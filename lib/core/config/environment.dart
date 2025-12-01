// lib/config/environment.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get geminiApiKey {
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  static String get alibabaApiKey {
    return dotenv.env['ALIBABA_API_KEY'] ?? '';
  }

  static String get alibabaUrl {
    return dotenv.env['ALIBABA_URL'] ?? '';
  }

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // Método para verificar que todo está configurado
  static void verificarConfiguracion() {
    print('🔧 Verificando configuración de Environment:');
    print('   - GEMINI_API_KEY: ${geminiApiKey.isNotEmpty ? "✓ Configurada (${geminiApiKey.substring(0, 10)}...)" : "✗ Falta"}');
    print('   - ALIBABA_API_KEY: ${alibabaApiKey.isNotEmpty ? "✓ Configurada (${alibabaApiKey.substring(0, 10)}...)" : "✗ Falta"}');
    print('   - ALIBABA_URL: ${alibabaUrl.isNotEmpty ? "✓ Configurada" : "✗ Falta"}');
    
    if (alibabaUrl.isNotEmpty) {
      print('   - URL completa: $alibabaUrl');
    }
    
    if (geminiApiKey.isEmpty || alibabaApiKey.isEmpty || alibabaUrl.isEmpty) {
      throw Exception(
        '❌ Faltan variables de entorno. Asegúrate de que el archivo .env existe '
        'y contiene: GEMINI_API_KEY, ALIBABA_API_KEY, ALIBABA_URL'
      );
    }
    
    print('✅ Todas las variables de entorno están configuradas correctamente');
  }
}