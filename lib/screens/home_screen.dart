// home_screen.dart (사이드바 유지 + 본문 전환 방식 적용)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfit/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openfit/screens/chat_screen.dart';
import 'package:openfit/screens/calendar_screen.dart';
import 'package:openfit/screens/user_settings_sheet.dart';

enum HomeContentView { dashboard, calendar }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeContentView selectedView = HomeContentView.dashboard;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final userName = "홍윤영";
    final todayDate = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // 좌측 고정 네비게이션
          Container(
            width: 250,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.explore, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                menuItem(t.menuFitness),
                menuItem(t.menuNutrition),
                menuItem(t.menuWeight, onTap: () {
                  setState(() {
                    selectedView = HomeContentView.calendar;
                  });
                }),
                menuItem(t.menuChat, onTap: () {
                  final sessionId = 'session_\${DateTime.now().millisecondsSinceEpoch}';
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
                menuItem(t.personal, onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: const UserSettingsSheet(),
                    ),
                  );
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

          // 우측 콘텐츠 영역 (상태에 따라 달라짐)
          Expanded(
            child: Builder(
              builder: (_) {
                switch (selectedView) {
                  case HomeContentView.calendar:
                    return const CalendarScreen();
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
}