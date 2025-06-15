import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/models/chat_session_meta.dart';

class ChatSession with ChangeNotifier {
  static const String _boxPrefix = 'chat_';
  final String id;
  late Box<ChatMessage> _messageBox;
  List<ChatMessage> _messages = [];
  late Box<ChatSessionMeta> _metaBox;
  DateTime? _lastUpdated;
  bool _isDisposed = false;

  ChatSession(this.id);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  DateTime? get lastUpdated => _lastUpdated;

  @override
  void dispose() {
    _isDisposed = true;
    _saveMessages();
    _messageBox.close();
    //_metaBox.close();
    super.dispose();
  }

  Future<void> loadMessages() async {
    _messageBox = await Hive.openBox<ChatMessage>('$_boxPrefix$id');
    _metaBox = Hive.box<ChatSessionMeta>('sessionMeta');
    _messages = _messageBox.values.toList();
    _lastUpdated = DateTime.now();
    if (!_isDisposed) notifyListeners();
  }

  Future<int> addMessage(ChatMessage message) async {
    if (_isDisposed) return -1;
    
    final index = _messages.length;
    final messageWithTimestamp = message.copyWith(
      timestamp: DateTime.now(),
    );
    await _messageBox.put(index.toString(), messageWithTimestamp);
    _messages.add(messageWithTimestamp);
    _lastUpdated = DateTime.now();
    await _updateMeta();
    notifyListeners();
    return index;
  }

  Future<void> updateMessage(int index, ChatMessage message) async {
    if (index < 0 || index >= _messages.length) return;
    
    final messageWithTimestamp = message.copyWith(
      timestamp: DateTime.now(),
    );
    await _messageBox.put(index.toString(), messageWithTimestamp);
    _messages[index] = messageWithTimestamp;
    _lastUpdated = DateTime.now();
    await _updateMeta();
    notifyListeners();
  }

  Future<void> clear() async {
    if (_isDisposed) return;
    
    await _messageBox.clear();
    _messages.clear();
    
    await _metaBox.delete(id);
    
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    if (_isDisposed || !_messageBox.isOpen) return;
    await _messageBox.clear();
    await _messageBox.addAll(_messages);
  }

  Future<void> _updateMeta() async {
    final meta = ChatSessionMeta(
      id: id,
      updatedAt: DateTime.now(),
    );
    await _metaBox.put(id, meta);
  }

  List<Map<String, String>> toGptMessages() => _messages
    .map((m) => {'role': m.role, 'content': m.content})
    .toList();

  static Future<List<String>> getAllSessionIds() async {
    final metaBox = await Hive.box<ChatSessionMeta>('sessionMeta'); 
    return metaBox.values.map((meta) => meta.id).toList();
  }

  static Future<List<ChatSessionMeta>> getAllSessionMetas() async {
    final metaBox = await Hive.box<ChatSessionMeta>('sessionMeta');
    final allMetas = metaBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return allMetas;
  }

  static Future<void> deleteSession(String id) async {
    await Hive.deleteBoxFromDisk('$_boxPrefix$id');
    final metaBox = await Hive.box<ChatSessionMeta>('sessionMeta');
    await metaBox.delete(id);
  }
}
