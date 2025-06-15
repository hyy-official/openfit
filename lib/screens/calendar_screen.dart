// calendar_screen.dart (운동/식단 통합 - Divider로 분리)
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfit/models/daily_plan.dart'; // DailyPlan 모델 임포트
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

  // Hive 박스를 초기화하고 선택된 날짜의 플랜을 로드합니다.
  Future<void> _initBoxAndLoad() async {
    // 'dailyPlanBox'가 아직 열려있지 않다면 엽니다.
    _planBox = Hive.box<DailyPlan>('dailyPlanBox');
    _loadPlanForDay(_selectedDay);
  }

  // 특정 날짜의 플랜을 로드하여 상태를 업데이트합니다.
  void _loadPlanForDay(DateTime date) {
    if (_planBox == null) return; // 박스가 초기화되지 않았다면 함수를 종료합니다.
    final key = DateFormat('yyyy-MM-dd').format(date); // 날짜를 키 형식으로 변환합니다.
    final plan = _planBox!.get(key); // 해당 키로 플랜을 가져옵니다.
    setState(() => _plan = plan); // 플랜을 상태에 설정하여 UI를 업데이트합니다.
  }

  // 선택된 날짜의 총 칼로리를 계산합니다.
  // 식단 칼로리 합계에서 운동으로 소모된 칼로리를 뺀 순 칼로리를 반환합니다.
  int _getTotalCalories() {
    if (_plan == null) return 0;

    double totalMealCalories = 0;
    for (int i = 0; i < _plan!.mealPlan.length; i++) {
      if (i < _plan!.mealCalories.length && _plan!.mealDone[i]) { // 완료된 식단만 계산
        totalMealCalories += _plan!.mealCalories[i];
      }
    }

    double totalWorkoutCaloriesBurned = 0;
    for (int i = 0; i < _plan!.workoutPlan.length; i++) {
      if (i < _plan!.workoutCalories.length && _plan!.workoutDone[i]) { // 완료된 운동만 계산
        totalWorkoutCaloriesBurned += _plan!.workoutCalories[i];
      }
    }
    // 식단 칼로리에서 운동으로 소모된 칼로리를 뺍니다.
    return (totalMealCalories - totalWorkoutCaloriesBurned).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // 캘린더 영역 (왼쪽)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                AppBar(
                  title: const Text('📅 건강 캘린더', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime(2023),
                  lastDay: DateTime(2030),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                    });
                    _loadPlanForDay(selected); // 선택된 날짜에 따라 플랜을 다시 로드합니다.
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    // 요일 텍스트 스타일
                    weekendTextStyle: TextStyle(color: Colors.red[400]),
                    holidayTextStyle: TextStyle(color: Colors.red[400]),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // '2주', '월' 버튼 숨기기
                    titleCentered: true,
                    titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    // leftMakersAutoVisibilityThreshold: 1, // 이전 달/다음 달 이동 버튼 자동 숨김 비활성화
                    // rightMakersAutoVisibilityThreshold: 1,
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[300]), // 캘린더와 플랜 뷰 사이 구분선
          // 운동/식단 통합 뷰 (오른쪽)
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

  // 운동 및 식단 계획을 표시하는 통합 뷰를 구성합니다.
  Widget _buildCombinedView() {
    // 선택된 날짜에 플랜이 없으면 안내 메시지를 표시합니다.
    if (_plan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              '${DateFormat('yyyy년 MM월 dd일').format(_selectedDay)}\n오늘은 등록된 건강 플랜이 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 채팅 화면으로 이동하는 로직 추가 또는 플랜 추가 UI 제공
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('채팅 화면에서 GPT와 대화하여 플랜을 생성해보세요!')),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('GPT와 플랜 만들기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      );
    }

    return ListView(
      children: [
        // 오늘의 총 칼로리 요약 카드
        Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('yyyy년 MM월 dd일').format(_selectedDay)} 요약',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Divider(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('순 칼로리:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                      '${_getTotalCalories()} kcal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTotalCalories() < 0 ? Colors.green : Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getTotalCalories() < 0
                      ? '오늘은 운동으로 더 많은 칼로리를 소모했어요! 🏃‍♀️'
                      : '오늘의 섭취 칼로리는 ${_getTotalCalories()} kcal 입니다. 💪',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        
        // 운동 계획 섹션
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: true, // 기본적으로 확장된 상태
            title: const Text('🏋️ 운동 계획', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            children: List.generate(_plan!.workoutPlan.length, (i) {
              return CheckboxListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(_plan!.workoutPlan[i], style: const TextStyle(fontSize: 15))),
                    if (i < _plan!.workoutCalories.length) // 칼로리 정보가 있을 경우 표시
                      Text(
                        '${_plan!.workoutCalories[i]} kcal 소모',
                        style: TextStyle(fontSize: 13, color: Colors.green[700], fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                value: _plan!.workoutDone[i],
                onChanged: (val) {
                  setState(() {
                    _plan!.workoutDone[i] = val!;
                    _plan!.save(); // Hive에 변경사항 저장
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // 체크박스를 왼쪽에 배치
              );
            }),
          ),
        ),

        // 식단 계획 섹션
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: true, // 기본적으로 확장된 상태
            title: const Text('🥗 식단 계획', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            children: List.generate(_plan!.mealPlan.length, (i) {
              return CheckboxListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(_plan!.mealPlan[i], style: const TextStyle(fontSize: 15))),
                    if (i < _plan!.mealCalories.length) // 칼로리 정보가 있을 경우 표시
                      Text(
                        '${_plan!.mealCalories[i]} kcal',
                        style: TextStyle(fontSize: 13, color: Colors.orange[700], fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                value: _plan!.mealDone[i],
                onChanged: (val) {
                  setState(() {
                    _plan!.mealDone[i] = val!;
                    _plan!.save(); // Hive에 변경사항 저장
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // 체크박스를 왼쪽에 배치
              );
            }),
          ),
        ),
      ],
    );
  }
}
