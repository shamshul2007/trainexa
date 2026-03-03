import 'dart:convert';

/// Represents a chat message exchanged with the AI trainer
class ChatMessage {
  final String id;
  final String userId;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'role': role,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String encode() => jsonEncode(toJson());

  static ChatMessage? tryDecode(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      final data = jsonDecode(source) as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
