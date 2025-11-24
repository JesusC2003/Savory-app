// lib/services/gemini_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Models/receta_model.dart';

class GeminiService {
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _alibabaApiKey = String.fromEnvironment('ALIBABA_API_KEY');
  static const String _alibabaUrl = 'https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions';
  
  late final Dio _dio;
  late final FirebaseStorage _storage;

  GeminiService() {
    if (_geminiApiKey.isEmpty || _alibabaApiKey.isEmpty) {
      throw Exception(
        'Las claves API no están configuradas. '
        'Ejecuta con: flutter run --dart-define=GEMINI_API_KEY=TU_KEY --dart-define=ALIBABA_API_KEY=TU_KEY'
      );
    }
    
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer $_alibabaApiKey',
        'Content-Type': 'application/json',
      },
    ));
    
    _storage = FirebaseStorage.instance;
  }

  /// Genera 3 recetas con Alibaba y sus imágenes con Gemini
  Future<List<RecetaModel>> generarRecetasConIngredientes(
    List<IngredienteDespensaSimple> ingredientesDisponibles,
  ) async {
    try {
      // 1. Generar recetas con Alibaba
      final recetasBase = await _generarRecetasConAlibaba(ingredientesDisponibles);
      
      // 2. Generar imágenes con Gemini para cada receta
      final recetasConImagenes = <RecetaModel>[];
      
      for (var receta in recetasBase) {
        try {
          // Generar URL de imagen desde prompt
          final imagenUrl = await _generarYGuardarImagenGemini(receta);
          recetasConImagenes.add(receta.copyWith(imagenUrl: imagenUrl));
        } catch (e) {
          print('Error generando imagen: $e');
          // Si falla la imagen, usar URL placeholder
          final placeholderUrl = _generarUrlPlaceholder(receta.promptImagen ?? receta.titulo);
          recetasConImagenes.add(receta.copyWith(imagenUrl: placeholderUrl));
        }
      }
      
      return recetasConImagenes;
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  /// Genera imagen con Gemini y la guarda en Firebase Storage
  Future<String> _generarYGuardarImagenGemini(RecetaModel receta) async {
    try {
      // Descargar imagen desde URL externa (Unsplash o similar)
      final imageUrl = await _descargarImagenDeInternet(receta.promptImagen ?? receta.titulo);
      
      if (imageUrl.isEmpty) {
        throw Exception('No se pudo generar la imagen');
      }

      // Guardar en Firebase Storage
      final urlGuardada = await _guardarImagenEnFirebaseStorage(receta.idReceta, imageUrl);
      
      return urlGuardada;
    } catch (e) {
      // Si falla, retornar placeholder
      return _generarUrlPlaceholder(receta.promptImagen ?? receta.titulo);
    }
  }

  /// Descarga imagen de una URL de internet
  Future<String> _descargarImagenDeInternet(String prompt) async {
    try {
      // Generar URL de Unsplash basada en el prompt
      final keywords = prompt
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z\s]'), '')
          .split(' ')
          .where((word) => word.isNotEmpty)
          .take(2)
          .join('+');
      
      final unsplashUrl = 'https://api.unsplash.com/photos/random?query=food+$keywords&client_id=RlM3aTEyMVZkdUowZWRvNWZkZmJGTVcyQ0lqUEJPd3ZlZ3Z5M0htSkc5eUE';
      
      try {
        final response = await _dio.get(unsplashUrl);
        if (response.statusCode == 200) {
          return response.data['urls']['regular'] ?? '';
        }
      } catch (e) {
        print('Error obteniendo imagen de Unsplash: $e');
      }
      
      // Fallback a URL genérica de comida
      return 'https://source.unsplash.com/400x300/?food,${keywords.replaceAll(' ', ',')}';
    } catch (e) {
      throw Exception('Error descargando imagen: $e');
    }
  }

  /// Guarda la imagen en Firebase Storage y retorna URL descargable
  Future<String> _guardarImagenEnFirebaseStorage(String recetaId, String imagenUrl) async {
    try {
      if (recetaId.isEmpty) {
        // Si la receta aún no tiene ID, usar un ID temporal basado en timestamp
        recetaId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Descargar la imagen
      final imageBytes = await _descargarImagenComoBytes(imagenUrl);
      
      // Ruta en Firebase Storage
      final storagePath = 'recetas/$recetaId/imagen_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Subir a Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putData(imageBytes);
      
      // Obtener URL descargable
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error guardando imagen en Firebase: $e');
      throw Exception('No se pudo guardar la imagen');
    }
  }

  /// Descarga imagen como bytes desde una URL
  Future<Uint8List> _descargarImagenComoBytes(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw Exception('Error descargando imagen: $e');
    }
  }

  /// Genera recetas usando Alibaba API
  Future<List<RecetaModel>> _generarRecetasConAlibaba(
    List<IngredienteDespensaSimple> ingredientes,
  ) async {
    try {
      final prompt = _crearPromptAlibaba(ingredientes);
      
      final response = await _dio.post(
        _alibabaUrl,
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

  String _generarUrlPlaceholder(String prompt) {
    // Genera URL de Unsplash basado en palabras clave del prompt
    final keywords = prompt
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(' ')
        .take(2)
        .join(',');
    
    return 'https://source.unsplash.com/400x300/?food,$keywords';
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
      "promptImagen": "Descripción para generar imagen: un plato de [receta] servido profesionalmente, luz natural, fotografía gastronómica",
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
- promptImagen: descripción visual profesional del plato terminado
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
          promptImagen: recetaJson['promptImagen'],
          tiempoPreparacion: recetaJson['tiempoPreparacion'] ?? 30,
          porciones: recetaJson['porciones'] ?? 4,
          dificultad: _validarDificultad(recetaJson['dificultad']),
          imagenUrl: '',
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

// Extensión para copiar RecetaModel con cambios
extension RecetaModelExtension on RecetaModel {
  RecetaModel copyWith({String? imagenUrl}) {
    return RecetaModel(
      idReceta: this.idReceta,
      titulo: this.titulo,
      descripcion: this.descripcion,
      promptImagen: this.promptImagen,
      tiempoPreparacion: this.tiempoPreparacion,
      porciones: this.porciones,
      dificultad: this.dificultad,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fechaRegistro: this.fechaRegistro,
      nivelAcceso: this.nivelAcceso,
      categoria: this.categoria,
      ingredientes: this.ingredientes,
      pasos: this.pasos,
      favorita: this.favorita,
    );
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