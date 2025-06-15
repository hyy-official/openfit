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
import 'package:openfit/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  
  // Register adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(GPTContextAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(DailyPlanAdapter());
  Hive.registerAdapter(ChatSessionMetaAdapter());
  
  // 🔥 임시: 기존 데이터 클리어 (구조 변경으로 인한 호환성 문제 해결)
  try {
    await Hive.deleteBoxFromDisk('userProfileBox');
    await Hive.deleteBoxFromDisk('gptContextBox');
    print('🗑️ 기존 데이터 박스 클리어 완료 - 새로운 구조로 재시작');
  } catch (e) {
    print('⚠️ 데이터 박스 클리어 중 오류 (무시해도 됨): $e');
  }
  
  // Open boxes
  await Hive.openBox<UserProfile>('userProfileBox');
  await Hive.openBox<GPTContext>('gptContextBox');
  await Hive.openBox<ChatMessage>('chatMessages');
  await Hive.openBox<DailyPlan>('dailyPlanBox');
  await Hive.openBox<ChatSessionMeta>('sessionMeta');
  await Hive.openBox('pendingSyncBox');

  // .env 파일 로드
  await dotenv.load(fileName: ".env");
  
  // API 키 서비스 초기화
  await ApiKeyService.initialize();
  
  // PromptLayer 서비스 초기화
  await PromptLayerService().initialize();
  
  // ProfileService 전역 인스턴스 생성 및 초기화
  final profileService = ProfileService();
  await profileService.initialize();
  
  runApp(OpenFitApp(profileService: profileService));
}

class OpenFitApp extends StatelessWidget {
  final ProfileService profileService;
  
  const OpenFitApp({super.key, required this.profileService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SummaryLoader()),
        ChangeNotifierProvider.value(value: profileService), // 🔥 ProfileService 제공
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
