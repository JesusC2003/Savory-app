// lib/services/gemini_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:proyecto_savory/core/config/environment.dart';
import '../Models/receta_model.dart';

class GeminiService {
  late final String _geminiApiKey;
  late final String _alibabaApiKey;
  late final String _alibabaUrl;
  
  late final Dio _dio;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  GeminiService() {
    _geminiApiKey = Environment.geminiApiKey;
    _alibabaApiKey = Environment.alibabaApiKey;
    _alibabaUrl = Environment.alibabaUrl;
    
    if (_geminiApiKey.isEmpty || _alibabaApiKey.isEmpty) {
      throw Exception(
        'Las claves API no están configuradas. '
        'Verifica que el archivo .env existe y contiene GEMINI_API_KEY y ALIBABA_API_KEY'
      );
    }
    
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  /// Genera 3 recetas con Alibaba (SIN imágenes todavía)
  Future<List<RecetaModel>> generarRecetasConIngredientes(
    List<IngredienteDespensaSimple> ingredientesDisponibles,
  ) async {
    try {
      print('🍳 Generando 3 recetas con Alibaba...');
      
      // 1. Generar recetas con Alibaba (sin imágenes)
      final recetasBase = await _generarRecetasConAlibaba(ingredientesDisponibles);
      
      print('✅ ${recetasBase.length} recetas generadas (sin imágenes)');
      return recetasBase;
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Genera imagen con Gemini y la sube a Firebase Storage
  /// Se llama cuando el usuario SELECCIONA una receta
  Future<String> generarYSubirImagenReceta(String tituloReceta, String idReceta) async {
    try {
      print('🎨 Generando imagen con Gemini para: "$tituloReceta"');
      
      // 1. Generar imagen con Gemini (devuelve base64)
      final base64Image = await _generarImagenConGemini(tituloReceta);
      
      // 2. Convertir base64 a bytes
      final imageBytes = base64Decode(base64Image);
      
      // 3. Subir a Firebase Storage
      final imageUrl = await _subirImagenAFirebase(imageBytes, idReceta);
      
      print('✅ Imagen generada y subida: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error generando imagen: $e');
      throw Exception('Error al generar imagen con Gemini: $e');
    }
  }

  /// Genera imagen usando Gemini Imagen API
  Future<String> _generarImagenConGemini(String tituloReceta) async {
    try {
      final prompt = _crearPromptImagen(tituloReceta);
      
      print('📸 Prompt para Gemini: "$prompt"');
      
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict',
        queryParameters: {'key': _geminiApiKey},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'instances': [
            {'prompt': prompt}
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '1:1', // Imagen cuadrada
            'negativePrompt': 'blurry, low quality, text, watermark, logo',
          }
        },
      );

      if (response.statusCode == 200) {
        final predictions = response.data['predictions'];
        if (predictions != null && predictions.isNotEmpty) {
          final base64Image = predictions[0]['bytesBase64Encoded'];
          if (base64Image != null) {
            print('✅ Imagen generada correctamente');
            return base64Image;
          }
        }
        throw Exception('Respuesta de Gemini no contiene imagen');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Solicitud inválida a Gemini: ${e.response?.data}');
      } else if (e.response?.statusCode == 403) {
        throw Exception('API Key de Gemini inválida o sin permisos');
      }
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Sube imagen a Firebase Storage y devuelve la URL
  Future<String> _subirImagenAFirebase(Uint8List imageBytes, String idReceta) async {
    try {
      // Crear referencia única en Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recetas/$idReceta-$timestamp.png';
      final storageRef = _storage.ref().child(fileName);
      
      print('📤 Subiendo imagen a Firebase Storage: $fileName');
      
      // Subir imagen
      final uploadTask = await storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/png'),
      );
      
      // Obtener URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('✅ Imagen subida exitosamente');
      return downloadUrl;
    } catch (e) {
      print('❌ Error subiendo a Firebase Storage: $e');
      throw Exception('Error al subir imagen a Firebase: $e');
    }
  }

  /// Crea un prompt optimizado para generar imágenes de comida
  String _crearPromptImagen(String tituloReceta) {
    return 'Professional food photography of $tituloReceta, '
           'beautifully plated on a white dish, '
           'natural lighting, high quality, '
           'appetizing presentation, '
           'restaurant style, '
           '8k resolution, '
           'detailed texture, '
           'vibrant colors';
  }

  /// Genera recetas usando Alibaba API (sin imágenes)
  Future<List<RecetaModel>> _generarRecetasConAlibaba(
    List<IngredienteDespensaSimple> ingredientes,
  ) async {
    try {
      final prompt = _crearPromptAlibaba(ingredientes);
      
      final response = await _dio.post(
        _alibabaUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_alibabaApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'qwen-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un chef experto que crea recetas deliciosas y fáciles de seguir.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.8,
          'max_tokens': 2000,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return _parsearRespuestaAlibaba(content);
      } else {
        throw ApiErrorHandler.handleHttpError(response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  String _crearPromptAlibaba(List<IngredienteDespensaSimple> ingredientes) {
    final ingredientesTexto = ingredientes
        .map((i) => '${i.nombre}: ${i.cantidad} ${i.unidad}')
        .join(', ');

    return '''
Ingredientes disponibles: $ingredientesTexto

Genera EXACTAMENTE 3 recetas diferentes en formato JSON válido. Sin texto adicional.

Formato requerido:
{
  "recetas": [
    {
      "titulo": "Nombre atractivo",
      "descripcion": "Descripción breve (max 100 caracteres)",
      "tiempoPreparacion": 30,
      "porciones": 4,
      "dificultad": "Fácil",
      "categoria": "Almuerzo",
      "ingredientes": [
        {"nombre": "tomate", "cantidad": "2", "unidad": "unidades"}
      ],
      "pasos": [
        "Paso 1: acción específica",
        "Paso 2: acción específica"
      ]
    }
  ]
}

Reglas:
- dificultad: "Fácil", "Media" o "Difícil"
- categoria: "Desayuno", "Almuerzo", "Cena", "Postre" o "Snack"
- tiempoPreparacion y porciones: números enteros
- ingredientes en minúsculas
- Mínimo 4 pasos por receta
- Usar máximo ingredientes disponibles
- Agregar ingredientes básicos solo si necesario (sal, pimienta, aceite, agua)
''';
  }

  List<RecetaModel> _parsearRespuestaAlibaba(String respuesta) {
    try {
      // Limpiar respuesta
      String cleanResponse = respuesta.trim();
      
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

      final Map<String, dynamic> json = jsonDecode(cleanResponse);
      final List<dynamic> recetasJson = json['recetas'] ?? [];

      if (recetasJson.isEmpty || recetasJson.length < 3) {
        throw Exception('Se esperaban 3 recetas, se recibieron ${recetasJson.length}');
      }

      return recetasJson.take(3).map((recetaJson) {
        return RecetaModel(
          idReceta: '',
          titulo: recetaJson['titulo'] ?? 'Receta sin nombre',
          descripcion: recetaJson['descripcion'] ?? 'Sin descripción',
          promptImagen: null, // Ya no necesitamos esto
          tiempoPreparacion: recetaJson['tiempoPreparacion'] ?? 30,
          porciones: recetaJson['porciones'] ?? 4,
          dificultad: _validarDificultad(recetaJson['dificultad']),
          imagenUrl: '', // Se llenará cuando se seleccione la receta
          fechaRegistro: DateTime.now(),
          nivelAcceso: 'gratuita',
          categoria: _validarCategoria(recetaJson['categoria']),
          ingredientes: (recetaJson['ingredientes'] as List?)
                  ?.map((ing) => IngredienteRecetaDetalle(
                        nombre: (ing['nombre'] ?? '').toString().toLowerCase(),
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
      throw Exception('Error al procesar respuesta: $e\n\nRespuesta: $respuesta');
    }
  }

  String _validarDificultad(dynamic dificultad) {
    const validas = ['Fácil', 'Media', 'Difícil'];
    final dif = dificultad?.toString() ?? 'Media';
    return validas.contains(dif) ? dif : 'Media';
  }

  String _validarCategoria(dynamic categoria) {
    const validas = ['Desayuno', 'Almuerzo', 'Cena', 'Postre', 'Snack'];
    final cat = categoria?.toString() ?? 'Almuerzo';
    return validas.contains(cat) ? cat : 'Almuerzo';
  }
}

class ApiErrorHandler {
  /// Maneja errores HTTP por código de estado
  static Exception handleHttpError(int statusCode) {
    switch (statusCode) {
      case 400:
        return Exception('Solicitud inválida');
      case 401:
        return Exception('No autorizado');
      case 403:
        return Exception('Acceso denegado');
      case 404:
        return Exception('Recurso no encontrado');
      case 429:
        return Exception('Demasiadas solicitudes. Intenta después');
      case 500:
        return Exception('Error interno del servidor');
      case 503:
        return Exception('Servicio no disponible');
      default:
        return Exception('Error HTTP $statusCode');
    }
  }

  /// Maneja errores de DioException
  static Exception handleDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Tiempo de conexión agotado');
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de respuesta agotado');
      case DioExceptionType.badResponse:
        return handleHttpError(dioError.response?.statusCode ?? 500);
      case DioExceptionType.unknown:
        return Exception('Error desconocido: ${dioError.message}');
      default:
        return Exception('Error de conexión: ${dioError.message}');
    }
  }

  /// Maneja cualquier tipo de error
  static Exception handleError(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    }
    if (error is Exception) {
      return error;
    }
    return Exception('Error desconocido: ${error.toString()}');
  }
}