import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart';

part 'gpt_context.g.dart';

@HiveType(typeId: 3)
class GPTContext extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String? conversationId;

  @HiveField(2)
  double? weight;

  @HiveField(3)
  double? bodyFat;

  @HiveField(4)
  double? targetBodyFat;

  @HiveField(5)
  double? targetMuscleMass;

  @HiveField(6)
  double? currentMuscleMass;

  @HiveField(7)
  String? sleepHabits;

  @HiveField(8)
  String? medicationsStr;

  @HiveField(9)
  String? availableIngredientsStr;

  @HiveField(10)
  String? activityLevel;

  @HiveField(11)
  String? availableWorkoutTime;

  @HiveField(12)
  String? dietaryRestrictions;

  @HiveField(13)
  String? historySummary;

  @HiveField(14)
  String? fitnessGoalsStr;

  @HiveField(15)
  String? desiredBodyShapesStr;

  @HiveField(16)
  String? complexAreasStr;

  @HiveField(17)
  Map<String, String>? workoutPreferences;

  @HiveField(18)
  String? fitnessLevel;

  @HiveField(19)
  String? weeklyWorkoutFrequency;

  @HiveField(20)
  String? currentBodyType;

  GPTContext({
    required this.userId,
    this.conversationId,
    this.weight,
    this.bodyFat,
    this.targetBodyFat,
    this.targetMuscleMass,
    this.currentMuscleMass,
    this.sleepHabits,
    List<String>? medications,
    List<String>? availableIngredients,
    this.activityLevel,
    this.availableWorkoutTime,
    this.dietaryRestrictions,
    this.historySummary,
    List<String>? fitnessGoals,
    List<String>? desiredBodyShapes,
    List<String>? complexAreas,
    this.workoutPreferences,
    this.fitnessLevel,
    this.weeklyWorkoutFrequency,
    this.currentBodyType,
  }) {
    this.medicationsStr = medications != null ? _listToString(medications) : null;
    this.availableIngredientsStr = availableIngredients != null ? _listToString(availableIngredients) : null;
    this.fitnessGoalsStr = fitnessGoals != null ? _listToString(fitnessGoals) : null;
    this.desiredBodyShapesStr = desiredBodyShapes != null ? _listToString(desiredBodyShapes) : null;
    this.complexAreasStr = complexAreas != null ? _listToString(complexAreas) : null;
  }

  GPTContext copyWith({
    String? userId,
    String? conversationId,
    double? weight,
    double? bodyFat,
    double? targetBodyFat,
    double? targetMuscleMass,
    double? currentMuscleMass,
    String? sleepHabits,
    List<String>? medications,
    List<String>? availableIngredients,
    String? activityLevel,
    String? availableWorkoutTime,
    String? dietaryRestrictions,
    String? historySummary,
    List<String>? fitnessGoals,
    List<String>? desiredBodyShapes,
    List<String>? complexAreas,
    Map<String, String>? workoutPreferences,
    String? fitnessLevel,
    String? weeklyWorkoutFrequency,
    String? currentBodyType,
  }) {
    return GPTContext(
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      targetBodyFat: targetBodyFat ?? this.targetBodyFat,
      targetMuscleMass: targetMuscleMass ?? this.targetMuscleMass,
      currentMuscleMass: currentMuscleMass ?? this.currentMuscleMass,
      sleepHabits: sleepHabits ?? this.sleepHabits,
      medications: medications ?? this.medications,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      activityLevel: activityLevel ?? this.activityLevel,
      availableWorkoutTime: availableWorkoutTime ?? this.availableWorkoutTime,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      historySummary: historySummary ?? this.historySummary,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      desiredBodyShapes: desiredBodyShapes ?? this.desiredBodyShapes,
      complexAreas: complexAreas ?? this.complexAreas,
      workoutPreferences: workoutPreferences ?? this.workoutPreferences,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      weeklyWorkoutFrequency: weeklyWorkoutFrequency ?? this.weeklyWorkoutFrequency,
      currentBodyType: currentBodyType ?? this.currentBodyType,
    );
  }

  static GPTContext fromUserProfile(String userId, UserProfile profile, {String? conversationId}) {
    return GPTContext(
      userId: userId,
      conversationId: conversationId,
      weight: profile.weight,
      bodyFat: profile.bodyFat,
      targetBodyFat: profile.targetBodyFat,
      targetMuscleMass: profile.targetMuscleMass,
      currentMuscleMass: profile.currentMuscleMass,
      fitnessGoals: profile.fitnessGoals,
      desiredBodyShapes: profile.desiredBodyShapes,
      complexAreas: profile.complexAreas,
      workoutPreferences: profile.workoutPreferences,
      fitnessLevel: profile.fitnessLevel,
      weeklyWorkoutFrequency: profile.weeklyWorkoutFrequency,
      currentBodyType: profile.currentBodyType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'conversationId': conversationId,
      'weight': weight,
      'bodyFat': bodyFat,
      'targetBodyFat': targetBodyFat,
      'targetMuscleMass': targetMuscleMass,
      'currentMuscleMass': currentMuscleMass,
      'sleepHabits': sleepHabits,
      'medications': medications,
      'availableIngredients': availableIngredients,
      'activityLevel': activityLevel,
      'availableWorkoutTime': availableWorkoutTime,
      'dietaryRestrictions': dietaryRestrictions,
      'historySummary': historySummary,
      'fitnessGoals': fitnessGoals,
      'desiredBodyShapes': desiredBodyShapes,
      'complexAreas': complexAreas,
      'workoutPreferences': workoutPreferences,
      'fitnessLevel': fitnessLevel,
      'weeklyWorkoutFrequency': weeklyWorkoutFrequency,
      'currentBodyType': currentBodyType,
    };
  }

  factory GPTContext.fromJson(Map<String, dynamic> json) {
    return GPTContext(
      userId: json['userId'] as String,
      conversationId: json['conversationId'] as String?,
      weight: json['weight'] as double?,
      bodyFat: json['bodyFat'] as double?,
      targetBodyFat: json['targetBodyFat'] as double?,
      targetMuscleMass: json['targetMuscleMass'] as double?,
      currentMuscleMass: json['currentMuscleMass'] as double?,
      sleepHabits: json['sleepHabits'] as String?,
      medications: (json['medications'] as List<dynamic>?)?.map((e) => e as String).toList(),
      availableIngredients: (json['availableIngredients'] as List<dynamic>?)?.map((e) => e as String).toList(),
      activityLevel: json['activityLevel'] as String?,
      availableWorkoutTime: json['availableWorkoutTime'] as String?,
      dietaryRestrictions: json['dietaryRestrictions'] as String?,
      historySummary: json['historySummary'] as String?,
      fitnessGoals: (json['fitnessGoals'] as List<dynamic>?)?.map((e) => e as String).toList(),
      desiredBodyShapes: (json['desiredBodyShapes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      complexAreas: (json['complexAreas'] as List<dynamic>?)?.map((e) => e as String).toList(),
      workoutPreferences: (json['workoutPreferences'] as Map<dynamic, dynamic>?)?.map((k, v) => MapEntry(k as String, v as String)),
      fitnessLevel: json['fitnessLevel'] as String?,
      weeklyWorkoutFrequency: json['weeklyWorkoutFrequency'] as String?,
      currentBodyType: json['currentBodyType'] as String?,
    );
  }

  String toPrompt() {
    final buffer = StringBuffer();
    
    if (weight != null) {
      buffer.writeln('체중: ${weight}kg');
    }
    if (bodyFat != null) {
      buffer.writeln('체지방률: ${bodyFat}%');
    }
    if (targetBodyFat != null) {
      buffer.writeln('목표 체지방률: ${targetBodyFat}%');
    }
    if (targetMuscleMass != null) {
      buffer.writeln('목표 근육량: ${targetMuscleMass}kg');
    }
    if (currentMuscleMass != null) {
      buffer.writeln('현재 근육량: ${currentMuscleMass}kg');
    }
    if (sleepHabits != null) {
      buffer.writeln('수면 습관: $sleepHabits');
    }
    if (medications != null && medications!.isNotEmpty) {
      buffer.writeln('복용 중인 약: ${medications!.join(', ')}');
    }
    if (availableIngredients != null && availableIngredients!.isNotEmpty) {
      buffer.writeln('가용 식재료: ${availableIngredients!.join(', ')}');
    }
    if (activityLevel != null) {
      buffer.writeln('활동 수준: $activityLevel');
    }
    if (availableWorkoutTime != null) {
      buffer.writeln('운동 가능 시간: $availableWorkoutTime');
    }
    if (dietaryRestrictions != null) {
      buffer.writeln('식이 제한: $dietaryRestrictions');
    }
    
    if (fitnessGoals != null && fitnessGoals!.isNotEmpty) {
      buffer.writeln('운동 목표: ${fitnessGoals!.join(', ')}');
    }
    if (desiredBodyShapes != null && desiredBodyShapes!.isNotEmpty) {
      buffer.writeln('원하는 몸매: ${desiredBodyShapes!.join(', ')}');
    }
    if (complexAreas != null && complexAreas!.isNotEmpty) {
      buffer.writeln('컴플렉스 부위: ${complexAreas!.join(', ')}');
    }
    if (workoutPreferences != null && workoutPreferences!.isNotEmpty) {
      buffer.writeln('운동 취향:');
      workoutPreferences!.forEach((type, preference) {
        buffer.writeln('  $type: $preference');
      });
    }
    if (fitnessLevel != null) {
      buffer.writeln('체력 수준: $fitnessLevel');
    }
    if (weeklyWorkoutFrequency != null) {
      buffer.writeln('주간 운동 빈도: $weeklyWorkoutFrequency');
    }
    if (currentBodyType != null) {
      buffer.writeln('현재 체형: $currentBodyType');
    }
    
    if (historySummary != null && historySummary!.trim().isNotEmpty) {
      buffer.writeln('\n대화 히스토리 요약:\n$historySummary');
    }

    return buffer.toString();
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
  List<String>? get medications => medicationsStr != null ? _stringToList(medicationsStr) : null;
  set medications(List<String>? value) => medicationsStr = value != null ? _listToString(value) : null;
  
  List<String>? get availableIngredients => availableIngredientsStr != null ? _stringToList(availableIngredientsStr) : null;
  set availableIngredients(List<String>? value) => availableIngredientsStr = value != null ? _listToString(value) : null;
  
  List<String>? get fitnessGoals => fitnessGoalsStr != null ? _stringToList(fitnessGoalsStr) : null;
  set fitnessGoals(List<String>? value) => fitnessGoalsStr = value != null ? _listToString(value) : null;
  
  List<String>? get desiredBodyShapes => desiredBodyShapesStr != null ? _stringToList(desiredBodyShapesStr) : null;
  set desiredBodyShapes(List<String>? value) => desiredBodyShapesStr = value != null ? _listToString(value) : null;
  
  List<String>? get complexAreas => complexAreasStr != null ? _stringToList(complexAreasStr) : null;
  set complexAreas(List<String>? value) => complexAreasStr = value != null ? _listToString(value) : null;
} 