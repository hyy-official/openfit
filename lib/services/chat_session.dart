import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/models/chat_session_meta.dart';
import 'package:openfit/services/session_list_provider.dart';
import 'package:openfit/services/user_profile_loader.dart';

class ChatSession with ChangeNotifier {
  final String sessionId;
  late Box<ChatMessage> _box;
  List<ChatMessage> _messages = [];
  bool _isDisposed = false;

  ChatSession(this.sessionId);

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  @override
  void dispose() {
    _isDisposed = true;
    saveMessages(); // 전체 저장
    _box.close();
    super.dispose();
  }

  Future<void> loadMessages() async {
    _box = await Hive.openBox<ChatMessage>('chat_$sessionId');
    _messages = _box.values.toList();
    if (!_isDisposed) notifyListeners();
  }

  Future<void> updateMessage(int index, ChatMessage newMessage) async {
    if (_isDisposed) return;
    if (index >= 0 && index < _messages.length) {
      _messages[index] = newMessage;
      await _box.putAt(index, newMessage);
      notifyListeners();
    }
  }

  Future<void> saveMessages() async {
    if (_isDisposed) return;
    if (!_box.isOpen) {
      _box = await Hive.openBox<ChatMessage>('chat_$sessionId');
    }

    await _box.clear(); // 기존 내용 삭제
    await _box.addAll(_messages); // 현재 메시지 전체 저장
  }

  Future<void> appendToMessage(int index, String delta) async {
    if (_isDisposed) return;
    final current = _messages[index];
    _messages[index] = ChatMessage(
      role: current.role,
      content: current.content + delta,
    );
  }

  Future<int> addMessage(ChatMessage message, BuildContext context) async {
    if (_isDisposed) return -1;
    _messages.add(message);
    final index = await _box.add(message);
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

    return index;
  }

  Future<void> clear() async {
    if (_isDisposed) return;
    await _box.clear();
    _messages.clear();
    notifyListeners();

    final metaBox = Hive.box<ChatSessionMeta>('sessionMeta');
    metaBox.delete(sessionId);
  }

  List<Map<String, String>> toGptMessages() {
    return messages.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();
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
