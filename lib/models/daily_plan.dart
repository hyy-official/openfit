import 'package:hive/hive.dart';

part 'daily_plan.g.dart';

@HiveType(typeId: 4)
class DailyPlan extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  List<String> mealPlan;

  @HiveField(2)
  List<String> workoutPlan;

  @HiveField(3)
  List<bool> mealDone;

  @HiveField(4)
  List<bool> workoutDone;

  DailyPlan({
    required this.date,
    this.mealPlan = const [],
    this.workoutPlan = const [],
    List<bool>? mealDone,
    List<bool>? workoutDone,
  })  : mealDone = mealDone ?? List.filled(mealPlan.length, false),
        workoutDone = workoutDone ?? List.filled(workoutPlan.length, false);
}
