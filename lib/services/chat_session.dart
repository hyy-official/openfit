import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/models/chat_session_meta.dart';
import 'package:openfit/services/session_list_provider.dart';

class ChatSession with ChangeNotifier {
  final String sessionId;
  late Box<ChatMessage> _box;
  List<ChatMessage> _messages = [];

  ChatSession(this.sessionId);

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> loadMessages() async {
    _box = await Hive.openBox<ChatMessage>('chat_$sessionId');
    _messages = _box.values.toList();
    notifyListeners();
  }

  Future<void> addMessage(ChatMessage message, BuildContext context) async {
    _messages.add(message);
    await _box.add(message);
    notifyListeners();

    final metaBox = await Hive.openBox<ChatSessionMeta>('sessionMeta');
    final meta = ChatSessionMeta(
        sessionId: sessionId,
        lastMessage: message.content,
        updatedAt: DateTime.now(),
    );
    await metaBox.put(sessionId, meta);

    
    final sessionProvider = Provider.of<SessionListProvider>(context, listen: false);
    await sessionProvider.refresh();
  }


  List<Map<String, String>> toGptMessages() {
    return _messages.map((m) => {
      "role": m.role,
      "content": m.content,
    }).toList();
  }

  Future<void> clear() async {
    await _box.clear();
    _messages.clear();
    notifyListeners();

    final metaBox = Hive.box<ChatSessionMeta>('sessionMeta');
    metaBox.delete(sessionId);
  }

  static Future<List<String>> getAllSessionIds() async {
    final metaBox = await Hive.openBox<ChatSessionMeta>('sessionMeta');
    return metaBox.keys.map((key) => key.toString()).toList();
  }
  
  static Future<void> deleteSession(String sessionId) async {
    await Hive.deleteBoxFromDisk('chat_$sessionId');
    final metaBox = await Hive.openBox<ChatSessionMeta>('sessionMeta');
    await metaBox.delete(sessionId);
  }
}
