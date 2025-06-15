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
      
      // 🔥 ProfileService와 충돌 방지를 위해 동기화 로직 비활성화
      print('ℹ️ SummaryLoader 동기화 비활성화 - ProfileService가 관리');
      print('   - 현재 UserProfile 운동 목표: ${_userProfile?.fitnessGoals}');
      print('   - 현재 UserProfile 원하는 몸매: ${_userProfile?.desiredBodyShapes}');
      print('   - 현재 UserProfile 운동 취향: ${_userProfile?.workoutPreferences}');
      
      // 동기화 로직 제거 - ProfileService가 담당
      // if (_shouldSynchronize()) {
      //   print('🔄 동기화 조건 충족 - 동기화 실행');
      //   await _synchronizeData();
      // } else {
      //   print('⏭️ 동기화 조건 미충족 - 동기화 건너뜀');
      // }
      
      print('✅ SummaryLoader 로드 완료 (동기화 없음)');
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
           (_gptContext!.dietaryRestrictions != null && _gptContext!.dietaryRestrictions!.isNotEmpty) ||
           // 🔥 새로 추가된 필드들 체크
           (_gptContext!.fitnessGoals != null && _gptContext!.fitnessGoals!.isNotEmpty) ||
           (_gptContext!.desiredBodyShapes != null && _gptContext!.desiredBodyShapes!.isNotEmpty) ||
           (_gptContext!.complexAreas != null && _gptContext!.complexAreas!.isNotEmpty) ||
           (_gptContext!.workoutPreferences != null && _gptContext!.workoutPreferences!.isNotEmpty) ||
           (_gptContext!.fitnessLevel != null && _gptContext!.fitnessLevel!.isNotEmpty) ||
           (_gptContext!.weeklyWorkoutFrequency != null && _gptContext!.weeklyWorkoutFrequency!.isNotEmpty) ||
           (_gptContext!.currentBodyType != null && _gptContext!.currentBodyType!.isNotEmpty);
  }

  Future<void> _loadUserProfile() async {
    final box = Hive.box<UserProfile>('userProfileBox'); 
    final profile = box.get('userProfile');
    
    print('🔍 SummaryLoader._loadUserProfile() - 박스에서 로드된 프로필:');
    print('   - 박스 키 목록: ${box.keys.toList()}');
    print('   - 프로필 존재 여부: ${profile != null}');
    
    if (profile != null) {
      print('   - 운동 목표: ${profile.fitnessGoals}');
      print('   - 원하는 몸매: ${profile.desiredBodyShapes}');
      print('   - 이름: ${profile.name}');
      print('   - 프로필 타입: ${profile.runtimeType}');
      print('   - 운동 취향: ${profile.workoutPreferences}');
      
      // 🔥 중요: List 필드가 비어있다면 경고 출력
      if (profile.fitnessGoals?.isEmpty == true) {
        print('⚠️ 경고: 로드된 프로필의 운동 목표가 비어있습니다!');
      }
      if (profile.desiredBodyShapes?.isEmpty == true) {
        print('⚠️ 경고: 로드된 프로필의 원하는 몸매가 비어있습니다!');
      }
      
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
    
    print('⚠️ _createInitialProfile() 호출됨 - 기존 프로필을 덮어쓸 위험!');
    print('   - GPTContext 존재: ${gptContext != null}');
    
    // 🔥 중요: 기존 프로필이 있는지 다시 한번 확인 - 더 안전하게 처리
    final existingProfile = box.get('userProfile');
    if (existingProfile != null) {
      print('❌ 기존 프로필이 존재하는데 _createInitialProfile()이 호출됨!');
      print('   - 기존 운동 목표: ${existingProfile.fitnessGoals}');
      print('   - 기존 원하는 몸매: ${existingProfile.desiredBodyShapes}');
      print('   - 기존 운동 취향: ${existingProfile.workoutPreferences}');
      _userProfile = existingProfile;
      return; // 기존 프로필을 덮어쓰지 않고 반환
    }
    
    // 정말로 프로필이 없는 경우에만 생성
    print('✅ 기존 프로필이 없음을 확인 - 새로운 초기 프로필 생성');
    _userProfile = UserProfile(
      weight: gptContext?.weight,
      bodyFat: gptContext?.bodyFat,
      targetBodyFat: gptContext?.targetBodyFat,
      targetMuscleMass: gptContext?.targetMuscleMass,
      currentMuscleMass: gptContext?.currentMuscleMass,
      // 🔥 중요: List 필드들은 기본값으로 빈 리스트가 설정됨 (생성자에서 처리)
      // 하지만 이는 새로운 프로필 생성 시에만 발생하므로 데이터 손실이 아님
    );
    
    print('✅ 새로운 초기 프로필 생성 완료');
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
      // 🔥 중요: GPTContext에서 List 필드들을 가져오되, 없으면 기존 값 유지
      fitnessGoals: (_gptContext!.fitnessGoals != null && _gptContext!.fitnessGoals!.isNotEmpty) ? _gptContext!.fitnessGoals : null,
      desiredBodyShapes: (_gptContext!.desiredBodyShapes != null && _gptContext!.desiredBodyShapes!.isNotEmpty) ? _gptContext!.desiredBodyShapes : null,
      complexAreas: (_gptContext!.complexAreas != null && _gptContext!.complexAreas!.isNotEmpty) ? _gptContext!.complexAreas : null,
      workoutPreferences: (_gptContext!.workoutPreferences != null && _gptContext!.workoutPreferences!.isNotEmpty) ? _gptContext!.workoutPreferences : null,
      fitnessLevel: (_gptContext!.fitnessLevel != null && _gptContext!.fitnessLevel!.isNotEmpty) ? _gptContext!.fitnessLevel : null,
      weeklyWorkoutFrequency: (_gptContext!.weeklyWorkoutFrequency != null && _gptContext!.weeklyWorkoutFrequency!.isNotEmpty) ? _gptContext!.weeklyWorkoutFrequency : null,
      currentBodyType: (_gptContext!.currentBodyType != null && _gptContext!.currentBodyType!.isNotEmpty) ? _gptContext!.currentBodyType : null,
      // 나머지 List 필드들은 기존 값 유지
      usualSportsOrInterests: null,
      preferredWorkoutLocations: null,
      dietTypes: null,
      pastWorkoutProblems: null,
      additionalWellnessGoals: null,
      healthConditionsOrInjuries: null,
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
- 현재 체중: ${_gptContext!.weight}kg
- 현재 체지방률: ${_gptContext!.bodyFat}%
- 현재 근육량: ${_gptContext!.currentMuscleMass}kg
- 현재 체형: ${_gptContext!.currentBodyType}
- 목표 체지방률: ${_gptContext!.targetBodyFat}%
- 목표 근육량: ${_gptContext!.targetMuscleMass}kg
- 운동 목표: ${_gptContext!.fitnessGoals?.join(', ')}
- 원하는 체형: ${_gptContext!.desiredBodyShapes?.join(', ')}
- 복합 부위: ${_gptContext!.complexAreas?.join(', ')}
- 운동 레벨: ${_gptContext!.fitnessLevel}
- 주간 운동 빈도: ${_gptContext!.weeklyWorkoutFrequency}
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
