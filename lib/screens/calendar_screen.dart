// calendar_screen.dart (운동/식단 통합 - Divider로 분리)
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfit/models/daily_plan.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  Box<DailyPlan>? _planBox;
  DailyPlan? _plan;

  @override
  void initState() {
    super.initState();
    _initBoxAndLoad();
  }

  Future<void> _initBoxAndLoad() async {
    if (!Hive.isBoxOpen('dailyPlanBox')) {
      await Hive.openBox<DailyPlan>('dailyPlanBox');
    }
    _planBox = Hive.box<DailyPlan>('dailyPlanBox');
    _loadPlanForDay(_selectedDay);
  }

  void _loadPlanForDay(DateTime date) {
    if (_planBox == null) return;
    final key = DateFormat('yyyy-MM-dd').format(date);
    final plan = _planBox!.get(key);
    setState(() => _plan = plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                AppBar(title: const Text('📅 건강 캘린더')),
                TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime(2023),
                  lastDay: DateTime(2030),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, _) {
                    setState(() => _selectedDay = selected);
                    _loadPlanForDay(selected);
                  },
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildCombinedView(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCombinedView() {
    if (_plan == null) return const Center(child: Text('오늘은 등록된 건강 플랜이 없습니다.'));

    return ListView(
      children: [
        ExpansionTile(
          title: const Text('🏋️ 운동 계획', style: TextStyle(fontWeight: FontWeight.bold)),
          children: List.generate(_plan!.workoutPlan.length, (i) {
            return CheckboxListTile(
              title: Text(_plan!.workoutPlan[i]),
              value: _plan!.workoutDone[i],
              onChanged: (val) {
                setState(() {
                  _plan!.workoutDone[i] = val!;
                  _plan!.save();
                });
              },
            );
          }),
        ),
        ExpansionTile(
          title: const Text('🥗 식단 계획', style: TextStyle(fontWeight: FontWeight.bold)),
          children: List.generate(_plan!.mealPlan.length, (i) {
            return CheckboxListTile(
              title: Text(_plan!.mealPlan[i]),
              value: _plan!.mealDone[i],
              onChanged: (val) {
                setState(() {
                  _plan!.mealDone[i] = val!;
                  _plan!.save();
                });
              },
            );
          }),
        ),
      ],
    );
  }
}