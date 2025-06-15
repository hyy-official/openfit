// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get explore => 'Explore';

  @override
  String get menuFitness => 'Fitness';

  @override
  String get menuNutrition => 'Nutrition';

  @override
  String get menuCalender => 'Calender';

  @override
  String get menuChat => 'Start Chat';

  @override
  String get personal => 'My body';

  @override
  String get startConsultation => 'Start AI Consultation';

  @override
  String helloUser(Object userName) {
    return 'Hello, $userName!';
  }

  @override
  String todayDate(Object date) {
    return 'Today\'s Date: $date';
  }

  @override
  String get recentWorkouts => 'Recent Workouts';

  @override
  String get recentMeals => 'Recent Meals';

  @override
  String get weightGraph => 'Weight Change Graph';
}
