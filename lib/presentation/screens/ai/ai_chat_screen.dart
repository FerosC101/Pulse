// lib/presentation/screens/ai/ai_chat_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/constants/app_colors.dart';
import 'package:pulse/presentation/providers/chat_provider.dart';
import 'package:pulse/presentation/screens/ai/widgets/chat_bubble.dart';
import 'package:pulse/presentation/screens/ai/widgets/typing_indicator.dart';
import 'package:pulse/presentation/screens/ai/widgets/quick_action_button.dart';
import 'package:pulse/services/location_service.dart';
import 'package:pulse/presentation/screens/patient/hospital_list_screen.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showQuickActions = true;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(message);
    _messageController.clear();
    setState(() => _showQuickActions = false);
    _scrollToBottom();
  }

  void _sendQuickAction(String action) {
    // Check if it's a booking action
    if (action.toLowerCase().contains('book')) {
      // Navigate to hospital list for booking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HospitalListScreen(),
        ),
      );
      return;
    }

    // Otherwise, send as chat message
    ref.read(chatControllerProvider.notifier).sendQuickAction(action);
    setState(() => _showQuickActions = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Custom Header with red gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B6B), Color(0xFFD32F2F)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        color: Color(0xFFD32F2F),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Medical Assistant',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Metro General',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Refresh button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          ref.read(chatControllerProvider.notifier).resetChat();
                          setState(() => _showQuickActions = true);
                        },
                        tooltip: 'Reset Chat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Location Status Banner
          Consumer(
            builder: (context, ref, child) {
              final chatState = ref.watch(chatControllerProvider);

              if (!chatState.hasLocation) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: AppColors.warning.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Location disabled. Enable for accurate distance information.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Request location permission
                          final locationService = LocationService();
                          await locationService.requestPermission();
                          // Refresh chat
                          ref.read(chatControllerProvider.notifier).resetChat();
                        },
                        child: const Text(
                          'Enable',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length && chatState.isLoading) {
                  return const TypingIndicator();
                }

                return ChatBubble(message: chatState.messages[index]);
              },
            ),
          ),

          // Quick Actions (shown initially)
          if (_showQuickActions && chatState.messages.length == 1)
            _buildQuickActions(),

          // Input Field
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFF5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick actions:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              QuickActionButton(
                icon: Icons.local_hospital,
                label: 'Find nearest hospital',
                onTap: () => _sendQuickAction('Find nearest hospital'),
              ),
              QuickActionButton(
                icon: Icons.airline_seat_flat,
                label: 'Check ICU availability',
                onTap: () => _sendQuickAction('Check ICU availability'),
              ),
              QuickActionButton(
                icon: Icons.emergency,
                label: 'Emergency routing',
                onTap: () => _sendQuickAction('Emergency routing'),
              ),
              QuickActionButton(
                icon: Icons.calendar_today,
                label: 'Book appointment',
                onTap: () => _sendQuickAction('Book appointment'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about hospitals...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFFD32F2F)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(26),
                  child: const Center(
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}