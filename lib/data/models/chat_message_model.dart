// lib/data/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { user, ai }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.userId,
    this.metadata,
  });

  // Factory constructor for user messages
  factory ChatMessage.user(String content, {String? userId}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  // Factory constructor for AI messages
  factory ChatMessage.ai(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  // Factory constructor from Firestore
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChatMessage(
      id: doc.id,
      content: data['content'] ?? '',
      type: data['type'] == 'user' ? MessageType.user : MessageType.ai,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'type': type == MessageType.user ? 'user' : 'ai',
      'timestamp': Timestamp.fromDate(timestamp),
      if (userId != null) 'userId': userId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Copy with method
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }
}