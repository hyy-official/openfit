import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/models/gpt_context.dart';
import 'package:openfit/models/user_profile.dart';
import 'package:openfit/services/chat_session.dart';
import 'package:openfit/models/chat_session_meta.dart';
import 'package:openfit/models/daily_plan.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:openfit/services/prompt_layer_service.dart';
import 'package:openfit/services/summary_loader.dart';
import 'package:openfit/services/chat_service.dart';
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
  final _summaryLoader = SummaryLoader();
  final _promptLayer = PromptLayerService();
  final _chatService = ChatService();
  String _cumulativeHistorySummary = ''; // 누적 히스토리 요약

  @override
  void dispose() {
    //_runAnalysis(); // dispose 시점에서의 분석 실행은 일반적으로 권장되지 않음
    _controller.dispose();
    _scrollController.dispose();
    session.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _loadProfile();
    _initializePromptLayer();
  }

  Future<void> _initializeSession() async {
    session = ChatSession(widget.sessionId);
    await session.loadMessages();

    final ids = await ChatSession.getAllSessionIds();

    // ChatSessionMeta 박스를 열어 updatedAt 값을 가져옵니다.
    final metaBox = await Hive.box<ChatSessionMeta>('sessionMeta');
    final metaList = metaBox.values.cast<ChatSessionMeta>().where(
      (m) => m.id == widget.sessionId,
    ).toList();

    if (mounted) {
      setState(() {
        sessionIds = ids;
        if (metaList.isNotEmpty) {
          updatedAt = metaList.first.updatedAt;
        }
      });
    }
}

  Future<void> _loadProfile() async {
    await _summaryLoader.loadData();
    
    // GPTContext에서 히스토리 요약 로드
    final gptContext = _summaryLoader.gptContext;
    if (gptContext?.historySummary != null && gptContext!.historySummary!.trim().isNotEmpty) {
      _cumulativeHistorySummary = gptContext.historySummary!;
      print('📚 GPTContext에서 히스토리 요약 로드: $_cumulativeHistorySummary');
    }
  }

  Future<void> _initializePromptLayer() async {
    await _promptLayer.initialize();
  }

  Future<String> _fetchFullReply(List<Map<String, String>> history, String prompt) async {
    print('📝 프롬프트 전송 시작');
    print('프롬프트 내용: $prompt');
    print('히스토리: $history');

    String fullReply = '';
    try {
      await for (final chunk in _chatService.sendMessageWithStream(history, prompt)) {
        print('📦 응답 청크 수신: $chunk');
        fullReply += chunk;
      }
      print('✅ 전체 응답 수신 완료: $fullReply');
      return fullReply;
    } catch (e) {
      print('❌ 응답 수신 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<void> _simulateTyping(int messageIndex, String fullReply) async {
    print('⌨️ 타이핑 시뮬레이션 시작');
    print('메시지 인덱스: $messageIndex');
    print('전체 응답: $fullReply');

    try {
      // JSON 부분과 메시지 부분 분리
      String messageContent = fullReply;
      Map<String, dynamic>? profileUpdate;
      
      // JSON 부분 찾기
      final jsonStart = fullReply.indexOf('{');
      final jsonEnd = fullReply.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonStart < jsonEnd) {
        try {
          final jsonStr = fullReply.substring(jsonStart, jsonEnd + 1);
          print('파싱할 JSON 문자열: $jsonStr');
          
          final response = json.decode(jsonStr) as Map<String, dynamic>;
          
          // message와 profile_update 분리
          if (response.containsKey('message')) {
            messageContent = response['message'] as String;
            print('추출된 메시지: $messageContent');
          }
          if (response.containsKey('profile_update')) {
            profileUpdate = response['profile_update'] as Map<String, dynamic>;
            print('추출된 프로필 업데이트: $profileUpdate');
          }
        } catch (e) {
          print('JSON 파싱 실패: $e');
          // JSON 파싱 실패 시 전체 응답을 메시지로 사용
          messageContent = fullReply;
        }
      }

      // 메시지 업데이트
      final message = session.messages[messageIndex];
      final updatedMessage = ChatMessage(role: message.role, content: messageContent);
      await session.updateMessage(messageIndex, updatedMessage);

      // 프로필 업데이트가 있다면 처리
      if (profileUpdate != null) {
        await _updateUserProfile(profileUpdate);
      }

      print('✅ 메시지 업데이트 완료');
    } catch (e) {
      print('❌ 메시지 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<void> _updateHistorySummary(String newSummary) async {
    try {
      if (newSummary.trim().isNotEmpty) {
        final gptContext = _summaryLoader.gptContext;
        if (gptContext == null) {
          print('❌ GPTContext가 null입니다.');
          return;
        }

        // 기존 요약과 새 요약을 결합
        String updatedSummary;
        if (gptContext.historySummary == null || gptContext.historySummary!.trim().isEmpty) {
          updatedSummary = newSummary;
        } else {
          updatedSummary = '${gptContext.historySummary}\n$newSummary';
        }

        // GPTContext 업데이트
        gptContext.historySummary = updatedSummary;
        
        // Hive에 저장
        final box = await Hive.box<GPTContext>('gptContextBox');
        await box.put('userProfile', gptContext);
        
        // 메모리 변수도 동기화
        _cumulativeHistorySummary = updatedSummary;
        
        print('✅ 히스토리 요약 업데이트: $newSummary');
        print('📚 GPTContext에 저장된 누적 요약: $updatedSummary');
      }
    } catch (e) {
      print('❌ 히스토리 요약 업데이트 중 오류 발생: $e');
    }
  }

  Future<void> _updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final gptContext = _summaryLoader.gptContext;
      if (gptContext == null) {
        print('❌ GPTContext가 null입니다.');
        return;
      }

      bool hasUpdates = false;
      String updateMessage = '';

      // GPTContext 업데이트
      if (updates.containsKey('weight')) {
        gptContext.weight = updates['weight'] as double;
        hasUpdates = true;
        updateMessage += '체중: ${gptContext.weight}kg\n';
      }
      if (updates.containsKey('bodyFat')) {
        gptContext.bodyFat = updates['bodyFat'] as double;
        hasUpdates = true;
        updateMessage += '체지방률: ${gptContext.bodyFat}%\n';
      }
      if (updates.containsKey('targetBodyFat')) {
        gptContext.targetBodyFat = updates['targetBodyFat'] as double;
        hasUpdates = true;
        updateMessage += '목표 체지방률: ${gptContext.targetBodyFat}%\n';
      }
      if (updates.containsKey('targetMuscleMass')) {
        gptContext.targetMuscleMass = updates['targetMuscleMass'] as double;
        hasUpdates = true;
        updateMessage += '목표 근육량: ${gptContext.targetMuscleMass}kg\n';
      }
      if (updates.containsKey('sleepHabits')) {
        gptContext.sleepHabits = updates['sleepHabits'] as String;
        hasUpdates = true;
        updateMessage += '수면 습관: ${gptContext.sleepHabits}\n';
      }
      if (updates.containsKey('medications')) {
        gptContext.medications = List<String>.from(updates['medications']);
        hasUpdates = true;
        updateMessage += '복용 중인 약: ${gptContext.medications?.join(', ')}\n';
      }
      if (updates.containsKey('availableIngredients')) {
        gptContext.availableIngredients = List<String>.from(updates['availableIngredients']);
        hasUpdates = true;
        updateMessage += '가용 식재료: ${gptContext.availableIngredients?.join(', ')}\n';
      }
      if (updates.containsKey('activityLevel')) {
        gptContext.activityLevel = updates['activityLevel'] as String;
        hasUpdates = true;
        updateMessage += '활동 수준: ${gptContext.activityLevel}\n';
      }
      if (updates.containsKey('availableWorkoutTime')) {
        gptContext.availableWorkoutTime = updates['availableWorkoutTime'] as String;
        hasUpdates = true;
        updateMessage += '운동 가능 시간: ${gptContext.availableWorkoutTime}\n';
      }
      if (updates.containsKey('dietaryRestrictions')) {
        gptContext.dietaryRestrictions = updates['dietaryRestrictions'] as String;
        hasUpdates = true;
        updateMessage += '식이 제한: ${gptContext.dietaryRestrictions}\n';
      }
      if (updates.containsKey('historySummary')) {
        gptContext.historySummary = updates['historySummary'] as String;
        hasUpdates = true;
        updateMessage += '대화 히스토리 요약이 업데이트되었습니다.\n';
        // 메모리 변수도 동기화
        _cumulativeHistorySummary = gptContext.historySummary!;
      }

      if (hasUpdates) {
        // Hive에 저장
        final box = await Hive.box<GPTContext>('gptContextBox');  
        await box.put('userProfile', gptContext);
        
        print('✅ 프로필 업데이트 완료: $updates');
        print('업데이트 메시지: $updateMessage');

        // 스낵바로 알림
        if (mounted) {
          print('스낵바 표시 시도');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('프로필이 업데이트되었습니다:\n$updateMessage'),
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(8),
              action: SnackBarAction(
                label: '확인',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
          print('스낵바 표시 완료');
        } else {
          print('❌ mounted가 false입니다.');
        }
      } else {
        print('❌ 업데이트된 내용이 없습니다.');
      }
    } catch (e) {
      print('❌ 프로필 업데이트 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 업데이트 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    if (_isProcessing || text.trim().isEmpty) return;

    print('📤 메시지 전송 시작');
    print('전송할 메시지: $text');

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _controller.clear();
      });
    }

    final userMsg = ChatMessage(role: 'user', content: text);
    final loadingMsg = ChatMessage(role: 'assistant', content: ''); 

    print('💬 메시지 저장 시작');
    final userIndex = await session.addMessage(userMsg);
    final assistantIndex = await session.addMessage(loadingMsg); 
    print('✅ 메시지 저장 완료');
    print('사용자 메시지 인덱스: $userIndex');
    print('어시스턴트 메시지 인덱스: $assistantIndex');

    if (mounted) setState(() {});

    try {
      final history = session.toGptMessages();
      final gptContext = _summaryLoader.gptContext;
      
      print('📝 프롬프트 준비 시작');
      final basePrompt = _promptLayer.promptTemplates['health_coach'] ?? '';
      final allSessionIds = await ChatSession.getAllSessionIds();
      final otherSessionExists = allSessionIds.where((id) => id != widget.sessionId).isNotEmpty;
      final profilePrompt = await _summaryLoader.loadSummariesAsPrompt(forceUserProfile: !otherSessionExists);
      
      // 시스템 프롬프트 구성
      String systemPrompt = '$basePrompt\n$profilePrompt';
      
      // 현재 히스토리 요약 상태를 사용자 입력에 포함
      final currentHistorySummary = gptContext?.historySummary ?? _cumulativeHistorySummary;
      String enhancedUserInput = text;
      if (currentHistorySummary.trim().isNotEmpty) {
        enhancedUserInput = '현재 요약된 히스토리: "$currentHistorySummary"\n\n사용자 입력: $text';
      }
      
      print('📝 시스템 프롬프트: $systemPrompt');
      print('📝 강화된 사용자 입력: $enhancedUserInput');
      print('📚 히스토리: $history');
      // 히스토리를 포함한 응답 받기 (시스템 프롬프트와 사용자 입력 분리)
      final response = await _chatService.getResponse(enhancedUserInput, gptContext, history: history, systemPrompt: systemPrompt);
      print('✅ GPT 응답 수신 완료');

      // JSON 응답 파싱 시도
      try {
        final jsonResponse = json.decode(response);
        if (jsonResponse is Map<String, dynamic>) {
          // 프로필 업데이트 처리
          if (jsonResponse.containsKey('profile_update')) {
            await _updateUserProfile(jsonResponse['profile_update']);
          }
          
          // 히스토리 요약 처리
          if (jsonResponse.containsKey('history_summary')) {
            await _updateHistorySummary(jsonResponse['history_summary']);
          }
          
          // 메시지 부분만 표시
          final messageContent = jsonResponse['message'] ?? response;
          await _simulateTyping(assistantIndex, messageContent);
        } else {
          await _simulateTyping(assistantIndex, response);
        }
      } catch (e) {
        // JSON 파싱 실패 시 전체 응답을 메시지로 처리
        await _simulateTyping(assistantIndex, response);
      }

    } catch (e) {
      print('❌ 메시지 전송 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 전송 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
      }
    } finally {
    if (mounted) {
      setState(() {
          _isProcessing = false;
      });
      }
    }
  }
  
  Future<void> _runAnalysis() async {
    if (mounted) setState(() => _isAnalyzing = true);
    try {
      final box = await Hive.openBox<ChatMessage>('chat_${widget.sessionId}');
      final messages = box.values.toList();
      
      final assistantMessages = messages.where((m) => m.role == 'assistant').toList();
      if (assistantMessages.isEmpty) {
        print('[⚠️ 분석 중단] 어시스턴트 메시지가 없습니다.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석할 GPT 응답이 없습니다. 먼저 대화를 나눠주세요.')),
          );
        }
        if (mounted) setState(() => _isAnalyzing = false);
        return;
      }
      
      // 비어있지 않은 마지막 어시스턴트 메시지를 찾습니다.
      final lastNotEmptyAssistantMessage = assistantMessages.lastWhereOrNull((m) => m.content.trim().isNotEmpty);
      
      if (lastNotEmptyAssistantMessage == null) {
        print('[⚠️ 분석 중단] 유효한 마지막 어시스턴트 메시지가 없습니다.');
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('분석할 내용이 충분하지 않습니다. GPT와 대화를 더 나눠주세요.')),
            );
          }
        if (mounted) setState(() => _isAnalyzing = false);
        return;
      }
      final lastSummary = lastNotEmptyAssistantMessage.content.trim();

      // GPT에 전달할 프롬프트 수정 (칼로리 정보 요청 추가)
      final prompt = '''
사용자와의 이전 대화 요약입니다:
"$lastSummary"

이 요약을 바탕으로 사용자의 식단(meal)과 운동(workout) 계획을 JSON 형식으로 제안해주세요.
각 식단 항목에는 "name" (음식 이름, 문자열)과 "calories" (칼로리, 정수)를 포함해야 합니다.
각 운동 항목에는 "name" (운동 이름, 문자열)과 "calories_burned" (소모 칼로리, 정수)를 포함해야 합니다.

JSON 응답 형식의 예시입니다:
{
  "meal": [
    {"name": "닭가슴살 샐러드", "calories": 350},
    {"name": "사과 1개", "calories": 95},
    {"name": "현미밥 1공기", "calories": 300}
  ],
  "workout": [
    {"name": "30분 달리기", "calories_burned": 300},
    {"name": "15분 근력 운동", "calories_burned": 150}
  ]
}

분석된 계획을 위의 JSON 형식으로만 응답해주세요. 다른 설명이나 추가 텍스트 없이 JSON 객체만 반환해야 합니다.
''';

      final client = await _chatService.createGPTClientFromProfile();
      final response = await client.sendMessageWithPrompt(prompt); // stream 대신 일반 요청 사용
      
      // 응답이 유효한 JSON 형태인지 더 확실하게 확인
      if (response.trim().isEmpty || !response.trim().startsWith('{') || !response.trim().endsWith('}')) {
        print('[❌ 분석 실패] 응답이 유효한 JSON 형식이 아닙니다: $response');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석 결과를 가져오는데 실패했습니다. (응답 형식 오류)')),
          );
        }
        if (mounted) setState(() => _isAnalyzing = false);
        return;
      }

      final Map<String, dynamic> parsed;
      try {
        parsed = json.decode(response) as Map<String, dynamic>;
      } catch (e) {
        print('[❌ 분석 실패] JSON 파싱 오류: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석 결과를 처리하는데 실패했습니다. (파싱 오류)')),
          );
        }
        if (mounted) setState(() => _isAnalyzing = false);
        return;
      }
      
      // meal 데이터 파싱 (이름 및 칼로리)
      final List<dynamic> mealDataRaw = parsed['meal'] as List<dynamic>? ?? [];
      final List<String> mealList = [];
      final List<double> mealCalList = [];
      for (var item in mealDataRaw) {
        if (item is Map<String, dynamic>) {
          mealList.add(item['name'] as String? ?? '알 수 없는 음식');
          mealCalList.add((item['calories'] as num?)?.toDouble() ?? 0.0);
        }
      }

      // workout 데이터 파싱 (이름 및 칼로리)
      final List<dynamic> workoutDataRaw = parsed['workout'] as List<dynamic>? ?? [];
      final List<String> workoutList = [];
      final List<double> workoutCalList = [];
      for (var item in workoutDataRaw) {
        if (item is Map<String, dynamic>) {
          workoutList.add(item['name'] as String? ?? '알 수 없는 운동');
          workoutCalList.add((item['calories_burned'] as num?)?.toDouble() ?? 0.0);
        }
      }

      final planBox = await Hive.box<DailyPlan>('dailyPlanBox');
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final existing = planBox.values.firstWhereOrNull(
        (p) => p.date == dateStr,
      );

      if (existing == null) {
        await planBox.put(dateStr, DailyPlan(
          date: dateStr,
          mealPlan: mealList,
          mealCalories: mealCalList,
          mealDone: List<bool>.filled(mealList.length, false),
          workoutPlan: workoutList,
          workoutCalories: workoutCalList,
          workoutDone: List<bool>.filled(workoutList.length, false),
          notes: '',
        ));
        print('[✨ 분석 완료] 새로운 일일 계획 저장: $dateStr');
      } else {
        final updated = DailyPlan(
          date: existing.date,
          mealPlan: mealList,
          mealCalories: mealCalList,
          mealDone: List<bool>.filled(mealList.length, false),
          workoutPlan: workoutList,
          workoutCalories: workoutCalList,
          workoutDone: List<bool>.filled(workoutList.length, false),
          notes: existing.notes,
        );
        await planBox.put(dateStr, updated);
        print('[✨ 분석 완료] 기존 일일 계획 업데이트: $dateStr');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅 분석이 완료되어 계획이 업데이트되었습니다!')),
        );
      }
    } catch (e, stack) {
      print('[❌ 분석 실패] $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
        );
      }
    }
    if (mounted) setState(() => _isAnalyzing = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
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
      appBar: AppBar(
        title: Text(updatedAt != null 
            ? '채팅 (${DateFormat('yy/MM/dd HH:mm').format(updatedAt!)})' 
            : 'Chat - ${widget.sessionId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeSession, // 세션 정보 새로고침 기능
            tooltip: '세션 정보 새로고침',
          )
        ],
      ),
      body: Row(
        children: [
          // Session list column (왼쪽)
          Container(
            width: 200,
            color: Colors.grey[200],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('📁 이전 채팅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: '새 채팅 시작',
                        onPressed: () async {
                          final newSessionId = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                           Navigator.pushReplacement(
                             context,
                             //MaterialPageRoute(builder: (_) => ChatScreen(sessionId: newSessionId)),
                             PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(sessionId: newSessionId),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return child; // 애니메이션 없이 바로 전환
                                          },
                                        ),
                           );
                        },
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder( // ListView.builder로 변경하여 스크롤 가능하게
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: sessionIds.length,
                    itemBuilder: (context, index) {
                      final id = sessionIds[index];
                      // 현재 세션의 메타데이터를 찾아 업데이트 시간 표시 (선택적)
                      // 이 부분은 성능에 영향을 줄 수 있으므로, 필요시 최적화 (예: Map으로 변환)
                      // String sessionDisplayTitle = 'Session $id';
                      // final metaBox = Hive.box<ChatSessionMeta>('sessionMeta');
                      // final currentMeta = metaBox.values.firstWhereOrNull((m) => m.sessionId == id);
                      // if (currentMeta != null) {
                      //   sessionDisplayTitle = DateFormat('MM/dd HH:mm').format(currentMeta.updatedAt);
                      // }

                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '채팅 $id', // 간단하게 표시 또는 날짜 기반으로 변경
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: id == widget.sessionId ? FontWeight.bold : FontWeight.normal,
                                  color: id == widget.sessionId ? Theme.of(context).primaryColor : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                              tooltip: '세션 삭제',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('세션 삭제'),
                                    content: Text('정말로 세션 "$id"를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ChatSession.deleteSession(id);
                                  final updatedIds = await ChatSession.getAllSessionIds();
                                  if (mounted) {
                                    setState(() {
                                      sessionIds = updatedIds;
                                    });
                                  }

                                  if (id == widget.sessionId) { // 현재 보고 있는 세션이 삭제된 경우
                                    if (updatedIds.isNotEmpty) {
                                      // 다른 세션이 있으면 가장 최근 또는 첫 번째 세션으로 이동
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(sessionId: updatedIds.first),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return child; // 애니메이션 없이 즉시 전환
                                          },
                                        ),
                                      );
                                    } else {
                                      // 모든 세션이 삭제되었으면 새 기본 세션으로 이동
                                      final newSessionId = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(sessionId: newSessionId),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return child;
                                          },
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        selected: id == widget.sessionId,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        onTap: () {
                          if (id != widget.sessionId) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(sessionId: id),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return child;
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3, // 채팅창 영역을 조금 더 넓게
            child: Column(
              children: [
                Expanded(
                  child: session.messages.isEmpty
                      ? Center(
                          child: Text(
                            '${widget.sessionId} 채팅을 시작하세요!',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: session.messages.length,
                          itemBuilder: (context, index) {
                            final msg = session.messages[index];
                            bool isUser = msg.role == 'user';
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6), // 메시지 최대 너비 제한
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isUser ? Theme.of(context).primaryColor : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                                    bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                ),
                                child: msg.content.trim().isEmpty && msg.role == 'assistant' && _isProcessing && index == session.messages.length -1
                                  ? const SizedBox(
                                      width: 20, height: 20, 
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white70))
                                    )
                                  : Text(
                                      msg.content,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), // 패딩 조정
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !_isProcessing,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _sendMessage(value);
                            }
                          },
                          onEditingComplete: () {
                            if (_controller.text.trim().isNotEmpty) {
                              _sendMessage(_controller.text);
                            }
                          },
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            // 커맨드(또는 컨트롤) + 엔터를 감지하기 위해 RawKeyboardListener를 사용할 수 있지만,
                            // 여기서는 단순히 onSubmitted와 onEditingComplete를 통해 처리합니다.
                          },
                          decoration: InputDecoration(
                            hintText: _isProcessing ? 'GPT가 응답을 생성 중입니다...' : '메시지를 입력하세요...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          minLines: 1,
                          maxLines: 5, // 여러 줄 입력 가능
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded),
                        iconSize: 28,
                        color: Theme.of(context).primaryColor,
                        tooltip: '메시지 전송',
                        onPressed: _isProcessing ? null : () => _sendMessage(_controller.text),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 분석 패널 (오른쪽)
          Container(
            width: 280, // 너비 약간 증가
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!))
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 채팅 분석 및 계획', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                const Divider(height: 20),
                Text(' • 세션 최종 업데이트:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('   ${updatedAt != null ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(updatedAt!.toLocal()) : '정보 없음'}', style: TextStyle(fontSize: 13)),

                const SizedBox(height: 16),
                // 아래는 예시이며, 실제 DailyPlan 데이터를 불러와 표시해야 합니다.
                Text(' • 오늘의 감정 (예시):', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('   긍정적 😊', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text(' • 주요 키워드 (예시):', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('   운동, 다이어트, 식단 관리', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text(' • GPT 요약 (예시):', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('   사용자는 체중 감량과 건강한 생활 습관 형성에 관심이 많으며, 구체적인 운동 및 식단 계획을 원하고 있습니다.', style: TextStyle(fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis,),
                const Spacer(), // 버튼을 하단에 위치시키기 위해 Spacer 추가
                
                ElevatedButton.icon(
                  icon: _isAnalyzing 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Icon(Icons.insights_rounded, size: 20),
                  label: Text(_isAnalyzing ? '분석 진행 중...' : '현재 채팅 분석 실행', style: TextStyle(fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark, // primaryColor 대신
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // 버튼 크기
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: (_isProcessing || _isAnalyzing) ? null : _runAnalysis, // 메시지 처리 중에도 비활성화
                ),
                const SizedBox(height: 8),
                Text(
                  '분석 실행 시, 현재 채팅의 마지막 GPT 답변을 기반으로 식단 및 운동 계획을 생성하여 저장합니다.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}