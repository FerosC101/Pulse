// lib/presentation/providers/chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_hospital_app/data/models/chat_message_model.dart';
import 'package:smart_hospital_app/services/gemini_ai_service.dart';
import 'package:smart_hospital_app/services/chat_context_service.dart';
import 'package:smart_hospital_app/presentation/providers/auth_provider.dart';

// Services
final geminiServiceProvider = Provider((ref) => GeminiAIService());
final chatContextServiceProvider = Provider((ref) => ChatContextService());

// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Chat controller
class ChatController extends StateNotifier<ChatState> {
  final GeminiAIService _geminiService;
  final ChatContextService _contextService;
  final String? _userId;

  ChatController(
    this._geminiService,
    this._contextService,
    this._userId,
  ) : super(ChatState(messages: [])) {
    _initializeChat();
  }

  void _initializeChat() {
    // Add welcome message
    final welcomeMessage = ChatMessage.ai(
      'Hello! I\'m your AI medical assistant for Metro General Hospital. '
      'I can help you find hospitals, check availability, book appointments, '
      'and provide emergency routing. How can I assist you today?',
    );
    
    state = state.copyWith(
      messages: [welcomeMessage],
    );
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(message, userId: _userId);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // Save to Firebase
    if (_userId != null) {
      await _contextService.saveChatMessage(_userId, message, 'user');
    }

    try {
      // Get hospital context
      final context = await _contextService.getHospitalContext();

      // Send to Gemini
      final response = await _geminiService.sendMessage(
        message,
        context: context,
      );

      // Add AI response
      final aiMessage = ChatMessage.ai(response, metadata: context);
      
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      // Save AI response to Firebase
      if (_userId != null) {
        await _contextService.saveChatMessage(_userId, response, 'ai');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendQuickAction(String action) async {
    state = state.copyWith(isLoading: true);

    try {
      final context = await _contextService.getHospitalContext();
      final response = await _geminiService.getQuickActionResponse(action);

      final aiMessage = ChatMessage.ai(response, metadata: context);
      
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void resetChat() {
    _geminiService.resetChat();
    _initializeChat();
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  final contextService = ref.watch(chatContextServiceProvider);
  final user = ref.watch(currentUserProvider).value;
  
  return ChatController(geminiService, contextService, user?.id);
});