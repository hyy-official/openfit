import 'package:flutter/material.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/services/chat_session.dart';
import 'package:openfit/services/gpt_factory.dart';
import 'package:openfit/services/user_profile_loader.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;
  const ChatScreen({super.key, required this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatSession session;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);
  List<String> sessionIds = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _isProcessing.dispose();
    session.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    session = ChatSession(widget.sessionId);
    await session.loadMessages();
    final ids = await ChatSession.getAllSessionIds();
    if (mounted) {
      setState(() => sessionIds = ids);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (_isProcessing.value || text.trim().isEmpty) return;
    _isProcessing.value = true;
    _controller.clear();

    final userMsg = ChatMessage(role: 'user', content: text);
    final loadingMsg = ChatMessage(role: 'assistant', content: '');

    final userIndex = await session.addMessage(userMsg, context);
    final assistantIndex = await session.addMessage(loadingMsg, context);
    setState(() {});

    try {
      final reply = await _fetchReply();
      await _displayTypingEffect(assistantIndex, reply);
    } catch (e) {
      await session.updateMessage(
        assistantIndex,
        ChatMessage(role: 'assistant', content: '오류 발생: $e'),
      );
    } finally {
      final ids = await ChatSession.getAllSessionIds();
      if (mounted) {
        setState(() => sessionIds = ids);
      }
      _isProcessing.value = false;
    }
  }

  Future<String> _fetchReply() async {
    final client = await createGPTClientFromProfile();
    final history = session.toGptMessages();
    final prompt = await loadUserProfileAsPrompt();

    final buffer = StringBuffer();
    await for (final chunk in client.sendMessageWithStream(history, prompt)) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  Future<void> _displayTypingEffect(int index, String fullText) async {
    final buffer = StringBuffer();
    for (var char in fullText.characters) {
      buffer.write(char);
      await session.updateMessage(index, ChatMessage(role: 'assistant', content: buffer.toString()));
      if (mounted) setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildSessionList() => Container(
        width: 200,
        color: Colors.grey[200],
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text('📁 이전 채팅', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            for (final id in sessionIds)
              ListTile(
                title: Text('Session $id', overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                  onPressed: () => _deleteSession(id),
                ),
                selected: id == widget.sessionId,
                onTap: () => _navigateToSession(id),
              ),
          ],
        ),
      );

  Widget _buildChatPanel() => Expanded(
        flex: 2,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: session.messages.length,
                itemBuilder: (context, index) {
                  final msg = session.messages[index];
                  return Align(
                    alignment: msg.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.role == 'user' ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(color: msg.role == 'user' ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isProcessing,
                      builder: (context, processing, _) => TextField(
                        controller: _controller,
                        enabled: !processing,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: processing ? 'GPT가 응답 중입니다...' : '메시지를 입력하세요',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isProcessing,
                    builder: (context, processing, _) => IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: processing ? null : () => _sendMessage(_controller.text),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );

  Widget _buildAnalysisPanel() => Container(
        width: 250,
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('📊 채팅 분석', style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(),
            Text('• 감정: 긍정적'),
            Text('• 키워드: 운동, 다이어트'),
            Text('• 요약: ...'),
          ],
        ),
      );

  void _deleteSession(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('세션 삭제'),
        content: Text('정말로 세션 $id 를 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirm == true) {
      await ChatSession.deleteSession(id);
      final ids = await ChatSession.getAllSessionIds();
      if (!mounted) return;
      setState(() => sessionIds = ids);
      if (id == widget.sessionId) {
        final newSessionId = ids.isNotEmpty ? ids.first : 'default';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(sessionId: newSessionId)),
        );
      }
    }
  }

  void _navigateToSession(String id) {
    if (id != widget.sessionId) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(sessionId: id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.sessionId}')),
      body: Row(
        children: [
          _buildSessionList(),
          _buildChatPanel(),
          _buildAnalysisPanel(),
        ],
      ),
    );
  }
}
