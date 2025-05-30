import 'package:flutter/material.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/services/chat_session.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;
  const ChatScreen({super.key, required this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatSession session;
  final TextEditingController _controller = TextEditingController();
  List<String> sessionIds = [];

  @override
  void initState() {
    super.initState();
    session = ChatSession(widget.sessionId);
    session.loadMessages().then((_) => setState(() {}));


    ChatSession.getAllSessionIds().then((ids) {
      setState(() {
        sessionIds = ids;
      });
    });
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    await session.addMessage(ChatMessage(role: 'user', content: text), context);
    await session.addMessage(ChatMessage(role: 'assistant', content: '응답 준비 중...'), context);

    _controller.clear();

    final ids = await ChatSession.getAllSessionIds();
    setState(() {
      sessionIds = ids;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.sessionId}')),
      body: Row(
        children: [
          // 1. 세션 목록 패널
          Container(
            width: 200,
            color: Colors.grey[200],
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text('📁 이전 채팅', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                for (final id in sessionIds)
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Session $id', overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('세션 삭제'),
                                content: Text('정말로 세션 $id 를 삭제할까요?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ChatSession.deleteSession(id);
                              final ids = await ChatSession.getAllSessionIds();
                              setState(() {
                                sessionIds = ids;
                              });

                              if (id == widget.sessionId && ids.isNotEmpty) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => ChatScreen(sessionId: ids.first)),
                                );
                              } else if (ids.isEmpty) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ChatScreen(sessionId: 'default')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    selected: id == widget.sessionId,
                    onTap: () {
                      if (id != widget.sessionId) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(sessionId: id),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),

          // 2. 채팅 입력/응답 패널
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: session.messages.length,
                    itemBuilder: (context, index) {
                      final msg = session.messages[index];
                      return Align(
                        alignment: msg.role == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: msg.role == 'user' ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: msg.role == 'user' ? Colors.white : Colors.black87,
                            ),
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
                        child: TextField(
                          controller: _controller,
                          onSubmitted: _sendMessage,
                          decoration: const InputDecoration(
                            hintText: "메시지를 입력하세요",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _sendMessage(_controller.text),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. 채팅 분석 패널
          Container(
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
                // TODO: 실제 분석 로직 연결
              ],
            ),
          ),
        ],
      ),
    );
  }
}
