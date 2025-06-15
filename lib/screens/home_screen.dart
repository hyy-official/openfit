// home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfit/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openfit/screens/chat_screen.dart';
import 'package:openfit/screens/calendar_screen.dart';
import 'package:openfit/screens/user_settings_sheet.dart'; // Make sure this import is correct
import 'package:openfit/models/user_profile.dart';
import 'package:hive/hive.dart';

// Add userSettings to your enum
enum HomeContentView { dashboard, calendar, userSettings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeContentView selectedView = HomeContentView.dashboard;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final userName = "홍윤영";
    final todayDate = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Left Fixed Navigation
          Container(
            width: 250,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t?.explore ?? "탐색", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                menuItem(t?.menuFitness ?? "피트니스"),
                menuItem(t?.menuNutrition ?? "영양"),
                menuItem(t?.menuCalender ?? "캘린더", onTap: () async {
                  final box = Hive.box<UserProfile>('userProfileBox');
                  final profile = box.get('userProfile');
                  if (!isProfileValid(profile)) {
                    setState(() {
                      selectedView = HomeContentView.userSettings;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 유저 프로필(이름, 나이, 키, 체중, 목표체중)을 모두 입력해주세요!')),
                    );
                    return;
                  }
                  setState(() {
                    selectedView = HomeContentView.calendar;
                  });
                }),
                menuItem(t?.menuChat ?? "채팅", onTap: () async {
                  final box = Hive.box<UserProfile>('userProfileBox');
                  final profile = box.get('userProfile');
                  //여기까진 문제 없음
                  if (!isProfileValid(profile)) {
                    setState(() {
                      selectedView = HomeContentView.userSettings;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 유저 프로필(이름, 나이, 키, 체중, 목표체중)을 모두 입력해주세요!')),
                    );
                    return;
                  }
                  final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
                  // 홈스크린에서 새 채팅 시작 시만 커스텀 애니메이션 적용
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(sessionId: sessionId),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                }),
                menuItem(t?.personal ?? "개인설정", onTap: () {
                  setState(() {
                    selectedView = HomeContentView.userSettings;
                  });
                }),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("AI 상담 시작하기"),
                )
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // Right Content Area (changes based on state)
          Expanded(
            child: Builder(
              builder: (_) {
                switch (selectedView) {
                  case HomeContentView.calendar:
                    return const CalendarScreen();
                  case HomeContentView.userSettings: // New case for UserSettingsSheet
                    return const UserSettingsSheet();
                  case HomeContentView.dashboard:
                  default:
                    return const Center(
                      child: Text("오른쪽에 메인 콘텐츠가 들어갑니다.", style: TextStyle(color: Colors.white)),
                    );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget menuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // 유저 프로필 필수 입력값 체크 함수
  bool isProfileValid(UserProfile? profile) {
    if (profile == null) return false;
    if (profile.name == null || profile.name!.isEmpty) return false;
    if (profile.age == null || profile.age == 0) return false;
    if (profile.height == null || profile.height == 0) return false;
    if (profile.weight == null || profile.weight == 0) return false;
    if (profile.targetWeight == null || profile.targetWeight == 0) return false;
    return true;
  }
}