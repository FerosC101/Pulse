// lib/core/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // IMPORTANT: DO NOT commit real API keys to version control
  // Set up your API keys in .env file for development
  // For production, use environment variables or secure configuration
  
  static const String _googleMapsApiKeyFallback = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  static const String _geminiApiKeyFallback = 'YOUR_GEMINI_API_KEY_HERE';
  
  static String get googleMapsApiKey {
    try {
      final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (key != null && key.isNotEmpty) {
        return key;
      }
    } catch (e) {
      // dotenv not loaded, use fallback
    }
    return _googleMapsApiKeyFallback;
  }
  
  static String get geminiApiKey {
    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key != null && key.isNotEmpty) {
        return key;
      }
    } catch (e) {
      // dotenv not loaded, use fallback
    }
    return _geminiApiKeyFallback;
  }
}
