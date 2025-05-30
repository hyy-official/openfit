import 'package:hive/hive.dart';

part 'chat_session_meta.g.dart';

@HiveType(typeId: 1)
class ChatSessionMeta extends HiveObject {
  @HiveField(0)
  String sessionId;

  @HiveField(1)
  String lastMessage;

  @HiveField(2)
  DateTime updatedAt;
    

  ChatSessionMeta({
    required this.sessionId,
    required this.lastMessage,
    required this.updatedAt,
  });
}
