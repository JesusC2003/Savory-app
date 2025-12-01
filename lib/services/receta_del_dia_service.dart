// lib/services/receta_del_dia_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_savory/core/config/environment.dart';
import '../Models/receta_model.dart';
import 'gemini_image_service.dart';

class RecetaDelDiaService {
  late final Dio _dio;
  final GeminiImageService _geminiImageService = GeminiImageService();
  
  static const String _keyRecetaDelDia = 'receta_del_dia';
  static const String _keyFechaReceta = 'fecha_receta_del_dia';

  RecetaDelDiaService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${Environment.alibabaApiKey}',
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Obtiene la receta del día
  /// Primero verifica si hay una guardada del mismo día
  Future<RecetaModel?> obtenerRecetaDelDia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ahora = DateTime.now();
      final hoyString = '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
      
      // Verificar si ya existe una receta guardada de hoy
      final fechaGuardada = prefs.getString(_keyFechaReceta);
      final recetaGuardada = prefs.getString(_keyRecetaDelDia);
      
      if (fechaGuardada == hoyString && recetaGuardada != null) {
        print('✅ Receta del día encontrada en caché local');
        final jsonData = jsonDecode(recetaGuardada) as Map<String, dynamic>;
        return RecetaModel.fromJson(jsonData);
      }
      
      // No hay receta de hoy, generar nueva
      print('🔄 Generando nueva receta del día...');
      final receta = await _generarNuevaReceta();
      
      if (receta != null) {
        // Generar imagen con Gemini
        final imagenBase64 = await _geminiImageService.generarImagenReceta(receta.titulo);
        final recetaConImagen = receta.copyWith(imagenUrl: imagenBase64);
        
        // Guardar en SharedPreferences (sin eliminar la anterior, solo se sobrescribe)
        await prefs.setString(_keyRecetaDelDia, jsonEncode(recetaConImagen.toJson()));
        await prefs.setString(_keyFechaReceta, hoyString);
        
        print('✅ Receta del día guardada para: $hoyString');
        return recetaConImagen;
      }
      
      return null;
    } catch (e) {
      print('❌ Error obteniendo receta del día: $e');
      return null;
    }
  }

  Future<RecetaModel?> _generarNuevaReceta() async {
    try {
      final ahora = DateTime.now();
      final tipoComida = _obtenerTipoComidaPorHora(ahora);
      final seed = '${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}';
      final prompt = _crearPromptRecetaDelDia(tipoComida, seed);

      final response = await _dio.post(
        Environment.alibabaUrl,
        data: {
          'model': 'qwen-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un chef experto que sugiere recetas saludables y deliciosas.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1500,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return _parsearRespuestaRecetaDelDia(content, tipoComida);
      }
      return null;
    } catch (e) {
      print('❌ Error generando receta: $e');
      return null;
    }
  }

  String _obtenerTipoComidaPorHora(DateTime fecha) {
    final hora = fecha.hour;
    if (hora >= 5 && hora < 12) {
      return 'Desayuno';
    } else if (hora >= 12 && hora < 18) {
      return 'Almuerzo';
    } else {
      return 'Cena';
    }
  }

  String _crearPromptRecetaDelDia(String tipoComida, String seed) {
    return '''Sugiere UNA sola receta creativa y diferente para $tipoComida.
Requisitos:
- NO requiere ingredientes específicos (usa ingredientes comunes)
- Tiempo de preparación: máximo 45 minutos
- Dificultad: Media
- Responde en formato JSON válido

Usa este seed para variación: $seed

Responde con JSON exactamente así:
{
  "titulo": "Nombre de la receta",
  "descripcion": "Descripción corta y apetitosa",
  "tiempoPreparacion": número,
  "porciones": número,
  "dificultad": "Fácil|Media|Difícil",
  "categoria": "$tipoComida",
  "ingredientes": [
    {"nombre": "...", "cantidad": "...", "unidad": "..."}
  ],
  "pasos": ["paso 1", "paso 2", ...]
}''';
  }

  RecetaModel _parsearRespuestaRecetaDelDia(String content, String tipoComida) {
    final jsonRegex = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonRegex.firstMatch(content);
    
    if (jsonMatch == null) {
      throw Exception('No se encontró JSON en la respuesta');
    }

    final jsonString = jsonMatch.group(0) ?? '{}';
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    final List ingredientesJson = jsonData['ingredientes'] ?? [];
    final List pasosJson = jsonData['pasos'] ?? [];

    return RecetaModel(
      idReceta: 'receta-del-dia-${DateTime.now().toString().split(' ')[0]}',
      titulo: jsonData['titulo'] ?? 'Receta del Día',
      descripcion: jsonData['descripcion'] ?? '',
      imagenUrl: '', // Se llenará después con Gemini
      tiempoPreparacion: jsonData['tiempoPreparacion'] ?? 30,
      porciones: jsonData['porciones'] ?? 2,
      dificultad: jsonData['dificultad'] ?? 'Media',
      categoria: tipoComida,
      ingredientes: ingredientesJson
          .map((ing) => IngredienteRecetaDetalle(
                nombre: ing['nombre'] ?? '',
                cantidad: ing['cantidad']?.toString() ?? '1',
                unidad: ing['unidad'] ?? 'un',
              ))
          .toList(),
      pasos: pasosJson.map((p) => p.toString()).toList(),
      favorita: false,
      preparada: false,
      fechaRegistro: DateTime.now(),
      nivelAcceso: 'gratuita',
    );
  }
  
  /// Obtener historial de recetas del día guardadas
  Future<List<Map<String, dynamic>>> obtenerHistorialRecetas() async {
    final prefs = await SharedPreferences.getInstance();
    final historialJson = prefs.getString('historial_recetas_del_dia');
    if (historialJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(historialJson));
    }
    return [];
  }
}
