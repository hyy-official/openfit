import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String role;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime? timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  ChatMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, String> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.user(String content) => ChatMessage(
    role: 'user',
    content: content,
    timestamp: DateTime.now(),
  );

  factory ChatMessage.assistant(String content) => ChatMessage(
    role: 'assistant',
    content: content,
    timestamp: DateTime.now(),
  );

  @override
  String toString() => '[$role] $content';
}
