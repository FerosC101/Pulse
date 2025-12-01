// lib/core/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // API keys with fallback for web platform
  // These are used when .env is not available (web builds)
  // Mobile apps should use .env file for better security
  
  static const String _googleMapsApiKeyFallback = 'AIzaSyD8zE3WkUaWr8OiBuTpg_wEaWgI6AMPtsU';
  static const String _geminiApiKeyFallback = 'AIzaSyAHtaHaZp9_gHYbVE7HPveRf6BoxOXe9pI';
  
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
