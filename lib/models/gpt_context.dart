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
  List<String>? medications;

  @HiveField(9)
  List<String>? availableIngredients;

  @HiveField(10)
  String? activityLevel;

  @HiveField(11)
  String? availableWorkoutTime;

  @HiveField(12)
  String? dietaryRestrictions;

  @HiveField(13)
  String? historySummary;

  GPTContext({
    required this.userId,
    this.conversationId,
    this.weight,
    this.bodyFat,
    this.targetBodyFat,
    this.targetMuscleMass,
    this.currentMuscleMass,
    this.sleepHabits,
    this.medications,
    this.availableIngredients,
    this.activityLevel,
    this.availableWorkoutTime,
    this.dietaryRestrictions,
    this.historySummary,
  });

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
    if (historySummary != null && historySummary!.trim().isNotEmpty) {
      buffer.writeln('\n대화 히스토리 요약:\n$historySummary');
    }

    return buffer.toString();
  }
} 