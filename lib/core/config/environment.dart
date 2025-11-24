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
}
