import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage {
  @HiveField(0)
  final String role;

  @HiveField(1)
  final String content;

  ChatMessage({required this.role, required this.content});
}
