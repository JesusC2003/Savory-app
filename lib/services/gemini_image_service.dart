// lib/services/gemini_image_service.dart

import 'package:dio/dio.dart';
import 'package:proyecto_savory/core/config/environment.dart';

class GeminiImageService {
  late final Dio _dio;

  GeminiImageService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
    ));
  }

  /// Genera una imagen usando Gemini Imagen API
  /// Retorna la imagen en formato base64 con prefijo data:image
  Future<String> generarImagenReceta(String tituloReceta) async {
    try {
      print('🎨 Generando imagen con Gemini para: $tituloReceta');

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict',
        queryParameters: {
          'key': Environment.geminiApiKey,
        },
        data: {
          'instances': [
            {
              'prompt': 'Professional food photography of $tituloReceta, beautifully plated on a white ceramic dish, soft natural lighting, shallow depth of field, appetizing, high quality, 4k'
            }
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '4:3',
            'outputOptions': {
              'mimeType': 'image/jpeg'
            }
          }
        },
      );

      if (response.statusCode == 200 && response.data['predictions'] != null) {
        final predictions = response.data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final base64Image = predictions[0]['bytesBase64Encoded'];
          print('✅ Imagen generada exitosamente');
          return 'data:image/jpeg;base64,$base64Image';
        }
      }
      
      // Fallback si falla
      return await _generarConGeminiFlash(tituloReceta);
    } catch (e) {
      print('⚠️ Error con Imagen API, intentando con Gemini Flash: $e');
      return await _generarConGeminiFlash(tituloReceta);
    }
  }

  /// Alternativa usando Gemini 2.0 Flash con generación de imágenes
  Future<String> _generarConGeminiFlash(String tituloReceta) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent',
        queryParameters: {
          'key': Environment.geminiApiKey,
        },
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': 'Generate a photorealistic image of $tituloReceta. The dish should look appetizing, professionally plated, with good lighting.'
                }
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['image', 'text'],
            'responseMimeType': 'image/jpeg'
          }
        },
      );

      if (response.statusCode == 200) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List?;
          if (parts != null) {
            for (var part in parts) {
              if (part['inlineData'] != null) {
                final mimeType = part['inlineData']['mimeType'] ?? 'image/jpeg';
                final base64Data = part['inlineData']['data'];
                print('✅ Imagen generada con Gemini Flash');
                return 'data:$mimeType;base64,$base64Data';
              }
            }
          }
        }
      }
      
      return _getPlaceholderImage();
    } catch (e) {
      print('❌ Error generando imagen: $e');
      return _getPlaceholderImage();
    }
  }

  String _getPlaceholderImage() {
    // Retorna un placeholder genérico de comida
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop';
  }
}
