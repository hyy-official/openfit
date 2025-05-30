// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_meta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatSessionMetaAdapter extends TypeAdapter<ChatSessionMeta> {
  @override
  final int typeId = 1;

  @override
  ChatSessionMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatSessionMeta(
      sessionId: fields[0] as String,
      lastMessage: fields[1] as String,
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatSessionMeta obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.lastMessage)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSessionMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
