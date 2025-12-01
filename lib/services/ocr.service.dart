import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  static const String _baseUrl = 
      'https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions';
  
  final ImagePicker _picker = ImagePicker();
  
  String get _apiKey => dotenv.env['DASHSCOPE_API_KEY'] ?? '';

  /// Escanear desde cámara
  Future<List<String>> escanearDesdeCamara() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return [];
    return await _processImage(File(image.path));
  }

  /// Escanear desde galería
  Future<List<String>> escanearDesdeGaleria() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return [];
    return await _processImage(File(image.path));
  }

  /// Procesar imagen y extraer ingredientes
  Future<List<String>> _processImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    final extension = imageFile.path.split('.').last.toLowerCase();
    final mimeType = _getMimeType(extension);
    final imageUrl = 'data:$mimeType;base64,$base64Image';
    
    final text = await _callOcrApi(imageUrl);
    return _parseIngredients(text);
  }

  Future<String> _callOcrApi(String imageContent) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      'model': 'qwen-vl-ocr',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': imageContent},
              'min_pixels': 28 * 28 * 4,
              'max_pixels': 28 * 28 * 8192,
            },
            {
              'type': 'text',
              'text': '''Analiza esta imagen de ticket/recibo de supermercado.
Extrae SOLO los nombres de los productos/ingredientes alimenticios.
Devuelve una lista simple, un ingrediente por línea.
No incluyas precios, cantidades, códigos ni caracteres especiales.
Solo nombres de alimentos.''',
            },
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception('Error OCR: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en solicitud OCR: $e');
    }
  }

  /// Parsear texto a lista de ingredientes
  List<String> _parseIngredients(String text) {
    if (text.isEmpty) return [];
    
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.length > 1)
        .where((line) => !RegExp(r'^[\d\$\.\,\-\*]+$').hasMatch(line))
        .toList();
  }

  String _getMimeType(String extension) {
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
    };
    return mimeTypes[extension] ?? 'image/jpeg';
  }

  /// Método dispose (requerido por DespensaPage)
  void dispose() {
    // Limpiar recursos si es necesario
    // En este caso no hay recursos persistentes que limpiar
  }
}
