// lib/services/gemini_service.dart

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../Models/receta_model.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAJsSNtXZt2FcCk1HzmosvrzD8Is3sDJsc'; 
  late final GenerativeModel _model;

   GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Modelo más reciente (2024)
      apiKey: _apiKey,
    );
  }

  /// Genera 5 recetas basadas en los ingredientes disponibles
  Future<List<RecetaModel>> generarRecetasConIngredientes(
    List<IngredienteDespensaSimple> ingredientesDisponibles,
  ) async {
    try {
      final prompt = _crearPrompt(ingredientesDisponibles);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('No se recibió respuesta de Gemini');
      }

      return _parsearRespuestaGemini(response.text!);
    } catch (e) {
      throw Exception('Error al generar recetas con IA: $e');
    }
  }

  String _crearPrompt(List<IngredienteDespensaSimple> ingredientes) {
    final ingredientesTexto = ingredientes
        .map((i) => '- ${i.nombre}: ${i.cantidad} ${i.unidad}')
        .join('\n');

    return '''
Eres un chef experto. Dado los siguientes ingredientes disponibles, genera EXACTAMENTE 5 recetas diferentes que se puedan preparar.

Ingredientes disponibles en la despensa:
$ingredientesTexto

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido, sin texto adicional antes o después. El formato debe ser exactamente así:

{
  "recetas": [
    {
      "titulo": "Nombre de la receta",
      "descripcion": "Descripción breve y apetitosa de la receta",
      "tiempoPreparacion": 30,
      "porciones": 4,
      "dificultad": "Fácil",
      "categoria": "Almuerzo",
      "ingredientes": [
        {
          "nombre": "tomate",
          "cantidad": "2",
          "unidad": "unidades"
        },
        {
          "nombre": "cebolla",
          "cantidad": "1",
          "unidad": "unidades"
        }
      ],
      "pasos": [
        "Paso 1: Lavar y picar los tomates finamente",
        "Paso 2: Calentar aceite en una sartén a fuego medio",
        "Paso 3: Agregar la cebolla picada y cocinar hasta que esté dorada"
      ]
    }
  ]
}

Reglas importantes:
1. La dificultad debe ser EXACTAMENTE: "Fácil", "Media" o "Difícil"
2. La categoría debe ser EXACTAMENTE: "Desayuno", "Almuerzo", "Cena", "Postre" o "Snack"
3. tiempoPreparacion debe ser un número entero (minutos)
4. porciones debe ser un número entero
5. Los nombres de ingredientes deben estar en minúsculas
6. Intenta usar al máximo los ingredientes disponibles
7. Puedes agregar ingredientes comunes básicos (sal, pimienta, aceite, agua) si son necesarios
8. Cada receta debe tener al menos 4 pasos detallados
9. Genera EXACTAMENTE 5 recetas diferentes y variadas
10. Los pasos deben ser claros, específicos y fáciles de seguir
''';
  }

  List<RecetaModel> _parsearRespuestaGemini(String respuesta) {
    try {
      // Limpiar la respuesta
      String cleanResponse = respuesta.trim();
      
      // Remover markdown si existe
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      // Parsear JSON
      final Map<String, dynamic> json = jsonDecode(cleanResponse);
      final List<dynamic> recetasJson = json['recetas'] ?? [];

      if (recetasJson.isEmpty) {
        throw Exception('No se generaron recetas');
      }

      // Convertir a RecetaModel
      return recetasJson.map((recetaJson) {
        return RecetaModel(
          idReceta: '', // Se generará en Firestore
          titulo: recetaJson['titulo'] ?? 'Receta sin nombre',
          descripcion: recetaJson['descripcion'] ?? 'Sin descripción',
          tiempoPreparacion: recetaJson['tiempoPreparacion'] ?? 30,
          porciones: recetaJson['porciones'] ?? 4,
          dificultad: recetaJson['dificultad'] ?? 'Media',
          imagenUrl: '', // Por defecto vacío
          fechaRegistro: DateTime.now(),
          nivelAcceso: 'gratuita',
          categoria: recetaJson['categoria'] ?? 'Almuerzo',
          ingredientes: (recetaJson['ingredientes'] as List?)
                  ?.map((ing) => IngredienteRecetaDetalle(
                        nombre: ing['nombre'] ?? '',
                        cantidad: ing['cantidad']?.toString() ?? '0',
                        unidad: ing['unidad'] ?? 'unidades',
                      ))
                  .toList() ??
              [],
          pasos: List<String>.from(recetaJson['pasos'] ?? []),
          favorita: false,
        );
      }).toList();
    } catch (e) {
      throw Exception(
          'Error al procesar respuesta de IA: $e\n\nRespuesta original: $respuesta');
    }
  }
}