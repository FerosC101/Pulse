import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiAIService {
  static const String apiKey = 'AIzaSyDsqyQ_IlhJfjzGN6YXNONMq3e0c87RqEk';

  final List<Map<String, dynamic>> _conversationHistory = [];
  final String _modelName = 'chat-bison-001'; 

  GeminiAIService() {
    _initializeChat();
  }

  void _initializeChat() {
    _conversationHistory.clear();
    // Add system prompt
    _conversationHistory.add({
      'role': 'user',
      'parts': [{'text': _getSystemPrompt()}]
    });
    _conversationHistory.add({
      'role': 'model',
      'parts': [
        {
          'text':
              'I understand. I am your AI Medical Assistant for MedMap AI, ready to help with hospital and healthcare-related queries in the Calamba, Laguna area.'
        }
      ]
    });
  }

  String _getSystemPrompt() {
    return '''
You are an AI Medical Assistant for MedMap AI - Smart Hospital Management System in the Philippines.

STRICT RULES:
1. ONLY answer questions about:
   - Hospital services and facilities
   - Finding hospitals and doctors
   - Booking appointments
   - Medical emergencies and first aid
   - General health information
   - MedMap AI app features

2. DO NOT answer:
   - Non-medical topics
   - Specific medical diagnoses (refer to doctors)
   - Prescription medications

3. Always be professional, empathetic, and concise
4. In emergencies, recommend calling emergency services

CONTEXT:
- App: MedMap AI
- Location: Calamba, Laguna, Philippines
- Features: Hospital mapping, AI assistance, emergency routing, appointment booking

Keep responses under 200 words and conversational.
''';
  }

  /// Send a message to the AI
  Future<String> sendMessage(String message,
      {Map<String, dynamic>? context}) async {
    try {
      // Add context if provided
      String enhancedMessage = message;
      if (context != null && context.isNotEmpty) {
        enhancedMessage += '\n\nContext: ${_formatContext(context)}';
      }

      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {'text': enhancedMessage}
        ]
      });

      final responseText = await _tryModel(_modelName);

      if (responseText != null) {
        _conversationHistory.add({
          'role': 'model',
          'parts': [
            {'text': responseText}
          ]
        });
        return responseText;
      }

      return 'I apologize, but I\'m having trouble connecting. Please check your internet connection and try again.';
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return 'I encountered an error. Please try again in a moment.';
    }
  }

  /// Try generating content from a given model
  Future<String?> _tryModel(String modelName) async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': _conversationHistory,
              'generationConfig': {
                'temperature': 0.7,
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 1024,
              },
              'safetySettings': [
                {
                  'category': 'HARM_CATEGORY_HARASSMENT',
                  'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                },
                {
                  'category': 'HARM_CATEGORY_HATE_SPEECH',
                  'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                },
                {
                  'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                  'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                },
                {
                  'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                  'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } else {
        debugPrint('❌ Model $modelName failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Model $modelName error: $e');
    }

    return null;
  }

  String _formatContext(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    if (context.containsKey('nearbyHospitals')) {
      buffer.write('Nearby hospitals: ${context['nearbyHospitals']}. ');
    }

    if (context.containsKey('userLocation')) {
      buffer.write('User location: ${context['userLocation']}. ');
    }

    if (context.containsKey('availableBeds')) {
      buffer.write('Available beds: ${context['availableBeds']}. ');
    }

    return buffer.toString();
  }

  Future<String> getQuickActionResponse(String action) async {
    switch (action) {
      case 'Find nearest hospital':
        return await sendMessage('I need to find the nearest hospital. Can you help me locate one?');
      case 'Check ICU availability':
        return await sendMessage('Show me hospitals with available ICU beds');
      case 'Emergency routing':
        return await sendMessage('I have a medical emergency. Guide me to the nearest hospital.');
      case 'Book appointment':
        return await sendMessage('I want to book a doctor appointment. What information do you need?');
      default:
        return await sendMessage(action);
    }
  }

  /// Reset chat safely
  void resetChat() {
    _initializeChat();
    // Model stays hardcoded
  }
}
