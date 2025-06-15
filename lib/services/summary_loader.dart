import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart';
import 'package:openfit/models/gpt_context.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class SummaryLoader extends ChangeNotifier {
  static const String _userProfileKey = 'userProfile';
  static const String _userProfileBox = 'userProfileBox';
  static const String _gptContextBox = 'gptContextBox';

  UserProfile? _userProfile;
  GPTContext? _gptContext;
  DateTime? _lastContextUpdate;

  UserProfile? get userProfile => _userProfile;
  GPTContext? get gptContext => _gptContext;
  DateTime? get lastContextUpdate => _lastContextUpdate;

  bool isContextUpdated() {
    if (_lastContextUpdate == null) return false;
    return DateTime.now().difference(_lastContextUpdate!).inMinutes < 5;
  }

  String getContextUpdateStatus() {
    if (_lastContextUpdate == null) return '업데이트 없음';
    final difference = DateTime.now().difference(_lastContextUpdate!);
    if (difference.inMinutes < 1) {
      return '방금 전 업데이트';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전 업데이트';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전 업데이트';
    } else {
      return '${difference.inDays}일 전 업데이트';
    }
  }

  Future<void> loadData() async {
    try {
      await _loadUserProfile();
      await _loadGPTContext();
      
      // 🚫 데이터 동기화 비활성화 - UserProfile 설정이 GPTContext에 의해 덮어써지는 문제 방지
      // GPTContext는 채팅 중 동적으로 업데이트되는 값들(체중, 체지방 등)만 관리하고
      // UserProfile의 고정 설정들(운동 목표, 선호도 등)은 건드리지 않음
      print('ℹ️ GPTContext-UserProfile 동기화 건너뜀 - 사용자 설정 보존');
      
      // 향후 필요시 수동으로 특정 상황에서만 동기화할 수 있도록 메소드는 보존
      // if (_shouldSynchronize() && _userShouldUpdate()) {
      //   await _synchronizeData();
      // }
    } catch (e) {
      print('데이터 로드 중 오류가 발생했습니다: $e');
      rethrow;
    }
  }
  
  // GPTContext에 의미있는 데이터가 있는지 확인
  bool _shouldSynchronize() {
    if (_gptContext == null) return false;
    
    // GPTContext에 실제로 업데이트된 데이터가 있는지 확인
    return _gptContext!.weight != null ||
           _gptContext!.bodyFat != null ||
           _gptContext!.targetBodyFat != null ||
           _gptContext!.targetMuscleMass != null ||
           (_gptContext!.sleepHabits != null && _gptContext!.sleepHabits!.isNotEmpty) ||
           (_gptContext!.medications != null && _gptContext!.medications!.isNotEmpty) ||
           (_gptContext!.availableIngredients != null && _gptContext!.availableIngredients!.isNotEmpty) ||
           (_gptContext!.activityLevel != null && _gptContext!.activityLevel!.isNotEmpty) ||
           (_gptContext!.availableWorkoutTime != null && _gptContext!.availableWorkoutTime!.isNotEmpty) ||
           (_gptContext!.dietaryRestrictions != null && _gptContext!.dietaryRestrictions!.isNotEmpty);
  }

  Future<void> _loadUserProfile() async {
    final box = Hive.box<UserProfile>('userProfileBox'); 
    final profile = box.get('userProfile');
    
    print('🔍 SummaryLoader._loadUserProfile() - 박스에서 로드된 프로필:');
    if (profile != null) {
      print('   - 운동 목표: ${profile.fitnessGoals}');
      print('   - 원하는 몸매: ${profile.desiredBodyShapes}');
      print('   - 이름: ${profile.name}');
      _userProfile = profile;
    } else {
      print('   - 프로필이 null이므로 초기 프로필 생성');
      await _createInitialProfile();
    }
  }

  Future<void> _createInitialProfile() async {
    final gptBox = Hive.box<GPTContext>('gptContextBox');
    final gptContext = gptBox.get('userProfile');
    final box = Hive.box<UserProfile>('userProfileBox');
    
    _userProfile = UserProfile(
      weight: gptContext?.weight,
      bodyFat: gptContext?.bodyFat,
      targetBodyFat: gptContext?.targetBodyFat,
      targetMuscleMass: gptContext?.targetMuscleMass,
      // List 필드들은 기본값으로 빈 리스트가 설정됨 (생성자에서 처리)
    );
    
    await box.put(_userProfileKey, _userProfile!);
  }

  Future<void> _loadGPTContext() async {
    final box = Hive.box<GPTContext>('gptContextBox');
    var context = box.get(_userProfileKey);

    if (context == null) {
      // 빈 값으로 초기화
      context = GPTContext(userId: 'user');
      await box.put(_userProfileKey, context);
    }
    _gptContext = context;
    _lastContextUpdate = DateTime.now();
  }

  Future<void> _synchronizeData() async {
    if (_gptContext == null || _userProfile == null) return;

    final box = Hive.box<UserProfile>('userProfileBox');
    
    // GPTContext에 값이 있을 때만 업데이트, 없으면 기존 UserProfile 값 유지
    // copyWith에서는 null이 아닌 경우에만 값을 전달
    final updatedProfile = _userProfile!.copyWith(
      weight: _gptContext!.weight,  // null이면 copyWith에서 기존 값 유지
      bodyFat: _gptContext!.bodyFat,
      targetBodyFat: _gptContext!.targetBodyFat,
      targetMuscleMass: _gptContext!.targetMuscleMass,
      sleepHabits: (_gptContext!.sleepHabits != null && _gptContext!.sleepHabits!.isNotEmpty) ? _gptContext!.sleepHabits : null,
      medications: (_gptContext!.medications != null && _gptContext!.medications!.isNotEmpty) ? _gptContext!.medications : null,
      availableIngredients: (_gptContext!.availableIngredients != null && _gptContext!.availableIngredients!.isNotEmpty) ? _gptContext!.availableIngredients : null,
      activityLevel: (_gptContext!.activityLevel != null && _gptContext!.activityLevel!.isNotEmpty) ? _gptContext!.activityLevel : null,
      availableWorkoutTime: (_gptContext!.availableWorkoutTime != null && _gptContext!.availableWorkoutTime!.isNotEmpty) ? _gptContext!.availableWorkoutTime : null,
      dietaryRestrictions: (_gptContext!.dietaryRestrictions != null && _gptContext!.dietaryRestrictions!.isNotEmpty) ? _gptContext!.dietaryRestrictions : null,
      // fitnessGoals, desiredBodyShapes, complexAreas 등은 명시적으로 null로 전달하여 기존 값 유지
    );
    
    print('🔄 데이터 동기화 - GPTContext에서 업데이트된 필드만 반영');
    print('   - 기존 운동 목표 유지: ${_userProfile!.fitnessGoals}');
    print('   - 기존 원하는 몸매 유지: ${_userProfile!.desiredBodyShapes}');
    
    await box.put(_userProfileKey, updatedProfile);
    _userProfile = updatedProfile;
    _lastContextUpdate = DateTime.now();
    notifyListeners();
  }

  Future<String> loadSummariesAsPrompt({bool forceUserProfile = false}) async {
    if (_userProfile == null) {
      throw Exception('사용자 프로필이 초기화되지 않았습니다.');
    }

    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(now);

    if (!forceUserProfile) {
      return '''
사용자 최신 정보:
- 체중: ${_gptContext!.weight}kg
- 체지방률: ${_gptContext!.bodyFat}%
- 근육량: ${_gptContext!.currentMuscleMass}kg
- 목표 체지방률: ${_gptContext!.targetBodyFat}%
- 목표 근육량: ${_gptContext!.targetMuscleMass}kg
- 수면 습관: ${_gptContext!.sleepHabits}
- 복용 중인 약: ${_gptContext!.medications?.join(', ')}
- 가용 식재료: ${_gptContext!.availableIngredients?.join(', ')}
- 활동 수준: ${_gptContext!.activityLevel}
- 운동 가능 시간: ${_gptContext!.availableWorkoutTime}
- 식이 제한: ${_gptContext!.dietaryRestrictions}
- 현재 시간: $formattedTime
''';
    } else {
      return '''
사용자 초기 정보:
- 이름: ${_userProfile!.name}
- 성별: ${_userProfile!.gender}
- 나이: ${_userProfile!.age}세
- 키: ${_userProfile!.height}cm
- 체중: ${_userProfile!.weight}kg
- 체지방률: ${_userProfile!.bodyFat}%
- 근육량: ${_userProfile!.currentMuscleMass}kg
- 목표 체중: ${_userProfile!.targetWeight}kg
- 목표 체지방률: ${_userProfile!.targetBodyFat}%
- 목표 근육량: ${_userProfile!.targetMuscleMass}kg
- 운동 목표: ${_userProfile!.fitnessGoals?.join(', ')}
- 원하는 체형: ${_userProfile!.desiredBodyShapes?.join(', ')}
- 현재 체형: ${_userProfile!.currentBodyType}
- 복합 부위: ${_userProfile!.complexAreas?.join(', ')}
- 운동 레벨: ${_userProfile!.fitnessLevel}
- 주간 운동 빈도: ${_userProfile!.weeklyWorkoutFrequency}
- 현재 시간: $formattedTime
''';
    }
  }
}
