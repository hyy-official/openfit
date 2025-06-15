// openfit/screens/user_settings_sheet.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart'; // UserProfile 모델 임포트
import 'package:openfit/models/gpt_context.dart'; // GPTContext 모델 임포트
import 'package:openfit/screens/home_screen.dart';

class UserSettingsSheet extends StatefulWidget {
  const UserSettingsSheet({super.key});

  @override
  State<UserSettingsSheet> createState() => _UserSettingsSheetState();
}

class _UserSettingsSheetState extends State<UserSettingsSheet> {
  // 기존 컨트롤러
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _goalController = TextEditingController(); // 기존 '건강 목표'
  final _dietController = TextEditingController(); // 기존 '식습관'
  final _keyController = TextEditingController();

  // 체지방과 근육량 관련 컨트롤러 추가
  final _currentMuscleMassController = TextEditingController();
  final _bodyFatMeasurementMethodController = TextEditingController();
  final _muscleMassMeasurementMethodController = TextEditingController();

  String _gender = '남성';

  // --- 추가된 컨트롤러 및 변수들 ---
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _targetBodyFatController = TextEditingController();
  final _targetMuscleMassController = TextEditingController();
  final _specificGoalEventDetailsController = TextEditingController();
  final _pushupCountController = TextEditingController();
  final _pullupCountController = TextEditingController(); // 턱걸이 선택 사항

  List<String> _fitnessGoals = [];
  List<String> _desiredBodyShapes = [];
  String _currentBodyType = '보통';
  List<String> _complexAreas = [];
  bool _hasSpecificGoalEvent = false;
  String _fitnessLevel = '초보자 (가끔 운동 시도)';
  String _weeklyWorkoutFrequency = '주 1~2회';
  String _desiredWorkoutDuration = '30~40분';
  Map<String, String> _workoutPreferences = {
    '유산소 운동': '보통이에요',
    '요가(스트레칭)': '보통이에요',
    '웨이트 트레이닝': '보통이에요',
    '턱걸이(풀업)': '보통이에요',
  };
  List<String> _usualSportsOrInterests = [];
  List<String> _preferredWorkoutLocations = [];
  List<String> _dietTypes = [];
  String _sugarIntakeFrequency = '자주 먹지 않음';
  String _waterIntake = '2~6잔';
  String _mealPrepTime = '중간 시간';
  List<String> _pastWorkoutProblems = [];
  List<String> _additionalWellnessGoals = [];
  List<String> _healthConditionsOrInjuries = [];

  // 멀티 선택 옵션 리스트 정의
  final List<String> fitnessGoalOptions = [
    '체지방 감소', '근육 증진', '체중 감량', '체력 향상', '특정 부위 강화'
  ];
  final List<String> desiredBodyShapeOptions = [
    '슬림 탄탄', '근육질 바디', '건강하고 활동적인 몸매', '특정 스포츠 바디'
  ];
  final List<String> currentBodyTypeOptions = [
    '마름', '보통', '통통함', '살집 있음'
  ];
  final List<String> complexAreaOptions = [
    '가슴', '팔', '배', '다리', '등', '엉덩이'
  ];
  final List<String> fitnessLevelOptions = [
    '초급 (일상생활 어려움)', '초보자 (가끔 운동 시도)', '고급 (꾸준히 고강도 운동 가능)'
  ];
  final List<String> weeklyWorkoutFrequencyOptions = [
    '전혀 하지 않음', '주 1~2회', '주 3회', '주 3회 이상'
  ];
  final List<String> desiredWorkoutDurationOptions = [
    '10~15분', '20~30분', '30~40분', '40~60분', '시스템에 맡기기'
  ];
  final List<String> workoutPreferenceLevels = [
    '싫어요', '보통이에요', '좋아요'
  ];
  final List<String> usualSportsOrInterestsOptions = [
    '헬스장 운동', '집에서 하는 운동', '권투', '무술', '조깅'
  ];
  final List<String> preferredWorkoutLocationOptions = [
    '집', '헬스장', '혼합'
  ];
  final List<String> dietTypeOptions = [
    '육류 제외', '모든 동물성 제품 제외 (비건)', '저탄수화물 고지방', '풍부한 식물성 식품', '없음'
  ];
  final List<String> sugarIntakeFrequencyOptions = [
    '자주 먹지 않음', '주 3~5회', '거의 매일'
  ];
  final List<String> waterIntakeOptions = [
    '2잔 미만', '2~6잔', '7~10잔', '10잔 이상', '커피/차만 마심'
  ];
  final List<String> mealPrepTimeOptions = [
    '짧은 시간 (예: 10분 미만)', '중간 시간', '충분한 시간'
  ];
  final List<String> pastWorkoutProblemOptions = [
    '동기 부족', '뚜렷한 계획 없음', '운동이 너무 힘들었음', '잘못된 코칭', '높은 콜레스테롤 수치', '부상'
  ];
  final List<String> additionalWellnessGoalOptions = [
    '수면 개선', '건강한 신체적 습관 형성', '더 건강한 기분', '스트레스 해소', '활력 증가', '신진대사 촉진'
  ];
  final List<String> healthConditionOrInjuryOptions = [
    '허리 디스크', '무릎 통증', '고혈압', '당뇨', '기타'
  ];

  // 측정 방법 옵션 추가
  final List<String> measurementMethodOptions = [
    '인바디',
    '캘리퍼',
    'DEXA',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    // 기본값 초기화 - 특히 _workoutPreferences 맵
    _workoutPreferences = {
      '유산소 운동': '보통이에요',
      '요가(스트레칭)': '보통이에요',
      '웨이트 트레이닝': '보통이에요',
      '턱걸이(풀업)': '보통이에요',
    };
    
    // 드롭다운 필드들 기본값 설정
    _currentBodyType = currentBodyTypeOptions.first;
    _fitnessLevel = fitnessLevelOptions.first;
    _weeklyWorkoutFrequency = weeklyWorkoutFrequencyOptions.first;
    _desiredWorkoutDuration = desiredWorkoutDurationOptions.first;
    _sugarIntakeFrequency = sugarIntakeFrequencyOptions.first;
    _waterIntake = waterIntakeOptions.first;
    _mealPrepTime = mealPrepTimeOptions.first;
    
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _targetWeightController.dispose();
    _targetBodyFatController.dispose();
    _targetMuscleMassController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    _dietController.dispose();
    _specificGoalEventDetailsController.dispose();
    _pushupCountController.dispose();
    _pullupCountController.dispose();
    _fitnessGoals.clear();
    _desiredBodyShapes.clear();
    _currentBodyType = '';
    _complexAreas.clear();
    _hasSpecificGoalEvent = false;
    _specificGoalEventDetailsController.text = '';
    _fitnessLevel = '';
    _weeklyWorkoutFrequency = '';
    _desiredWorkoutDuration = '';
    _workoutPreferences.clear();
    _usualSportsOrInterests.clear();
    _preferredWorkoutLocations.clear();
    _dietTypes.clear();
    _sugarIntakeFrequency = '';
    _waterIntake = '';
    _mealPrepTime = '';
    _pastWorkoutProblems.clear();
    _additionalWellnessGoals.clear();
    _healthConditionsOrInjuries.clear();
    _currentMuscleMassController.dispose();
    _bodyFatMeasurementMethodController.dispose();
    _muscleMassMeasurementMethodController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final box = Hive.box<UserProfile>('userProfileBox');
      final profile = box.get('userProfile');
      if (profile != null) {
        print('📖 프로필 로드 - 운동 목표: ${profile.fitnessGoals}');
        print('📖 프로필 로드 - 원하는 몸매: ${profile.desiredBodyShapes}');
        print('📖 프로필 로드 - 운동 취향: ${profile.workoutPreferences}');
        setState(() {
          _nameController.text = profile.name ?? '';
          _keyController.text = profile.gptKey ?? '';
          _goalController.text = profile.goal ?? '';
          _dietController.text = profile.dietHabit ?? '';
          _gender = profile.gender ?? '';
          _weightController.text = profile.weight?.toString() ?? '';
          _bodyFatController.text = profile.bodyFat?.toString() ?? '';
          _ageController.text = profile.age?.toString() ?? '';
          _heightController.text = profile.height?.toString() ?? '';
          _targetWeightController.text = profile.targetWeight?.toString() ?? '';
          _targetBodyFatController.text = profile.targetBodyFat?.toString() ?? '';
          _targetMuscleMassController.text = profile.targetMuscleMass?.toString() ?? '';
          _fitnessGoals = List<String>.from(profile.fitnessGoals ?? []);
          _desiredBodyShapes = List<String>.from(profile.desiredBodyShapes ?? []);
          _currentBodyType = (profile.currentBodyType != null && currentBodyTypeOptions.contains(profile.currentBodyType) && profile.currentBodyType!.isNotEmpty)
              ? profile.currentBodyType!
              : currentBodyTypeOptions.first;
          _complexAreas = List<String>.from(profile.complexAreas ?? []);
          _hasSpecificGoalEvent = profile.hasSpecificGoalEvent ?? false;
          _specificGoalEventDetailsController.text = profile.specificGoalEventDetails ?? '';
          _fitnessLevel = (profile.fitnessLevel != null && fitnessLevelOptions.contains(profile.fitnessLevel) && profile.fitnessLevel!.isNotEmpty)
              ? profile.fitnessLevel!
              : fitnessLevelOptions.first;
          _weeklyWorkoutFrequency = (profile.weeklyWorkoutFrequency != null && weeklyWorkoutFrequencyOptions.contains(profile.weeklyWorkoutFrequency) && profile.weeklyWorkoutFrequency!.isNotEmpty)
              ? profile.weeklyWorkoutFrequency!
              : weeklyWorkoutFrequencyOptions.first;
          _desiredWorkoutDuration = (profile.desiredWorkoutDuration != null && desiredWorkoutDurationOptions.contains(profile.desiredWorkoutDuration) && profile.desiredWorkoutDuration!.isNotEmpty)
              ? profile.desiredWorkoutDuration!
              : desiredWorkoutDurationOptions.first;
          
          // _workoutPreferences 안전하게 로드
          if (profile.workoutPreferences != null && profile.workoutPreferences!.isNotEmpty) {
            _workoutPreferences = Map<String, String>.from(profile.workoutPreferences!);
            // 기본 키들이 누락된 경우 추가
            const defaultPreferences = {
              '유산소 운동': '보통이에요',
              '요가(스트레칭)': '보통이에요',
              '웨이트 트레이닝': '보통이에요',
              '턱걸이(풀업)': '보통이에요',
            };
            defaultPreferences.forEach((key, value) {
              if (!_workoutPreferences.containsKey(key)) {
                _workoutPreferences[key] = value;
              }
            });
          }
          _usualSportsOrInterests = List<String>.from(profile.usualSportsOrInterests ?? []);
          _pushupCountController.text = profile.pushupCount?.toString() ?? '';
          _pullupCountController.text = profile.pullupCount?.toString() ?? '';
          _preferredWorkoutLocations = List<String>.from(profile.preferredWorkoutLocations ?? []);
          _dietTypes = List<String>.from(profile.dietTypes ?? []);
          _sugarIntakeFrequency = (profile.sugarIntakeFrequency != null && sugarIntakeFrequencyOptions.contains(profile.sugarIntakeFrequency) && profile.sugarIntakeFrequency!.isNotEmpty)
              ? profile.sugarIntakeFrequency!
              : sugarIntakeFrequencyOptions.first;
          _waterIntake = (profile.waterIntake != null && waterIntakeOptions.contains(profile.waterIntake) && profile.waterIntake!.isNotEmpty)
              ? profile.waterIntake!
              : waterIntakeOptions.first;
          _mealPrepTime = (profile.mealPrepTime != null && mealPrepTimeOptions.contains(profile.mealPrepTime) && profile.mealPrepTime!.isNotEmpty)
              ? profile.mealPrepTime!
              : mealPrepTimeOptions.first;
          _pastWorkoutProblems = List<String>.from(profile.pastWorkoutProblems ?? []);
          _additionalWellnessGoals = List<String>.from(profile.additionalWellnessGoals ?? []);
          _healthConditionsOrInjuries = List<String>.from(profile.healthConditionsOrInjuries ?? []);
          _currentMuscleMassController.text = profile.currentMuscleMass?.toString() ?? '';
          _bodyFatMeasurementMethodController.text = profile.bodyFatMeasurementMethod ?? '';
          _muscleMassMeasurementMethodController.text = profile.muscleMassMeasurementMethod ?? '';
        });
      }
      // box.close() 제거 - main.dart에서 관리하는 전역 박스이므로 닫으면 안됨
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 로드 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      // 디버그 정보 출력
      print('🔍 저장 시작 - 주요 운동 목표: $_fitnessGoals');
      print('🔍 저장 시작 - 원하는 몸매: $_desiredBodyShapes');
      print('🔍 저장 시작 - 운동 취향: $_workoutPreferences');
      
      final box = Hive.box<UserProfile>('userProfileBox');
      final profile = UserProfile(
        name: _nameController.text,
        gptKey: _keyController.text,
        goal: _goalController.text,
        dietHabit: _dietController.text,
        gender: _gender,
        weight: double.tryParse(_weightController.text),
        bodyFat: double.tryParse(_bodyFatController.text),
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        targetWeight: double.tryParse(_targetWeightController.text),
        targetBodyFat: double.tryParse(_targetBodyFatController.text),
        targetMuscleMass: double.tryParse(_targetMuscleMassController.text),
        fitnessGoals: _fitnessGoals,
        desiredBodyShapes: _desiredBodyShapes,
        currentBodyType: _currentBodyType,
        complexAreas: _complexAreas,
        hasSpecificGoalEvent: _hasSpecificGoalEvent,
        specificGoalEventDetails: _specificGoalEventDetailsController.text,
        fitnessLevel: _fitnessLevel,
        weeklyWorkoutFrequency: _weeklyWorkoutFrequency,
        desiredWorkoutDuration: _desiredWorkoutDuration,
        workoutPreferences: _workoutPreferences,
        usualSportsOrInterests: _usualSportsOrInterests,
        preferredWorkoutLocations: _preferredWorkoutLocations,
        dietTypes: _dietTypes,
        sugarIntakeFrequency: _sugarIntakeFrequency,
        waterIntake: _waterIntake,
        mealPrepTime: _mealPrepTime,
        pastWorkoutProblems: _pastWorkoutProblems,
        additionalWellnessGoals: _additionalWellnessGoals,
        healthConditionsOrInjuries: _healthConditionsOrInjuries,
        pushupCount: int.tryParse(_pushupCountController.text),
        pullupCount: int.tryParse(_pullupCountController.text),
        currentMuscleMass: double.tryParse(_currentMuscleMassController.text),
        bodyFatMeasurementMethod: _bodyFatMeasurementMethodController.text,
        muscleMassMeasurementMethod: _muscleMassMeasurementMethodController.text,
      );

      await box.put('userProfile', profile);
      
      // 저장 후 확인
      print('✅ 저장 완료 - 프로필 운동 목표: ${profile.fitnessGoals}');
      print('✅ 저장 완료 - 프로필 원하는 몸매: ${profile.desiredBodyShapes}');
      print('✅ 저장 완료 - 프로필 운동 취향: ${profile.workoutPreferences}');

      // GPTContext 업데이트
      final gptContextBox = Hive.box<GPTContext>('gptContextBox');
      final gptContext = gptContextBox.get('userProfile');
      
      if (gptContext != null) {
        final updatedContext = gptContext.copyWith(
          weight: profile.weight,
          bodyFat: profile.bodyFat,
          targetBodyFat: profile.targetBodyFat,
          targetMuscleMass: profile.targetMuscleMass,
          sleepHabits: profile.sleepHabits,
          medications: profile.medications,
          availableIngredients: profile.availableIngredients,
          activityLevel: profile.activityLevel,
          availableWorkoutTime: profile.availableWorkoutTime,
          dietaryRestrictions: profile.dietaryRestrictions,
        );
        await gptContextBox.put('userProfile', updatedContext);
      } else {
        final newContext = GPTContext.fromUserProfile('user', profile);
        await gptContextBox.put('userProfile', newContext);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );
        
        // 약간의 지연 후 대시보드로 돌아가기
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // 모든 이전 화면을 제거하고 HomeScreen으로 이동
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // --- 헬퍼 위젯: 다중 선택 체크박스 ---
  Widget _buildMultiSelectChips(String title, List<String> options, List<String> selectedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedList.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedList.add(option);
                    print('➕ $title에서 "$option" 추가됨. 현재 목록: $selectedList');
                  } else {
                    selectedList.remove(option);
                    print('➖ $title에서 "$option" 제거됨. 현재 목록: $selectedList');
                  }
                });
              },
              backgroundColor: Colors.grey[700],
              selectedColor: Colors.blue,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("⚙ 개인 설정", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),

            // I. 기본 신체 정보 및 인구 통계
            const Text("I. 기본 신체 정보 및 인구 통계", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
            const Divider(color: Colors.white54),
            _buildTextField(_nameController, '이름'),
            _buildDropdown<String>(
              '성별', _gender, ['남성', '여성'],
                  (v) => setState(() => _gender = v ?? '남성'),
            ),
            _buildTextField(_ageController, '나이', TextInputType.number),
            _buildTextField(_heightController, '키 (cm)', TextInputType.number),
            _buildTextField(_weightController, '현재 체중 (kg)', TextInputType.number),
            _buildTextField(_targetWeightController, '목표 체중 (kg)', TextInputType.number),
            _buildTextField(_targetBodyFatController, '목표 체지방률 (%)', TextInputType.number),
            _buildTextField(_targetMuscleMassController, '목표 근육량 (kg)', TextInputType.number),
            _buildDropdown<String>(
              '현재 체형', _currentBodyType, currentBodyTypeOptions,
                  (v) => setState(() => _currentBodyType = v ?? currentBodyTypeOptions.first),
            ),
            const SizedBox(height: 20),

            // II. 운동 목표 및 현재 상태
            const Text("II. 운동 목표 및 현재 상태", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
            const Divider(color: Colors.white54),
            _buildMultiSelectChips('주요 운동 목표', fitnessGoalOptions, _fitnessGoals),
            _buildMultiSelectChips('원하는 몸매', desiredBodyShapeOptions, _desiredBodyShapes),
            _buildMultiSelectChips('컴플렉스가 있는 부위', complexAreaOptions, _complexAreas),
            SwitchListTile(
              title: const Text('특정 목표 일정 (예: 결혼식, 바디프로필)', style: TextStyle(color: Colors.white)),
              value: _hasSpecificGoalEvent,
              onChanged: (bool value) {
                setState(() {
                  _hasSpecificGoalEvent = value;
                });
              },
              activeColor: Colors.blue,
            ),
            if (_hasSpecificGoalEvent)
              _buildTextField(_specificGoalEventDetailsController, '특정 목표 일정 세부 정보', TextInputType.text),
            const SizedBox(height: 20),

            // III. 운동 습관 및 선호도
            const Text("III. 운동 습관 및 선호도", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
            const Divider(color: Colors.white54),
            _buildDropdown<String>(
              '체력 수준', _fitnessLevel, fitnessLevelOptions,
                  (v) => setState(() => _fitnessLevel = v ?? fitnessLevelOptions.first),
            ),
            _buildDropdown<String>(
              '지난 3개월간 주간 운동 횟수', _weeklyWorkoutFrequency, weeklyWorkoutFrequencyOptions,
                  (v) => setState(() => _weeklyWorkoutFrequency = v ?? weeklyWorkoutFrequencyOptions.first),
            ),
            _buildDropdown<String>(
              '한 번 운동할 때 원하는 시간', _desiredWorkoutDuration, desiredWorkoutDurationOptions,
                  (v) => setState(() => _desiredWorkoutDuration = v ?? desiredWorkoutDurationOptions.first),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Text('운동 취향', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                ..._workoutPreferences.keys.map((type) => Row(
                  children: [
                    Expanded(child: Text(type, style: const TextStyle(color: Colors.white70))),
                    DropdownButton<String>(
                      value: workoutPreferenceLevels.contains(_workoutPreferences[type])
                        ? _workoutPreferences[type]
                        : workoutPreferenceLevels.first,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      items: workoutPreferenceLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _workoutPreferences[type] = v ?? workoutPreferenceLevels.first;
                        });
                      },
                    ),
                  ],
                )).toList(),
                const SizedBox(height: 10),
              ],
            ),
            _buildMultiSelectChips('평소 하는 운동 또는 관심 있는 스포츠', usualSportsOrInterestsOptions, _usualSportsOrInterests),
            _buildTextField(_pushupCountController, '푸쉬업(팔굽혀펴기) 가능 개수', TextInputType.number),
            _buildTextField(_pullupCountController, '턱걸이(풀업) 가능 개수 (선택 사항)', TextInputType.number),
            _buildMultiSelectChips('선호하는 운동 장소', preferredWorkoutLocationOptions, _preferredWorkoutLocations),
            const SizedBox(height: 20),

            // IV. 식단 습관 및 건강 관련 정보
            const Text("IV. 식단 습관 및 건강 관련 정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
            const Divider(color: Colors.white54),
            _buildMultiSelectChips('따르고 있는 식단 유형', dietTypeOptions, _dietTypes),
            _buildDropdown<String>(
              '설탕이 들어간 음식/음료 섭취 빈도', _sugarIntakeFrequency, sugarIntakeFrequencyOptions,
                  (v) => setState(() => _sugarIntakeFrequency = v ?? sugarIntakeFrequencyOptions.first),
            ),
            _buildDropdown<String>(
              '하루 물 섭취량', _waterIntake, waterIntakeOptions,
                  (v) => setState(() => _waterIntake = v ?? waterIntakeOptions.first),
            ),
            _buildDropdown<String>(
              '식사 준비에 할애할 수 있는 시간', _mealPrepTime, mealPrepTimeOptions,
                  (v) => setState(() => _mealPrepTime = v ?? mealPrepTimeOptions.first),
            ),
            const SizedBox(height: 20),

            // V. 기타 및 건강 관련 정보
            const Text("V. 기타 및 건강 관련 정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
            const Divider(color: Colors.white54),
            _buildMultiSelectChips('이전에 운동을 시도하면서 겪었던 문제점', pastWorkoutProblemOptions, _pastWorkoutProblems),
            _buildMultiSelectChips('추가 목표 (운동 외적인 건강 및 웰빙 목표)', additionalWellnessGoalOptions, _additionalWellnessGoals),
            _buildMultiSelectChips('기저 질환 또는 과거 부상 이력', healthConditionOrInjuryOptions, _healthConditionsOrInjuries),
            const SizedBox(height: 20),

            // 체지방과 근육량 관련 필드 추가
            const SizedBox(height: 16),
            const Text('체지방과 근육량 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyFatController,
              decoration: const InputDecoration(
                labelText: '현재 체지방률 (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _bodyFatMeasurementMethodController.text.isEmpty 
                  ? measurementMethodOptions.first
                  : _bodyFatMeasurementMethodController.text,
              decoration: const InputDecoration(
                labelText: '체지방 측정 방법',
                border: OutlineInputBorder(),
              ),
              items: measurementMethodOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _bodyFatMeasurementMethodController.text = newValue ?? measurementMethodOptions.first;
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currentMuscleMassController,
              decoration: const InputDecoration(
                labelText: '현재 근육량 (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _muscleMassMeasurementMethodController.text.isEmpty 
                  ? measurementMethodOptions.first
                  : _muscleMassMeasurementMethodController.text,
              decoration: const InputDecoration(
                labelText: '근육량 측정 방법',
                border: OutlineInputBorder(),
              ),
              items: measurementMethodOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _muscleMassMeasurementMethodController.text = newValue ?? measurementMethodOptions.first;
                });
              },
            ),

            // API Key (기존 필드)
            TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                    labelText: 'API_KEY',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))
                ),
                style: const TextStyle(color: Colors.white)
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('저장'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 헬퍼 함수: TextField 위젯 빌드
  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // 헬퍼 함수: DropdownButtonFormField 위젯 빌드
  Widget _buildDropdown<T>(String label, T value, List<T> options, ValueChanged<T?> onChanged) {
    final safeValue = options.contains(value) ? value : options.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: DropdownButtonFormField<T>(
        value: safeValue,
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt.toString()))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
        dropdownColor: Colors.grey[800],
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}