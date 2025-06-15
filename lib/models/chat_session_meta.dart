import 'package:hive/hive.dart';

part 'chat_session_meta.g.dart';

@HiveType(typeId: 1)
class ChatSessionMeta extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime updatedAt;

  ChatSessionMeta({
    required this.id,
    required this.updatedAt,
  });

  factory ChatSessionMeta.create(String title) => ChatSessionMeta(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    updatedAt: DateTime.now(),
  );

  ChatSessionMeta copyWith({
    String? id,
    DateTime? updatedAt,
  }) => ChatSessionMeta(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() => 'ChatSession($id)';
}
