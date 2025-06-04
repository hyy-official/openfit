import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:openfit/l10n/app_localizations.dart';
import 'package:openfit/screens/home_screen.dart';

import 'package:openfit/models/chat_message.dart';
import 'package:openfit/models/chat_session_meta.dart';
import 'package:openfit/models/user_profile.dart';
import 'package:openfit/models/daily_plan.dart';

import 'package:openfit/services/chat_session.dart';
import 'package:openfit/services/session_list_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatSessionMetaAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(DailyPlanAdapter());
  
  await Hive.openBox<ChatSessionMeta>('sessionMeta'); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (_) => ChatSession('default')..loadMessages()),
        ChangeNotifierProvider(create: (_) => SessionListProvider()..loadSessions()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ko'),
        ],
        locale: const Locale('ko'),
        home: const HomeScreen(),
      ),
    );
  }
}
