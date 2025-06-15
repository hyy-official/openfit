import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart';
import 'package:openfit/models/gpt_context.dart';

/// 프로필 관리 서비스
/// 
/// UserProfile (고정 정보)와 GPTContext (동적 정보) 간의 동기화를 관리합니다.
/// 
/// 동기화 정책:
/// 1. 초기: UserProfile → GPTContext (일방향 복사)
/// 2. 채팅 중: GPTContext만 업데이트
/// 3. 채팅 종료: GPTContext → UserProfile (선택적 병합, UserProfile 우선)
class ProfileService extends ChangeNotifier {
  static const String _userProfileKey = 'userProfile';
  static const String _gptContextKey = 'userProfile';
  static const String _userProfileBox = 'userProfileBox';
  static const String _gptContextBox = 'gptContextBox';
  static const String _pendingSyncKey = 'pendingSync';
  static const String _pendingSyncBox = 'pendingSyncBox';

  UserProfile? _userProfile;
  GPTContext? _gptContext;
  Map<String, dynamic>? _pendingChanges;
  DateTime? _lastSyncAttempt;

  // Getters
  UserProfile? get userProfile => _userProfile;
  GPTContext? get gptContext => _gptContext;
  bool get hasPendingSync => _pendingChanges?.isNotEmpty ?? false;
  Map<String, dynamic>? get pendingChanges => _pendingChanges;

  /// 서비스 초기화 - 앱 시작 시 호출
  Future<void> initialize() async {
    try {
      print('🚀 ProfileService 초기화 시작');
      await _loadUserProfile();
      await _loadGPTContext();
      await _loadPendingSync();
      
      // 실패한 동기화가 있다면 재시도
      if (hasPendingSync) {
        print('⏳ 이전 동기화 실패 발견 - 재시도 중...');
        await _retryPendingSync();
      }
      print('✅ ProfileService 초기화 완료');
      notifyListeners();
    } catch (e) {
      print('❌ ProfileService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 1. 초기 동기화: UserProfile → GPTContext
  /// 사용자 설정 저장 시 호출
  Future<void> syncUserToContext() async {
    try {
      print('🔄 초기 동기화 시작: UserProfile → GPTContext');
      
      if (_userProfile == null) {
        print('⚠️ UserProfile이 null입니다. 동기화 중단');
        return;
      }

      // GPTContext를 UserProfile로 완전히 덮어쓰기
      final newContext = GPTContext.fromUserProfile('user', _userProfile!);
      
      // 기존 대화 히스토리는 보존
      if (_gptContext?.historySummary != null) {
        newContext.historySummary = _gptContext!.historySummary;
      }

      await _saveGPTContext(newContext);
      _gptContext = newContext;
      
      print('✅ 초기 동기화 완료');
      notifyListeners();
    } catch (e) {
      print('❌ 초기 동기화 실패: $e');
      rethrow;
    }
  }

  /// 2. 채팅 중 GPTContext 업데이트
  Future<void> updateContext(Map<String, dynamic> updates) async {
    try {
      print('📝 GPTContext 업데이트: $updates');
      
      if (_gptContext == null) {
        print('⚠️ GPTContext가 null입니다. 기본 컨텍스트 생성');
        _gptContext = GPTContext(userId: 'user');
      }

      // GPTContext 업데이트
      _gptContext = _updateGPTContextWithMap(_gptContext!, updates);
      await _saveGPTContext(_gptContext!);
      
      print('✅ GPTContext 업데이트 완료');
      notifyListeners();
    } catch (e) {
      print('❌ GPTContext 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 3. 채팅 종료 시 역동기화: GPTContext → UserProfile
  Future<void> syncContextToUser() async {
    try {
      print('🔄 역동기화 시작: GPTContext → UserProfile');
      
      if (_gptContext == null || _userProfile == null) {
        print('⚠️ 필요한 데이터가 없습니다. 동기화 중단');
        return;
      }

      // 변경된 내용만 추출
      final changes = _extractChangesFromContext();
      if (changes.isEmpty) {
        print('📝 변경된 내용이 없습니다.');
        return;
      }

      print('📋 동기화할 변경사항: $changes');

      // UserProfile 업데이트 (기존 값 우선 보존)
      final updatedProfile = _mergeChangesToUserProfile(changes);
      
      await _saveUserProfile(updatedProfile);
      _userProfile = updatedProfile;

      print('✅ 역동기화 완료');
      notifyListeners();
      
    } catch (e) {
      print('❌ 역동기화 실패: $e');
      
      // 실패 시 pending 상태로 저장
      await _savePendingSync(_extractChangesFromContext());
      print('💾 변경사항을 pending으로 저장 - 다음 세션에서 재시도');
    }
  }

  /// 완전한 프로필 정보 반환 (GPT 프롬프트용)
  Map<String, dynamic> getCompleteProfile() {
    final profile = <String, dynamic>{};
    
    // UserProfile 기본 정보
    if (_userProfile != null) {
      profile.addAll(_userProfile!.toJson());
    }
    
    // GPTContext 동적 정보로 덮어쓰기 (최신 정보 우선)
    if (_gptContext != null) {
      final contextData = _gptContext!.toJson();
      contextData.forEach((key, value) {
        if (value != null) {
          profile[key] = value;
        }
      });
    }
    
    return profile;
  }

  // === Private 메서드들 ===

  Future<void> _loadUserProfile() async {
    final box = Hive.box<UserProfile>(_userProfileBox);
    _userProfile = box.get(_userProfileKey);
    print('userProfile: ${_userProfile?.toPrompt()}');
    print('📖 UserProfile 로드: ${_userProfile != null ? "성공" : "없음"}');
  }

  Future<void> _loadGPTContext() async {
    final box = Hive.box<GPTContext>(_gptContextBox);
    _gptContext = box.get(_gptContextKey);
    print('📖 GPTContext 로드: ${_gptContext != null ? "성공" : "없음"}');
  }

  Future<void> _loadPendingSync() async {
    try {
      if (!Hive.isBoxOpen(_pendingSyncBox)) {
        await Hive.openBox(_pendingSyncBox);
      }
      final box = Hive.box(_pendingSyncBox);
      final pendingData = box.get(_pendingSyncKey);
      _pendingChanges = pendingData != null ? Map<String, dynamic>.from(pendingData) : null;
      print('📖 PendingSync 로드: ${_pendingChanges?.length ?? 0}개 항목');
    } catch (e) {
      print('⚠️ PendingSync 로드 실패: $e');
      _pendingChanges = null;
    }
  }

  Future<void> _saveUserProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>(_userProfileBox);
    await box.put(_userProfileKey, profile);
  }

  Future<void> _saveGPTContext(GPTContext context) async {
    final box = Hive.box<GPTContext>(_gptContextBox);
    await box.put(_gptContextKey, context);
  }

  Future<void> _savePendingSync(Map<String, dynamic> changes) async {
    try {
      if (!Hive.isBoxOpen(_pendingSyncBox)) {
        await Hive.openBox(_pendingSyncBox);
      }
      final box = Hive.box(_pendingSyncBox);
      await box.put(_pendingSyncKey, changes);
      _pendingChanges = changes;
    } catch (e) {
      print('⚠️ PendingSync 저장 실패: $e');
    }
  }

  Future<void> _clearPendingSync() async {
    try {
      if (!Hive.isBoxOpen(_pendingSyncBox)) {
        await Hive.openBox(_pendingSyncBox);
      }
      final box = Hive.box(_pendingSyncBox);
      await box.delete(_pendingSyncKey);
      _pendingChanges = null;
    } catch (e) {
      print('⚠️ PendingSync 클리어 실패: $e');
    }
  }

  Future<void> _retryPendingSync() async {
    if (_pendingChanges == null || _pendingChanges!.isEmpty) return;
    
    try {
      final updatedProfile = _mergeChangesToUserProfile(_pendingChanges!);
      await _saveUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      
      await _clearPendingSync();
      print('✅ Pending 동기화 성공');
    } catch (e) {
      print('❌ Pending 동기화 재시도 실패: $e');
      // 실패 시 그대로 두고 다음 기회를 기다림
    }
  }

  GPTContext _updateGPTContextWithMap(GPTContext context, Map<String, dynamic> updates) {
    return context.copyWith(
      weight: updates['weight']?.toDouble(),
      bodyFat: updates['bodyFat']?.toDouble(),
      targetBodyFat: updates['targetBodyFat']?.toDouble(),
      targetMuscleMass: updates['targetMuscleMass']?.toDouble(),
      currentMuscleMass: updates['currentMuscleMass']?.toDouble(),
      sleepHabits: updates['sleepHabits']?.toString(),
      medications: updates['medications'] != null ? List<String>.from(updates['medications']) : null,
      availableIngredients: updates['availableIngredients'] != null ? List<String>.from(updates['availableIngredients']) : null,
      activityLevel: updates['activityLevel']?.toString(),
      availableWorkoutTime: updates['availableWorkoutTime']?.toString(),
      dietaryRestrictions: updates['dietaryRestrictions']?.toString(),
      fitnessGoals: updates['fitnessGoals'] != null ? List<String>.from(updates['fitnessGoals']) : null,
      desiredBodyShapes: updates['desiredBodyShapes'] != null ? List<String>.from(updates['desiredBodyShapes']) : null,
      complexAreas: updates['complexAreas'] != null ? List<String>.from(updates['complexAreas']) : null,
      workoutPreferences: updates['workoutPreferences'] != null ? Map<String, String>.from(updates['workoutPreferences']) : null,
      fitnessLevel: updates['fitnessLevel']?.toString(),
      weeklyWorkoutFrequency: updates['weeklyWorkoutFrequency']?.toString(),
      currentBodyType: updates['currentBodyType']?.toString(),
      historySummary: updates['historySummary']?.toString(),
    );
  }

  Map<String, dynamic> _extractChangesFromContext() {
    if (_gptContext == null) return {};
    
    final changes = <String, dynamic>{};
    final contextJson = _gptContext!.toJson();
    
    // null이 아닌 값들만 변경사항으로 취급
    contextJson.forEach((key, value) {
      if (value != null) {
        // historySummary는 UserProfile로 동기화하지 않음
        if (key != 'historySummary' && key != 'userId' && key != 'conversationId') {
          changes[key] = value;
        }
      }
    });
    
    return changes;
  }

  UserProfile _mergeChangesToUserProfile(Map<String, dynamic> changes) {
    if (_userProfile == null) {
      throw Exception('UserProfile이 없어서 변경사항을 병합할 수 없습니다.');
    }

    // UserProfile에 있는 값은 보존, 없는 값만 GPTContext에서 가져옴
    return _userProfile!.copyWith(
      weight: changes['weight']?.toDouble(),
      bodyFat: changes['bodyFat']?.toDouble(),
      targetBodyFat: changes['targetBodyFat']?.toDouble(),
      targetMuscleMass: changes['targetMuscleMass']?.toDouble(),
      currentMuscleMass: changes['currentMuscleMass']?.toDouble(),
      sleepHabits: changes['sleepHabits']?.toString(),
      medications: changes['medications'] != null ? List<String>.from(changes['medications']) : null,
      availableIngredients: changes['availableIngredients'] != null ? List<String>.from(changes['availableIngredients']) : null,
      activityLevel: changes['activityLevel']?.toString(),
      availableWorkoutTime: changes['availableWorkoutTime']?.toString(),
      dietaryRestrictions: changes['dietaryRestrictions']?.toString(),
      // 고정 정보들은 GPTContext가 변경할 수 없음 (null 전달로 기존 값 유지)
      fitnessGoals: null,
      desiredBodyShapes: null,
      complexAreas: null,
      workoutPreferences: null,
      fitnessLevel: null,
      weeklyWorkoutFrequency: null,
      currentBodyType: null,
    );
  }

  /// UserProfile 저장 (사용자 설정에서 호출)
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      print('💾 UserProfile 저장 시작');
      
      await _saveUserProfile(profile);
      _userProfile = profile;
      
      // 저장 후 자동으로 GPTContext에 동기화
      await syncUserToContext();
      
      print('✅ UserProfile 저장 및 동기화 완료');
      notifyListeners();
    } catch (e) {
      print('❌ UserProfile 저장 실패: $e');
      rethrow;
    }
  }

  /// 수동 동기화 강제 실행 (설정에서 사용)
  Future<void> forceSyncNow() async {
    try {
      print('🔧 수동 동기화 강제 실행');
      await syncContextToUser();
    } catch (e) {
      print('❌ 수동 동기화 실패: $e');
      rethrow;
    }
  }

  /// Pending 변경사항 포기 (설정에서 사용)
  Future<void> discardPendingChanges() async {
    await _clearPendingSync();
    print('🗑️ Pending 변경사항 삭제');
    notifyListeners();
  }
} 