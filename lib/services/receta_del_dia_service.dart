// lib/services/receta_del_dia_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../Models/receta_model.dart';
import '../config/environment.dart';

class RecetaDelDiaService {
  late final Dio _dio;

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

  /// Obtiene receta del día basada en la hora actual
  /// Desayuno: 5:00 - 11:59
  /// Almuerzo: 12:00 - 17:59
  /// Cena: 18:00 - 23:59
  Future<RecetaModel> obtenerRecetaDelDia() async {
    try {
      final ahora = DateTime.now();
      final tipoComida = _obtenerTipoComidaPorHora(ahora);
      
      // Usar la fecha como seed para que sea diferente cada día
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
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1500,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        final receta = _parsearRespuestaRecetaDelDia(content, tipoComida);
        
        // Obtener imagen
        final imagenUrl = await _obtenerImagenReceta(receta.titulo);
        return receta.copyWith(imagenUrl: imagenUrl);
      } else {
        throw Exception('Error al generar receta del día');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
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
    try {
      // Buscar JSON válido en el contenido
      final jsonRegex = RegExp(r'\{[\s\S]*\}');
      final jsonMatch = jsonRegex.firstMatch(content);
      
      if (jsonMatch == null) {
        throw Exception('No se encontró JSON en la respuesta');
      }

      final jsonString = jsonMatch.group(0) ?? '{}';
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final List<dynamic> ingredientesJson = jsonData['ingredientes'] ?? [];
      final List<dynamic> pasosJson = jsonData['pasos'] ?? [];

      return RecetaModel(
        idReceta: 'receta-del-dia-${DateTime.now().toString().split(' ')[0]}',
        titulo: jsonData['titulo'] ?? 'Receta del Día',
        descripcion: jsonData['descripcion'] ?? '',
        imagenUrl: '', // Se cargará posteriormente
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
    } catch (e) {
      throw Exception('Error al parsear receta: $e');
    }
  }

  /// Obtiene imagen de Unsplash basada en el título de la receta
  Future<String> _obtenerImagenReceta(String titulo) async {
    try {
      final keywords = titulo
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .split(' ')
          .where((word) => word.isNotEmpty && word.length > 2)
          .take(3)
          .join('+');

      print('📸 Buscando imagen para receta del día: "$titulo"');

      final unsplashUrl = 'https://api.unsplash.com/photos/random'
          '?query=food+$keywords'
          '&w=400&h=300'
          '&fit=crop'
          '&client_id=RlM3aTEyMVZkdUowZWRvNWZkZmJGTVcyQ0lqUEJPd3ZlZ3Z5M0htSkc5eUE';

      try {
        final response = await _dio.get(unsplashUrl);
        if (response.statusCode == 200) {
          final imageUrl = response.data['urls']['regular'] ?? response.data['urls']['full'] ?? '';
          if (imageUrl.isNotEmpty) {
            print('✓ Imagen encontrada: $imageUrl');
            return imageUrl;
          }
        }
      } catch (e) {
        print('⚠️ Error en Unsplash: $e');
      }

      // Fallback a imagen genérica de comida
      print('📌 Usando fallback URL');
      return 'https://images.unsplash.com/photo-1495521821757-a1efb6729352'
          '?w=400&h=300&fit=crop&q=80';
    } catch (e) {
      print('❌ Error obteniendo imagen: $e');
      return '';
    }
  }
}
