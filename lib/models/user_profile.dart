// openfit/models/user_profile.dart
import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 4)
class UserProfile extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? gender;

  @HiveField(2)
  double? weight;

  @HiveField(3)
  double? bodyFat;  // 현재 체지방률

  @HiveField(4)
  String? dietHabit; // 기존 식습관 -> 이제 '따르고 있는 식단 유형'으로 확장될 수 있음

  @HiveField(5)
  String? goal; // 기존 건강 목표 -> 이제 '주요 운동 목표'로 확장될 수 있음

  @HiveField(6)
  String? gptKey;

  // --- 추가될 필드들 ---
  @HiveField(7)
  int? age;

  @HiveField(8)
  double? height;

  @HiveField(9)
  double? targetWeight;

  @HiveField(10)
  double? targetBodyFat;  // 목표 체지방율

  @HiveField(11)
  double? targetMuscleMass;  // 목표 근육량

  @HiveField(12)
  String? sleepHabits;  // 수면 습관

  @HiveField(13)
  String? medicationsStr;

  @HiveField(14)
  String? availableIngredientsStr;

  @HiveField(15)
  String? activityLevel;  // 활동 수준

  @HiveField(16)
  String? availableWorkoutTime;  // 운동 가능 시간

  @HiveField(17)
  String? dietaryRestrictions;  // 식이 제한사항

  @HiveField(18)
  String? dietaryType;

  @HiveField(19)
  String? fitnessGoalsStr;

  @HiveField(20)
  String? desiredBodyShapesStr;

  @HiveField(21)
  String? currentBodyType; // 현재 체형

  @HiveField(22)
  String? complexAreasStr;

  @HiveField(23)
  bool? hasSpecificGoalEvent; // 특정 목표 여부 (예: 결혼식, 바디프로필)

  @HiveField(24)
  String? specificGoalEventDetails; // 특정 목표 이벤트 세부 정보 (선택 사항)

  @HiveField(25)
  String? fitnessLevel; // 체력 수준

  @HiveField(26)
  String? weeklyWorkoutFrequency; // 지난 3개월간 주간 운동 횟수

  @HiveField(27)
  String? desiredWorkoutDuration; // 한 번 운동할 때 원하는 시간

  @HiveField(28)
  Map<String, String>? workoutPreferences; // 운동 취향 (유형별 선호도)

  @HiveField(29)
  String? usualSportsOrInterestsStr;

  @HiveField(30)
  int? pushupCount; // 푸쉬업 가능 개수

  @HiveField(31)
  int? pullupCount; // 턱걸이(풀업) 가능 개수 (선택 사항)

  @HiveField(32)
  String? preferredWorkoutLocationsStr;

  @HiveField(33)
  String? dietTypesStr;

  @HiveField(34)
  String? sugarIntakeFrequency; // 설탕이 들어간 음식/음료 섭취 빈도

  @HiveField(35)
  String? waterIntake; // 하루 물 섭취량

  @HiveField(36)
  String? mealPrepTime; // 식사 준비에 할애할 수 있는 시간

  @HiveField(37)
  String? pastWorkoutProblemsStr;

  @HiveField(38)
  String? additionalWellnessGoalsStr;

  @HiveField(39)
  String? healthConditionsOrInjuriesStr;

  @HiveField(40)
  DateTime? lastUpdated;

  @HiveField(41)
  double? currentMuscleMass;  // 현재 근육량

  @HiveField(42)
  DateTime? lastBodyFatMeasurement;  // 마지막 체지방 측정일

  @HiveField(43)
  DateTime? lastMuscleMassMeasurement;  // 마지막 근육량 측정일

  @HiveField(44)
  String? bodyFatMeasurementMethod;  // 체지방 측정 방법

  @HiveField(45)
  String? muscleMassMeasurementMethod;  // 근육량 측정 방법

  UserProfile({
    this.name,
    this.gender,
    this.weight,
    this.bodyFat,
    this.dietHabit,
    this.goal,
    this.gptKey,
    this.age,
    this.height,
    this.targetWeight,
    this.targetBodyFat,
    this.targetMuscleMass,
    this.currentMuscleMass,
    this.lastBodyFatMeasurement,
    this.lastMuscleMassMeasurement,
    this.bodyFatMeasurementMethod,
    this.muscleMassMeasurementMethod,
    this.sleepHabits,
    List<String>? medications,
    List<String>? availableIngredients,
    this.activityLevel,
    this.availableWorkoutTime,
    this.dietaryRestrictions,
    this.dietaryType,
    List<String>? fitnessGoals,
    List<String>? desiredBodyShapes,
    this.currentBodyType,
    List<String>? complexAreas,
    this.hasSpecificGoalEvent,
    this.specificGoalEventDetails,
    String? fitnessLevel,
    String? weeklyWorkoutFrequency,
    String? desiredWorkoutDuration,
    Map<String, String>? workoutPreferences,
    List<String>? usualSportsOrInterests,
    this.pushupCount,
    this.pullupCount,
    List<String>? preferredWorkoutLocations,
    List<String>? dietTypes,
    this.sugarIntakeFrequency,
    this.waterIntake,
    this.mealPrepTime,
    List<String>? pastWorkoutProblems,
    List<String>? additionalWellnessGoals,
    List<String>? healthConditionsOrInjuries,
    this.lastUpdated,
  }) {
    // 🔥 List를 String으로 변환하여 저장
    this.medicationsStr = _listToString(medications);
    this.availableIngredientsStr = _listToString(availableIngredients);
    this.fitnessGoalsStr = _listToString(fitnessGoals);
    this.desiredBodyShapesStr = _listToString(desiredBodyShapes);
    this.complexAreasStr = _listToString(complexAreas);
    this.usualSportsOrInterestsStr = _listToString(usualSportsOrInterests);
    this.preferredWorkoutLocationsStr = _listToString(preferredWorkoutLocations);
    this.dietTypesStr = _listToString(dietTypes);
    this.pastWorkoutProblemsStr = _listToString(pastWorkoutProblems);
    this.additionalWellnessGoalsStr = _listToString(additionalWellnessGoals);
    this.healthConditionsOrInjuriesStr = _listToString(healthConditionsOrInjuries);
    
    // 드롭다운 관련 필드 안전 보정
    const fitnessLevelOptions = ['초급 (일상생활 어려움)', '초보자 (가끔 운동 시도)', '고급 (꾸준히 고강도 운동 가능)'];
    const weeklyWorkoutFrequencyOptions = ['전혀 하지 않음', '주 1~2회', '주 3회', '주 3회 이상'];
    const desiredWorkoutDurationOptions = ['10~15분', '20~30분', '30~40분', '40~60분', '시스템에 맡기기'];
    const workoutPreferenceLevels = ['싫어요', '보통이에요', '좋아요'];

    this.fitnessLevel = (fitnessLevel != null && fitnessLevelOptions.contains(fitnessLevel) && fitnessLevel.isNotEmpty)
        ? fitnessLevel
        : '초보자 (가끔 운동 시도)';
    this.weeklyWorkoutFrequency = (weeklyWorkoutFrequency != null && weeklyWorkoutFrequencyOptions.contains(weeklyWorkoutFrequency) && weeklyWorkoutFrequency.isNotEmpty)
        ? weeklyWorkoutFrequency
        : '주 1~2회';
    this.desiredWorkoutDuration = (desiredWorkoutDuration != null && desiredWorkoutDurationOptions.contains(desiredWorkoutDuration) && desiredWorkoutDuration.isNotEmpty)
        ? desiredWorkoutDuration
        : '30~40분';
    this.workoutPreferences = (workoutPreferences ?? {
      '유산소 운동': '보통이에요',
      '요가(스트레칭)': '보통이에요',
      '웨이트 트레이닝': '보통이에요',
      '턱걸이(풀업)': '보통이에요',
    }).map((k, v) => MapEntry(
      k,
      (v != null && workoutPreferenceLevels.contains(v) && v.isNotEmpty) ? v : '보통이에요',
    ));
  }

  String toPrompt() {
    // GPT 프롬프트 생성 로직을 더욱 상세하게 구성
    final buffer = StringBuffer();
    buffer.writeln('사용자의 이름은 $name이고, 성별은 $gender입니다.');
    buffer.writeln('나이는 $age세이며, 키는 ${height?.toStringAsFixed(1) ?? '알 수 없음'}cm입니다.');
    buffer.writeln('현재 체중은 ${weight?.toStringAsFixed(1) ?? '알 수 없음'}kg이며, 목표 체중은 ${targetWeight?.toStringAsFixed(1) ?? '알 수 없음'}kg입니다.');
    
    // 체지방 관련 정보
    if (bodyFat != null) {
      buffer.writeln('현재 체지방률은 ${bodyFat!.toStringAsFixed(1)}%입니다.');
    }
    if (targetBodyFat != null) {
      buffer.writeln('목표 체지방률은 ${targetBodyFat!.toStringAsFixed(1)}%입니다.');
    }
    
    // 근육량 관련 정보
    if (currentMuscleMass != null) {
      buffer.writeln('현재 근육량은 ${currentMuscleMass!.toStringAsFixed(1)}kg입니다.');
    }
    if (targetMuscleMass != null) {
      buffer.writeln('목표 근육량은 ${targetMuscleMass!.toStringAsFixed(1)}kg입니다.');
    }
    
    // 측정 관련 정보
    if (lastBodyFatMeasurement != null) {
      buffer.writeln('마지막 체지방 측정일: ${lastBodyFatMeasurement.toString()}');
    }
    if (lastMuscleMassMeasurement != null) {
      buffer.writeln('마지막 근육량 측정일: ${lastMuscleMassMeasurement.toString()}');
    }
    if (bodyFatMeasurementMethod != null) {
      buffer.writeln('체지방 측정 방법: $bodyFatMeasurementMethod');
    }
    if (muscleMassMeasurementMethod != null) {
      buffer.writeln('근육량 측정 방법: $muscleMassMeasurementMethod');
    }

    if (fitnessGoals?.isNotEmpty == true) {
      buffer.writeln('주요 운동 목표는 ${fitnessGoals?.join(', ') ?? '알 수 없음'}입니다.');
    }
    if (desiredBodyShapes?.isNotEmpty == true) {
      buffer.writeln('원하는 몸매는 ${desiredBodyShapes?.join(', ') ?? '알 수 없음'}입니다.');
    }
    if (complexAreas?.isNotEmpty == true) {
      buffer.writeln('컴플렉스가 있는 부위는 ${complexAreas?.join(', ') ?? '알 수 없음'}입니다.');
    }
    if (hasSpecificGoalEvent == true && specificGoalEventDetails != null) {
      buffer.writeln('특정 목표는 "$specificGoalEventDetails" 일정에 맞춘 몸관리입니다.');
    }

    buffer.writeln('현재 체력 수준은 $fitnessLevel입니다.');
    buffer.writeln('지난 3개월간 주간 운동 횟수는 $weeklyWorkoutFrequency입니다.');
    buffer.writeln('한 번 운동할 때 원하는 시간은 $desiredWorkoutDuration입니다.');

    if (workoutPreferences?.isNotEmpty == true) {
      buffer.writeln('운동 취향:');
      workoutPreferences?.forEach((type, preference) {
        buffer.writeln('  $type: $preference');
      });
    }
    if (usualSportsOrInterests?.isNotEmpty == true) {
      buffer.writeln('평소 하는 운동 또는 관심 있는 스포츠는 ${usualSportsOrInterests?.join(', ') ?? '알 수 없음'}입니다.');
    }
    buffer.writeln('푸쉬업은 ${pushupCount != null ? pushupCount.toString() : '없음'}개 가능합니다.');
    if (pullupCount != null) {
      buffer.writeln('턱걸이는 ${pullupCount}개 가능합니다.');
    }
    if (preferredWorkoutLocations?.isNotEmpty == true) {
      buffer.writeln('선호하는 운동 장소는 ${preferredWorkoutLocations?.join(', ') ?? '알 수 없음'}입니다.');
    }

    if (dietTypes?.isNotEmpty == true) {
      buffer.writeln('따르고 있는 식단 유형은 ${dietTypes?.join(', ') ?? '알 수 없음'}입니다.');
    }
    buffer.writeln('설탕이 들어간 음식/음료 섭취 빈도는 $sugarIntakeFrequency입니다.');
    buffer.writeln('하루 물 섭취량은 $waterIntake입니다.');
    buffer.writeln('식사 준비에 할애할 수 있는 시간은 $mealPrepTime입니다.');

    if (pastWorkoutProblems?.isNotEmpty == true) {
      buffer.writeln('이전에 운동을 시도하면서 겪었던 문제점은 ${pastWorkoutProblems?.join(', ') ?? '알 수 없음'}입니다.');
    }
    if (additionalWellnessGoals?.isNotEmpty == true) {
      buffer.writeln('추가적인 건강 및 웰빙 목표는 ${additionalWellnessGoals?.join(', ') ?? '알 수 없음'}입니다.');
    }
    if (healthConditionsOrInjuries?.isNotEmpty == true) {
      buffer.writeln('기저 질환 또는 과거 부상 이력: ${healthConditionsOrInjuries?.join(', ') ?? '알 수 없음'}입니다.');
    }

    return buffer.toString();
  }

  // 프로필 업데이트 메서드 추가
  UserProfile copyWith({
    String? name,
    String? gender,
    double? weight,
    double? bodyFat,
    String? dietHabit,
    String? goal,
    String? gptKey,
    int? age,
    double? height,
    double? targetWeight,
    double? targetBodyFat,
    double? targetMuscleMass,
    double? currentMuscleMass,
    DateTime? lastBodyFatMeasurement,
    DateTime? lastMuscleMassMeasurement,
    String? bodyFatMeasurementMethod,
    String? muscleMassMeasurementMethod,
    String? sleepHabits,
    List<String>? medications,
    List<String>? availableIngredients,
    String? activityLevel,
    String? availableWorkoutTime,
    String? dietaryRestrictions,
    String? dietaryType,
    List<String>? fitnessGoals,
    List<String>? desiredBodyShapes,
    String? currentBodyType,
    List<String>? complexAreas,
    bool? hasSpecificGoalEvent,
    String? specificGoalEventDetails,
    String? fitnessLevel,
    String? weeklyWorkoutFrequency,
    String? desiredWorkoutDuration,
    Map<String, String>? workoutPreferences,
    List<String>? usualSportsOrInterests,
    int? pushupCount,
    int? pullupCount,
    List<String>? preferredWorkoutLocations,
    List<String>? dietTypes,
    String? sugarIntakeFrequency,
    String? waterIntake,
    String? mealPrepTime,
    List<String>? pastWorkoutProblems,
    List<String>? additionalWellnessGoals,
    List<String>? healthConditionsOrInjuries,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      dietHabit: dietHabit ?? this.dietHabit,
      goal: goal ?? this.goal,
      gptKey: gptKey ?? this.gptKey,
      age: age ?? this.age,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      targetBodyFat: targetBodyFat ?? this.targetBodyFat,
      targetMuscleMass: targetMuscleMass ?? this.targetMuscleMass,
      currentMuscleMass: currentMuscleMass ?? this.currentMuscleMass,
      lastBodyFatMeasurement: lastBodyFatMeasurement ?? this.lastBodyFatMeasurement,
      lastMuscleMassMeasurement: lastMuscleMassMeasurement ?? this.lastMuscleMassMeasurement,
      bodyFatMeasurementMethod: bodyFatMeasurementMethod ?? this.bodyFatMeasurementMethod,
      muscleMassMeasurementMethod: muscleMassMeasurementMethod ?? this.muscleMassMeasurementMethod,
      sleepHabits: sleepHabits ?? this.sleepHabits,
      medications: medications ?? this.medications,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      activityLevel: activityLevel ?? this.activityLevel,
      availableWorkoutTime: availableWorkoutTime ?? this.availableWorkoutTime,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      dietaryType: dietaryType ?? this.dietaryType,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      desiredBodyShapes: desiredBodyShapes ?? this.desiredBodyShapes,
      currentBodyType: currentBodyType ?? this.currentBodyType,
      complexAreas: complexAreas ?? this.complexAreas,
      hasSpecificGoalEvent: hasSpecificGoalEvent ?? this.hasSpecificGoalEvent,
      specificGoalEventDetails: specificGoalEventDetails ?? this.specificGoalEventDetails,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      weeklyWorkoutFrequency: weeklyWorkoutFrequency ?? this.weeklyWorkoutFrequency,
      desiredWorkoutDuration: desiredWorkoutDuration ?? this.desiredWorkoutDuration,
      workoutPreferences: workoutPreferences ?? this.workoutPreferences,
      usualSportsOrInterests: usualSportsOrInterests ?? this.usualSportsOrInterests,
      pushupCount: pushupCount ?? this.pushupCount,
      pullupCount: pullupCount ?? this.pullupCount,
      preferredWorkoutLocations: preferredWorkoutLocations ?? this.preferredWorkoutLocations,
      dietTypes: dietTypes ?? this.dietTypes,
      sugarIntakeFrequency: sugarIntakeFrequency ?? this.sugarIntakeFrequency,
      waterIntake: waterIntake ?? this.waterIntake,
      mealPrepTime: mealPrepTime ?? this.mealPrepTime,
      pastWorkoutProblems: pastWorkoutProblems ?? this.pastWorkoutProblems,
      additionalWellnessGoals: additionalWellnessGoals ?? this.additionalWellnessGoals,
      healthConditionsOrInjuries: healthConditionsOrInjuries ?? this.healthConditionsOrInjuries,
      lastUpdated: DateTime.now(),
    );
  }

  static void registerAdapters() {
    Hive.registerAdapter(UserProfileAdapter());
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'weight': weight,
      'bodyFat': bodyFat,
      'dietHabit': dietHabit,
      'goal': goal,
      'gptKey': gptKey,
      'age': age,
      'height': height,
      'targetWeight': targetWeight,
      'targetBodyFat': targetBodyFat,
      'targetMuscleMass': targetMuscleMass,
      'currentMuscleMass': currentMuscleMass,
      'lastBodyFatMeasurement': lastBodyFatMeasurement?.toIso8601String(),
      'lastMuscleMassMeasurement': lastMuscleMassMeasurement?.toIso8601String(),
      'bodyFatMeasurementMethod': bodyFatMeasurementMethod,
      'muscleMassMeasurementMethod': muscleMassMeasurementMethod,
      'sleepHabits': sleepHabits,
      'medications': medications,
      'availableIngredients': availableIngredients,
      'activityLevel': activityLevel,
      'availableWorkoutTime': availableWorkoutTime,
      'dietaryRestrictions': dietaryRestrictions,
      'dietaryType': dietaryType,
      'fitnessGoals': fitnessGoals,
      'desiredBodyShapes': desiredBodyShapes,
      'currentBodyType': currentBodyType,
      'complexAreas': complexAreas,
      'hasSpecificGoalEvent': hasSpecificGoalEvent,
      'specificGoalEventDetails': specificGoalEventDetails,
      'fitnessLevel': fitnessLevel,
      'weeklyWorkoutFrequency': weeklyWorkoutFrequency,
      'desiredWorkoutDuration': desiredWorkoutDuration,
      'workoutPreferences': workoutPreferences,
      'usualSportsOrInterests': usualSportsOrInterests,
      'pushupCount': pushupCount,
      'pullupCount': pullupCount,
      'preferredWorkoutLocations': preferredWorkoutLocations,
      'dietTypes': dietTypes,
      'sugarIntakeFrequency': sugarIntakeFrequency,
      'waterIntake': waterIntake,
      'mealPrepTime': mealPrepTime,
      'pastWorkoutProblems': pastWorkoutProblems,
      'additionalWellnessGoals': additionalWellnessGoals,
      'healthConditionsOrInjuries': healthConditionsOrInjuries,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // === 헬퍼 메서드들 ===
  
  // 구분자 상수
  static const String _separator = '|||';
  
  // String ↔ List 변환 헬퍼
  static String _listToString(List<String>? items) {
    if (items == null || items.isEmpty) return '';
    return items.join(_separator);
  }
  
  static List<String> _stringToList(String? str) {
    if (str == null || str.isEmpty) return [];
    return str.split(_separator);
  }
  
  // Getter/Setter들
  List<String> get medications => _stringToList(medicationsStr);
  set medications(List<String> value) => medicationsStr = _listToString(value);
  
  List<String> get availableIngredients => _stringToList(availableIngredientsStr);
  set availableIngredients(List<String> value) => availableIngredientsStr = _listToString(value);
  
  List<String> get fitnessGoals => _stringToList(fitnessGoalsStr);
  set fitnessGoals(List<String> value) => fitnessGoalsStr = _listToString(value);
  
  List<String> get desiredBodyShapes => _stringToList(desiredBodyShapesStr);
  set desiredBodyShapes(List<String> value) => desiredBodyShapesStr = _listToString(value);
  
  List<String> get complexAreas => _stringToList(complexAreasStr);
  set complexAreas(List<String> value) => complexAreasStr = _listToString(value);
  
  List<String> get usualSportsOrInterests => _stringToList(usualSportsOrInterestsStr);
  set usualSportsOrInterests(List<String> value) => usualSportsOrInterestsStr = _listToString(value);
  
  List<String> get preferredWorkoutLocations => _stringToList(preferredWorkoutLocationsStr);
  set preferredWorkoutLocations(List<String> value) => preferredWorkoutLocationsStr = _listToString(value);
  
  List<String> get dietTypes => _stringToList(dietTypesStr);
  set dietTypes(List<String> value) => dietTypesStr = _listToString(value);
  
  List<String> get pastWorkoutProblems => _stringToList(pastWorkoutProblemsStr);
  set pastWorkoutProblems(List<String> value) => pastWorkoutProblemsStr = _listToString(value);
  
  List<String> get additionalWellnessGoals => _stringToList(additionalWellnessGoalsStr);
  set additionalWellnessGoals(List<String> value) => additionalWellnessGoalsStr = _listToString(value);
  
  List<String> get healthConditionsOrInjuries => _stringToList(healthConditionsOrInjuriesStr);
  set healthConditionsOrInjuries(List<String> value) => healthConditionsOrInjuriesStr = _listToString(value);
}