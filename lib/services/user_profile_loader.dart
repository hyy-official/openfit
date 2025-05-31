import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart';


Future<String> loadUserProfileAsPrompt() async {
  final now = DateTime.now();
  final box = await Hive.openBox<UserProfile>('userProfileBox');
  final profile = box.get('main');
  final formattedTime = '${now.year}년 ${now.month}월 ${now.day}일 ${now.hour}시 ${now.minute}분';

  if (profile == null) return '';

  return '''
당신은 개인 건강 코치입니다. 아래는 사용자의 프로필 정보입니다:
- 현재 날짜와 시간: $formattedTime 기준입니다.
- 이름: ${profile.name}
- 성별: ${profile.gender}
- 체중: ${profile.weight}kg
- 체지방률: ${profile.bodyFat}%
- 목표: ${profile.goal}
- 식단 성향: ${profile.dietHabit}

이 정보를 바탕으로 사용자에게 맞춤형으로 건강 상담을 진행해주세요.
''';
}
