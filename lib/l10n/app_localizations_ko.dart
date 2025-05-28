// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get explore => '탐색';

  @override
  String get menuFitness => '운동';

  @override
  String get menuNutrition => '영양';

  @override
  String get menuWeight => '체중 관리';

  @override
  String get menuChat => '채팅 시작';

  @override
  String get startConsultation => 'AI 상담 시작하기';

  @override
  String helloUser(Object userName) {
    return '$userName님, 안녕하세요!';
  }

  @override
  String todayDate(Object date) {
    return '오늘 날짜: $date';
  }

  @override
  String get recentWorkouts => '최근 운동';

  @override
  String get recentMeals => '최근 식사';

  @override
  String get weightGraph => '체중 변화 그래프';
}
