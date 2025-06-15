import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfit/models/chat_message.dart';
import 'package:openfit/models/chat_session_meta.dart';
import 'package:openfit/models/daily_plan.dart';
import 'package:openfit/models/user_profile.dart';
import 'package:openfit/models/gpt_context.dart';
import 'package:openfit/screens/home_screen.dart';
import 'package:openfit/screens/chat_screen.dart';
import 'package:openfit/screens/calendar_screen.dart';
import 'package:openfit/screens/user_settings_sheet.dart';
import 'package:openfit/services/api_key_service.dart';
import 'package:openfit/services/prompt_layer_service.dart';
import 'package:openfit/services/summary_loader.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env 파일 로드
  await dotenv.load(fileName: ".env");
  
  // Hive 초기화
  await Hive.initFlutter();
  
  // // // 개발용: 모든 박스 삭제 (기존 데이터 완전 초기화)
  // await Hive.deleteBoxFromDisk('chat_messages');
  // await Hive.deleteBoxFromDisk('sessionMeta');
  // await Hive.deleteBoxFromDisk('dailyPlans');
  // await Hive.deleteBoxFromDisk('userProfileBox');
  // await Hive.deleteBoxFromDisk('gptContextBox');
  
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatSessionMetaAdapter());
  Hive.registerAdapter(DailyPlanAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(GPTContextAdapter());

  // 박스 열기
  await Hive.openBox<ChatMessage>('chat_messages');
  await Hive.openBox<ChatSessionMeta>('sessionMeta');
  await Hive.openBox<DailyPlan>('dailyPlans');
  await Hive.openBox<UserProfile>('userProfileBox');
  await Hive.openBox<GPTContext>('gptContextBox');
  await Hive.openBox<ChatSessionMeta>('sessionMeta');
  
  // API 키 서비스 초기화
  await ApiKeyService.initialize();
  
  // PromptLayer 서비스 초기화
  await PromptLayerService().initialize();
  
  runApp(const OpenFitApp());
}

class OpenFitApp extends StatelessWidget {
  const OpenFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SummaryLoader()),
      ],
      child: MaterialApp(
        title: 'OpenFit',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/chat': (context) => const ChatScreen(sessionId: ''),
          '/calendar': (context) => const CalendarScreen(),
          '/settings': (context) => const UserSettingsSheet(),
        },
      ),
    );
  }
}

void _goToChat(BuildContext context) async {
  final box = Hive.box<UserProfile>('userProfileBox');
  final profile = box.get('userProfile');
  if (profile == null) {
    // 유저 셋팅 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserSettingsSheet()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('먼저 유저 프로필을 등록해주세요!')),
    );
    return;
  }
  Navigator.pushNamed(context, '/chat');
}
