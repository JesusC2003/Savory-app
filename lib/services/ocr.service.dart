// lib/services/ocr_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../core/config/environment.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();

  /// Tomar foto desde la cámara
  Future<List<Map<String, String>>> escanearDesdeCamara() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return [];

      return await _procesarImagen(File(image.path));
    } catch (e) {
      throw Exception('Error al tomar foto: $e');
    }
  }

  /// Seleccionar imagen desde galería
  Future<List<Map<String, String>>> escanearDesdeGaleria() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return [];

      return await _procesarImagen(File(image.path));
    } catch (e) {
      throw Exception('Error al cargar imagen: $e');
    }
  }

  /// Procesar imagen con Alibaba Cloud OCR + IA
  Future<List<Map<String, String>>> _procesarImagen(File imageFile) async {
    try {
      print('📸 Procesando imagen con Alibaba Cloud...');

      // 1. Convertir imagen a base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Llamar a la API de Alibaba Cloud
      final apiKey = Environment.alibabaApiKey;
      final url = Environment.alibabaUrl;

      print('🌐 URL: $url');
      print('🔑 API Key: ${apiKey.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'qwen-vl-max-latest',
          'messages': [
            {
              'role': 'system',
              'content': '''Eres un experto en reconocimiento de ingredientes. 
Tu tarea es analizar imágenes de alimentos o listas de compras y extraer TODOS los ingredientes visibles.

IMPORTANTE: Debes devolver un JSON válido con este formato exacto:
{
  "ingredientes": [
    {"nombre": "nombre_ingrediente", "cantidad": "numero", "unidad": "unidad_medida"},
    {"nombre": "otro_ingrediente", "cantidad": "numero", "unidad": "unidad_medida"}
  ]
}

REGLAS:
1. Si NO ves cantidad explícita, usa "1" como cantidad por defecto
2. Unidades válidas: kg, g, L, ml, unidades, tazas, cucharadas, cucharaditas
3. Si la unidad no está clara, usa "unidades"
4. Normaliza los nombres (sin tildes, en minúsculas, singular)
5. NO incluyas texto adicional, solo el JSON
6. Si no detectas ingredientes, devuelve: {"ingredientes": []}

EJEMPLOS:
- "2 kg de arroz" → {"nombre": "arroz", "cantidad": "2", "unidad": "kg"}
- "Leche" → {"nombre": "leche", "cantidad": "1", "unidad": "unidades"}
- "500g azúcar" → {"nombre": "azucar", "cantidad": "500", "unidad": "g"}
'''
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                },
                {
                  'type': 'text',
                  'text': 'Analiza esta imagen y extrae TODOS los ingredientes que veas. Devuelve SOLO el JSON, sin texto adicional.'
                }
              ]
            }
          ]
        }),
      );

      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ Error response: ${response.body}');
        throw Exception('Error API Alibaba: ${response.statusCode}');
      }

      // 3. Parsear respuesta
      final jsonResponse = jsonDecode(response.body);
      print('📦 Response completo: ${jsonEncode(jsonResponse)}');

      // Formato de respuesta de OpenAI compatible
      final content = jsonResponse['choices']?[0]?['message']?['content'];
      
      if (content == null || content.isEmpty) {
        print('⚠️ No se encontró contenido en la respuesta');
        return [];
      }

      print('📄 Contenido extraído: $content');

      // 4. Limpiar el texto y extraer JSON
      String textContent = content.toString().trim();
      
      // Buscar JSON entre ```json y ``` o directamente
      final jsonMatch = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true).firstMatch(textContent);
      if (jsonMatch != null) {
        textContent = jsonMatch.group(1)!;
      } else {
        // Buscar JSON directo
        final directJsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(textContent);
        if (directJsonMatch != null) {
          textContent = directJsonMatch.group(0)!;
        }
      }

      print('🔍 JSON limpio: $textContent');

      // 5. Parsear ingredientes
      final ingredientesJson = jsonDecode(textContent);
      final List<dynamic> ingredientesList = ingredientesJson['ingredientes'] ?? [];

      print('✅ Ingredientes detectados: ${ingredientesList.length}');

      // 6. Convertir a formato esperado
      return ingredientesList.map<Map<String, String>>((ing) {
        final nombre = ing['nombre']?.toString() ?? '';
        final cantidad = ing['cantidad']?.toString() ?? '1';
        final unidad = ing['unidad']?.toString() ?? 'unidades';
        
        print('   - $nombre: $cantidad $unidad');
        
        return {
          'nombre': nombre,
          'cantidad': cantidad,
          'unidad': unidad,
        };
      }).toList();

    } catch (e) {
      print('❌ Error al procesar imagen: $e');
      throw Exception('Error al procesar imagen: $e');
    }
  }

  /// Limpiar recursos
  void dispose() {
    // No hay recursos que limpiar con la API de Alibaba
  }
}