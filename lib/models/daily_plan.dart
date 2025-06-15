import 'package:hive/hive.dart';

part 'daily_plan.g.dart'; // Hive 어댑터 파일 (build_runner로 생성)

@HiveType(typeId: 2)
class DailyPlan extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final List<String> mealPlan;

  @HiveField(2)
  final List<String> workoutPlan;

  @HiveField(3)
  final List<bool> mealDone;

  @HiveField(4)
  final List<bool> workoutDone;

  @HiveField(5)
  final List<double> mealCalories;

  @HiveField(6)
  final List<double> workoutCalories;

  @HiveField(7)
  final String notes;

  DailyPlan({
    required this.date,
    required this.mealPlan,
    required this.workoutPlan,
    required this.mealDone,
    required this.workoutDone,
    required this.mealCalories,
    required this.workoutCalories,
    required this.notes,
  });

  DailyPlan copyWith({
    String? date,
    List<String>? mealPlan,
    List<String>? workoutPlan,
    String? notes,
    List<bool>? mealDone,
    List<bool>? workoutDone,
    List<double>? mealCalories,
    List<double>? workoutCalories,
  }) {
    return DailyPlan(
      date: date ?? this.date,
      mealPlan: mealPlan ?? this.mealPlan,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      notes: notes ?? this.notes,
      mealDone: mealDone ?? this.mealDone,
      workoutDone: workoutDone ?? this.workoutDone,
      mealCalories: mealCalories ?? this.mealCalories,
      workoutCalories: workoutCalories ?? this.workoutCalories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mealPlan': mealPlan,
      'workoutPlan': workoutPlan,
      'notes': notes,
      'mealDone': mealDone,
      'workoutDone': workoutDone,
      'mealCalories': mealCalories,
      'workoutCalories': workoutCalories,
    };
  }

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      date: json['date'] as String,
      mealPlan: List<String>.from(json['mealPlan']),
      workoutPlan: List<String>.from(json['workoutPlan']),
      notes: json['notes'] as String,
      mealDone: List<bool>.from(json['mealDone']),
      workoutDone: List<bool>.from(json['workoutDone']),
      mealCalories: List<double>.from(json['mealCalories']),
      workoutCalories: List<double>.from(json['workoutCalories']),
    );
  }

  @override
  String toString() => 'DailyPlan(${date.split(' ')[0]})';
}