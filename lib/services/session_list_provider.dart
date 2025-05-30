import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/chat_session_meta.dart';

class SessionListProvider with ChangeNotifier {
  List<ChatSessionMeta> _sessions = [];

  List<ChatSessionMeta> get sessions => _sessions;

  Future<void> loadSessions() async {
    final metaBox = await Hive.openBox<ChatSessionMeta>('sessionMeta');
    _sessions = metaBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<void> refresh() async => await loadSessions();
}
