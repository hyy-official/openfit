import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfit/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openfit/screens/chat_screen.dart';
import 'package:openfit/screens/user_settings_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final userName = "홍윤영"; // 향후 수정
    final todayDate = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Sidebar
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
                menuItem(t.menuWeight),
                menuItem(t.menuChat, onTap: (){
                    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ChatScreen(sessionId: sessionId),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(1.0, 0.0), // 오른쪽에서 슬라이드 인
                            end: Offset.zero,
                          ).animate(animation);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                    }
                  ),
                menuItem(t.personal, onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: const UserSettingsSheet(), // ← 여기 기존 폼 위젯 사용
                    ),
                  );
                }),

                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ChatScreen(sessionId: sessionId),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(1.0, 0.0), // 오른쪽에서 슬라이드 인
                            end: Offset.zero,
                          ).animate(animation);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text(t.startConsultation),
                ),
              ],
            ),
          ),

          // Main Dashboard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.helloUser(userName), style: const TextStyle(color: Colors.white, fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(t.todayDate(todayDate), style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      dashboardCard(t.recentWorkouts, "assets/workout.jpg"),
                      const SizedBox(width: 20),
                      dashboardCard(t.recentMeals, "assets/meal.jpg"),
                      const SizedBox(width: 20),
                      dashboardCard(t.weightGraph, "assets/graph.jpg"),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget menuItem(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
  
  Widget dashboardCard(String title, String imagePath) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(imagePath, height: 150, fit: BoxFit.cover),
          )
        ],
      ),
    );
  }
}
