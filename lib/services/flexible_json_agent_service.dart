import 'dart:convert';
import 'package:openfit/models/flexible_gpt_context.dart';

class FlexibleJsonAgentService {
    // GPT API 호출 시뮬레이션 (실제로는 OpenAI API를 사용)
  static Future<Map<String, dynamic>> _simulateGPTCall(String prompt) async {
    // 시뮬레이션용 응답 - 실제로는 GPT API 호출
    await Future.delayed(Duration(seconds: 2));
    
    return {
      'data': {
        'weight': 70.5,
        'bodyFat': 15.2,
        'targetBodyFat': 12.0,
        'fitnessGoals': ['근육 증가', '체지방 감소'],
        'activityLevel': '활발함',
        'workoutFrequency': '주 3회',
      },
      'keyDescriptions': {
        'weight': '사용자의 현재 체중 (kg)',
        'bodyFat': '현재 체지방률 (%)',
        'targetBodyFat': '목표 체지방률 (%)',
        'fitnessGoals': '운동 목표 리스트',
        'activityLevel': '일상 활동 수준',
        'workoutFrequency': '주간 운동 빈도',
      }
    };
  }

  /// GPT를 통해 프로필 업데이트 (키 중복 방지 포함)
  static Future<FlexibleGPTContext> updateProfileWithGPT(
    FlexibleGPTContext context,
    String userInput,
  ) async {
    // 현재 컨텍스트를 프롬프트로 변환
    final currentPrompt = context.toPrompt();
    
    // 기존 키 목록 가져오기
    final keysPrompt = context.getKeysForPrompt();
    
    // GPT에게 보낼 전체 프롬프트 구성
    final fullPrompt = '''
현재 사용자 프로필:
$currentPrompt

$keysPrompt

사용자 입력: "$userInput"

위 정보를 바탕으로 사용자 프로필을 업데이트해주세요. 
변경된 또는 새로운 필드들을 JSON 형태로 반환해주세요.

⚠️ 중요 지침:
1. 위 키들과 동일한 의미의 새로운 키를 만들지 마세요
2. 기존 키가 있다면 반드시 해당 키를 사용하여 값을 업데이트하세요
3. 새로운 정보는 명확하고 구체적인 키 이름을 사용하세요
4. 영어 키 이름을 사용하되, 의미가 명확하게 전달되도록 작성하세요
5. 새로운 키를 만들 때는 반드시 키에 대한 설명도 함께 제공하세요

응답 형식:
{
  "data": {
    "field1": "value1",
    "field2": "value2"
  },
  "keyDescriptions": {
    "field1": "field1에 대한 한국어 설명",
    "field2": "field2에 대한 한국어 설명"
  }
}
''';

    // GPT 호출
    final gptResponse = await _simulateGPTCall(fullPrompt);
    
    // 응답 검증 (중복 키 체크)
    final validatedData = _validateGPTResponse(context, gptResponse['data'] ?? {});
    final descriptions = gptResponse['keyDescriptions'] as Map<String, dynamic>? ?? {};
    final validatedDescriptions = Map<String, String>.from(descriptions);
    
    // 컨텍스트 업데이트
    final updatedContext = context.copyWith();
    updatedContext.updateFromGPTResponse(validatedData, keyDescriptions: validatedDescriptions);
    
    return updatedContext;
  }

  /// GPT 응답 검증 (중복 키 방지)
  static Map<String, dynamic> _validateGPTResponse(
    FlexibleGPTContext context, 
    Map<String, dynamic> gptResponse
  ) {
    final validatedResponse = <String, dynamic>{};
    
    gptResponse.forEach((newKey, value) {
      // 기존 키와 유사한 키가 있는지 확인(레벤슈타인 거리 기반)
      final similarKeys = context.findSimilarKeys(newKey);
      
      if (similarKeys.isNotEmpty) {
        // 유사한 키가 있다면 첫 번째 기존 키를 사용
        final existingKey = similarKeys.first;
        validatedResponse[existingKey] = value;
        
        print('⚠️ 키 중복 방지: "$newKey" -> "$existingKey" 사용');
      } else {
        // 새로운 키 사용
        validatedResponse[newKey] = value;
      }
    });
    
    return validatedResponse;
  }

  /// 특정 필드만 업데이트
  static Future<FlexibleGPTContext> updateSpecificFields(
    FlexibleGPTContext context,
    Map<String, dynamic> updates,
  ) async {
    final updatedContext = context.copyWith();
    updates.forEach((key, value) {
      updatedContext.setValue(key, value);
    });
    
    return updatedContext;
  }

  /// 스키마 유효성 검사 (선택적)
  static bool validateSchema(FlexibleGPTContext context) {
    final data = context.data;
    
    // 필수 필드들 검사
    final requiredFields = ['userId'];
    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        return false;
      }
    }
    
    // 타입 검사
    if (data['weight'] != null && data['weight'] is! num) {
      return false;
    }
    
    if (data['fitnessGoals'] != null && data['fitnessGoals'] is! List) {
      return false;
    }
    
    return true;
  }

  /// GPT용 구조화된 프롬프트 생성
  static String generateStructuredPrompt(FlexibleGPTContext context) {
    final data = context.data;
    final buffer = StringBuffer();
    
    buffer.writeln('=== 사용자 프로필 ===');
    buffer.writeln('\n=== 신체 정보 ===');
    _appendIfExists(buffer, data, 'weight', '체중', 'kg');
    _appendIfExists(buffer, data, 'bodyFat', '체지방률', '%');
    _appendIfExists(buffer, data, 'currentMuscleMass', '현재 근육량', 'kg');
    _appendIfExists(buffer, data, 'targetBodyFat', '목표 체지방률', '%');
    _appendIfExists(buffer, data, 'targetMuscleMass', '목표 근육량', 'kg');
    
    buffer.writeln('\n=== 운동 정보 ===');
    _appendIfExists(buffer, data, 'fitnessLevel', '체력 수준');
    _appendIfExists(buffer, data, 'activityLevel', '활동 수준');
    _appendIfExists(buffer, data, 'weeklyWorkoutFrequency', '주간 운동 빈도');
    _appendIfExists(buffer, data, 'availableWorkoutTime', '운동 가능 시간');
    
    if (data['fitnessGoals'] != null) {
      buffer.writeln('운동 목표: ${(data['fitnessGoals'] as List).join(', ')}');
    }
    
    if (data['workoutPreferences'] != null) {
      buffer.writeln('운동 취향:');
      (data['workoutPreferences'] as Map).forEach((type, preference) {
        buffer.writeln('  $type: $preference');
      });
    }
    
    buffer.writeln('\n=== 생활 패턴 ===');
    _appendIfExists(buffer, data, 'sleepHabits', '수면 습관');
    _appendIfExists(buffer, data, 'dietaryRestrictions', '식이 제한');
    
    if (data['medications'] != null && (data['medications'] as List).isNotEmpty) {
      buffer.writeln('복용 중인 약: ${(data['medications'] as List).join(', ')}');
    }
    
    if (data['availableIngredients'] != null && (data['availableIngredients'] as List).isNotEmpty) {
      buffer.writeln('가용 식재료: ${(data['availableIngredients'] as List).join(', ')}');
    }
    
    // 위에서 다루지 않은 모든 추가 필드들
    final coveredFields = {
      'weight', 'bodyFat', 'currentMuscleMass', 'targetBodyFat', 'targetMuscleMass',
      'fitnessLevel', 'activityLevel', 'weeklyWorkoutFrequency', 'availableWorkoutTime',
      'fitnessGoals', 'workoutPreferences', 'sleepHabits', 'dietaryRestrictions',
      'medications', 'availableIngredients', 'desiredBodyShapes', 'complexAreas',
      'historySummary', 'currentBodyType'
    };
    
    final additionalFields = data.keys.where((key) => !coveredFields.contains(key)).toList();
    if (additionalFields.isNotEmpty) {
      buffer.writeln('\n=== 기타 정보 ===');
      for (final key in additionalFields) {
        buffer.writeln('$key: ${data[key]}');
      }
    }
    
    return buffer.toString();
  }

  static void _appendIfExists(StringBuffer buffer, Map<String, dynamic> data, String key, String label, [String? unit]) {
    if (data[key] != null) {
      final value = data[key];
      final unitStr = unit != null ? unit : '';
      buffer.writeln('$label: $value$unitStr');
    }
  }

  /// 컨텍스트 병합 (여러 소스에서 온 데이터 통합)
  static FlexibleGPTContext mergeContexts(List<FlexibleGPTContext> contexts) {
    if (contexts.isEmpty) {
      throw ArgumentError('적어도 하나의 컨텍스트가 필요합니다');
    }
    
    final baseContext = contexts.first;
    final mergedData = Map<String, dynamic>.from(baseContext.data);
    
    for (int i = 1; i < contexts.length; i++) {
      final currentData = contexts[i].data;
      currentData.forEach((key, value) {
        if (value != null) {
          mergedData[key] = value;
        }
      });
    }
    
    return FlexibleGPTContext(
      userId: baseContext.userId,
      conversationId: baseContext.conversationId,
      jsonPayload: jsonEncode(mergedData),
    );
  }

  /// 컨텍스트 차이점 분석
  static Map<String, dynamic> getContextDifferences(
    FlexibleGPTContext oldContext,
    FlexibleGPTContext newContext,
  ) {
    final oldData = oldContext.data;
    final newData = newContext.data;
    final differences = <String, dynamic>{};
    
    // 변경된 필드들
    newData.forEach((key, newValue) {
      final oldValue = oldData[key];
      if (oldValue != newValue) {
        differences[key] = {
          'old': oldValue,
          'new': newValue,
        };
      }
    });
    
    // 삭제된 필드들
    oldData.forEach((key, oldValue) {
      if (!newData.containsKey(key)) {
        differences[key] = {
          'old': oldValue,
          'new': null,
        };
      }
    });
    
    return differences;
  }
} 