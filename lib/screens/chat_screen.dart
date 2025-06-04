import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/services/chat_session.dart';
import 'package:openfit/services/gpt_factory.dart';
import 'package:openfit/services/user_profile_loader.dart';
import 'package:openfit/models/chat_session_meta.dart';
import 'package:openfit/models/daily_plan.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import 'dart:convert';


class ChatScreen extends StatefulWidget {
  final String sessionId;
  
  const ChatScreen({super.key, required this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatSession session;
  bool _isAnalyzing = false;
  DateTime? updatedAt;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> sessionIds = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    //_runAnalysis();
    _controller.dispose();
    _scrollController.dispose();
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

    final metaBox = await Hive.openBox<ChatSessionMeta>('sessionMeta');
    final metaList = metaBox.values.cast<ChatSessionMeta>().where(
      (m) => m.sessionId == widget.sessionId,
    ).toList();

    setState(() {
      sessionIds = ids;
      if (metaList.isNotEmpty) {
        updatedAt = metaList.first.updatedAt;
      }
    });
}


  void _sendMessage(String text) async {
    if (_isProcessing || text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _controller.clear();
    });

    final userMsg = ChatMessage(role: 'user', content: text);
    final loadingMsg = ChatMessage(role: 'assistant', content: '');

    final userIndex = await session.addMessage(userMsg, context);
    final assistantIndex = await session.addMessage(loadingMsg, context);
    setState(() {});

    try {
      final client = await createGPTClientFromProfile();
      final history = session.toGptMessages();
      final profilePrompt = await loadUserProfileAsPrompt();

      final fullReply = await _fetchFullReply(client, history, profilePrompt);
      await _simulateTyping(assistantIndex, fullReply);

    } catch (e) {
      await session.updateMessage(
        assistantIndex,
        ChatMessage(role: 'assistant', content: '오류 발생: $e'),
      );
      setState(() {});
    }

    final ids = await ChatSession.getAllSessionIds();
    setState(() {
      sessionIds = ids;
      _isProcessing = false;
    });
  }
  
  Future<void> _runAnalysis() async {
    setState(() => _isAnalyzing = true);
    try {
      final box = await Hive.openBox<ChatMessage>('chat_${widget.sessionId}');
      final messages = box.values.toList();

      
      final assistantMessages = messages.where((m) => m.role == 'assistant').toList();
      if (assistantMessages.isEmpty) {
        return;
      }
      final lastSummary = assistantMessages.last.content.trim();
      if (lastSummary.isEmpty) {
        return;
      }

      final prompt = '''
  당신은 건강 코치입니다. 아래 사용자와의 대화 요약을 기반으로 오늘의 식단 및 운동 계획을 다음 JSON 형식으로 생성하세요:

  {
    "meal": ["예: 닭가슴살 샐러드", "단백질 쉐이크"],
    "workout": ["예: 턱걸이 3세트", "스쿼트 4세트"]
  }

  요약:
  $lastSummary

  ⚠️ JSON만 출력하세요. 자연어 설명 없이 순수 JSON만 응답해주세요.
  ''';

      final client = await createGPTClientFromProfile();
      final response = await client.sendMessageWithPrompt(prompt);
      
      if (!response.trim().startsWith('{')) {
        return;
      }

      final parsed = json.decode(response);
      final mealList = List<String>.from(parsed['meal'] ?? []);
      final workoutList = List<String>.from(parsed['workout'] ?? []);

      final planBox = await Hive.openBox<DailyPlan>('dailyPlanBox');
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      

      final existing = planBox.values.firstWhereOrNull(
        (p) => p.date == dateStr,
      );
      if (existing == null) {
        await planBox.put(dateStr, DailyPlan(
          date: dateStr,
          mealPlan: mealList,
          mealDone: List<bool>.filled(mealList.length, false),
          workoutPlan: workoutList,
          workoutDone: List<bool>.filled(workoutList.length, false),
        ));
      } else {
        existing
          ..mealPlan = mealList
          ..mealDone = List<bool>.filled(mealList.length, false)
          ..workoutPlan = workoutList
          ..workoutDone = List<bool>.filled(workoutList.length, false);
        await existing.save();
      }
    } catch (e, stack) {
      print('[❌ 분석 실패] $e\n$stack');
    }
    setState(() => _isAnalyzing = false);
  }


  Future<String> _fetchFullReply(client, List<Map<String, String>> history, String prompt) async {
    String reply = '';
    await for (final chunk in client.sendMessageWithStream(history, prompt)) {
      reply += chunk;
    }
    return reply;
  }

  Future<void> _simulateTyping(int index, String fullText) async {
    String display = '';

    for (int i = 0; i < fullText.length; i++) {
      display += fullText[i];
      await session.updateMessage(index, ChatMessage(role: 'assistant', content: display));
      setState(() {});
      _scrollToBottom();
    }

    await session.updateMessage(index, ChatMessage(role: 'assistant', content: fullText));
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.sessionId}')),
      body: Row(
        children: [
          // Session list column (왼쪽)
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
          Expanded(
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
                          enabled: !_isProcessing,
                          onSubmitted: (value) => _sendMessage(value),
                          decoration: InputDecoration(
                            hintText: _isProcessing ? 'GPT가 응답 중입니다...' : '메시지를 입력하세요',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isProcessing ? null : () => _sendMessage(_controller.text),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 250,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📊 채팅 분석', style: TextStyle(fontWeight: FontWeight.bold)),
                Divider(),
                Text('• 날짜: ${updatedAt != null ? updatedAt!.toLocal().toString().split(' ')[0] : '불러오는 중...'}'),
                Text('• 감정: 긍정적'),
                Text('• 키워드: 운동, 다이어트'),
                Text('• 요약: ...'),
                const SizedBox(height: 16), // 여백 추가
                ElevatedButton(
                  onPressed: _isAnalyzing ? null : _runAnalysis,
                  child: _isAnalyzing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('분석 중...'),
                          ],
                        )
                      : const Text('분석하기'),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
