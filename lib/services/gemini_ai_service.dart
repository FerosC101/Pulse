// lib/services/gemini_ai_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiAIService {
  static const String apiKey = 'AIzaSyBgePDAyyEv2c4OR-iMxY1P_ge6QDOsC8s';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiAIService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );

    _initializeChat();
  }

  void _initializeChat() {
    _chat = _model.startChat(history: [
      Content.text(_getSystemPrompt()),
    ]);
  }

  String _getSystemPrompt() {
    return '''
You are an AI Medical Assistant for MedMap AI - Smart Hospital Management System.

STRICT RULES YOU MUST FOLLOW:
1. ONLY answer questions related to:
   - Hospital services and facilities
   - Finding hospitals and doctors
   - Booking appointments
   - Medical emergencies and first aid
   - General health information
   - Using the MedMap AI app features
   
2. DO NOT answer questions about:
   - Non-medical topics (politics, entertainment, etc.)
   - Specific medical diagnoses (always recommend seeing a doctor)
   - Prescription medications (refer to healthcare professionals)
   - Personal advice unrelated to the app
   
3. If asked about non-medical topics, politely redirect:
   "I'm specialized in helping with hospital and healthcare-related queries through MedMap AI. How can I assist you with finding medical services?"

4. Always be:
   - Professional and empathetic
   - Clear and concise
   - Safety-conscious (in emergencies, recommend calling emergency services)
   
5. You have access to:
   - Real-time hospital bed availability
   - Doctor schedules and specialties
   - Hospital locations and contact information
   - Emergency routing capabilities

CURRENT CONTEXT:
- App Name: MedMap AI
- Features: Hospital mapping, AI assistance, emergency routing, appointment booking
- Location: Philippines (primarily Calamba, Laguna area)

RESPONSE FORMAT:
- Keep responses under 200 words
- Use bullet points for lists
- Be conversational but professional
- Suggest relevant app features when appropriate

How can I help you today?
''';
  }

  Future<String> sendMessage(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // Add context if provided (hospital data, user location, etc.)
      String enhancedMessage = message;
      
      if (context != null && context.isNotEmpty) {
        enhancedMessage += '\n\nContext: ${_formatContext(context)}';
      }

      final response = await _chat.sendMessage(
        Content.text(enhancedMessage),
      );

      return response.text ?? 'I apologize, but I could not generate a response. Please try again.';
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return 'I encountered an error. Please try again or contact support if the issue persists.';
    }
  }

  String _formatContext(Map<String, dynamic> context) {
    StringBuffer buffer = StringBuffer();
    
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

  // Get quick action responses
  Future<String> getQuickActionResponse(String action) async {
    switch (action) {
      case 'Find nearest hospital':
        return await sendMessage(
          'I need to find the nearest hospital. Can you help me locate one?',
        );
      
      case 'Check ICU availability':
        return await sendMessage(
          'Show me hospitals with available ICU beds',
        );
      
      case 'Emergency routing':
        return await sendMessage(
          'I have a medical emergency. Guide me to the nearest hospital.',
        );
      
      case 'Book appointment':
        return await sendMessage(
          'I want to book a doctor appointment. What information do you need?',
        );
      
      default:
        return await sendMessage(action);
    }
  }

  void resetChat() {
    _initializeChat();
  }
}