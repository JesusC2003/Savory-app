// lib/services/ocr_service.dart

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Tomar foto desde la cámara
  Future<List<String>> escanearDesdeCamara() async {
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
  Future<List<String>> escanearDesdeGaleria() async {
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

  /// Procesar imagen con OCR
  Future<List<String>> _procesarImagen(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = 
          await _textRecognizer.processImage(inputImage);

      // Extraer líneas de texto
      List<String> ingredientes = [];
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String texto = line.text.trim();
          
          // Filtrar líneas vacías y muy cortas
          if (texto.isNotEmpty && texto.length > 2) {
            ingredientes.add(texto);
          }
        }
      }

      return ingredientes;
    } catch (e) {
      throw Exception('Error al procesar imagen: $e');
    }
  }

  /// Limpiar recursos
  void dispose() {
    _textRecognizer.close();
  }
}