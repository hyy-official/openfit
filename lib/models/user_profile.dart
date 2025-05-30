import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String gender;

  @HiveField(2)
  double weight;

  @HiveField(3)
  double bodyFat;

  @HiveField(4)
  String dietHabit;

  @HiveField(5)
  String goal;

  UserProfile({
    required this.name,
    required this.gender,
    required this.weight,
    required this.bodyFat,
    required this.dietHabit,
    required this.goal,
  });

  String toPrompt() => '''
사용자의 이름은 $name이고, 성별은 $gender입니다.
현재 체중은 ${weight.toStringAsFixed(1)}kg이며 체지방률은 ${bodyFat.toStringAsFixed(1)}%입니다.
$dietHabit
현재 목표는 $goal입니다.
''';
}
