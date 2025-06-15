import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfit/models/flexible_gpt_context.dart';
import 'package:openfit/models/gpt_context.dart';
import 'package:openfit/services/flexible_json_agent_service.dart';

void main() {
  group('FlexibleGPTContext 테스트', () {
    test('기본 생성 및 데이터 접근', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        conversationId: 'conv456',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
          'fitnessGoals': ['근육 증가', '체지방 감소'],
        }),
      );

      expect(context.userId, 'user123');
      expect(context.conversationId, 'conv456');
      expect(context.getValue<double>('weight'), 70.5);
      expect(context.getValue<double>('bodyFat'), 15.2);
      expect(context.getValue<List>('fitnessGoals'), ['근육 증가', '체지방 감소']);
    });

    test('setValue 메서드로 데이터 업데이트', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({}),
      );

      // 새로운 값 설정
      context.setValue('weight', 75.0);
      context.setValue('activityLevel', '활발함');
      context.setValue('customField', '사용자 정의 필드');

      expect(context.getValue<double>('weight'), 75.0);
      expect(context.getValue<String>('activityLevel'), '활발함');
      expect(context.getValue<String>('customField'), '사용자 정의 필드');

      // null 값으로 삭제
      context.setValue<double>('weight', null);
      expect(context.getValue<double>('weight'), null);
    });

    test('기존 GPTContext와의 변환', () {
      // 기존 GPTContext 생성
      final originalContext = GPTContext(
        userId: 'user123',
        conversationId: 'conv456',
        weight: 70.5,
        bodyFat: 15.2,
        fitnessGoals: ['근육 증가', '체지방 감소'],
        workoutPreferences: {'헬스장': '좋아함', '홈트': '보통'},
      );

      // FlexibleGPTContext로 변환
      final flexibleContext = FlexibleGPTContext.fromGPTContext(originalContext);

      expect(flexibleContext.userId, 'user123');
      expect(flexibleContext.conversationId, 'conv456');
      expect(flexibleContext.getValue<double>('weight'), 70.5);
      expect(flexibleContext.getValue<double>('bodyFat'), 15.2);
      expect(flexibleContext.getValue<List>('fitnessGoals'), ['근육 증가', '체지방 감소']);
      expect(flexibleContext.getValue<Map>('workoutPreferences'), {'헬스장': '좋아함', '홈트': '보통'});

      // 다시 GPTContext로 변환
      final convertedBack = flexibleContext.toGPTContext();

      expect(convertedBack.userId, 'user123');
      expect(convertedBack.weight, 70.5);
      expect(convertedBack.bodyFat, 15.2);
      expect(convertedBack.fitnessGoals, ['근육 증가', '체지방 감소']);
      expect(convertedBack.workoutPreferences, {'헬스장': '좋아함', '홈트': '보통'});
    });

    test('동적 필드 추가', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
        }),
      );

      // 동적으로 새로운 필드들 추가
      context.setValue('favoriteExercise', '스쿼트');
      context.setValue('workoutDays', ['월', '수', '금']);
      context.setValue('supplementInfo', {
        'protein': '웨이 프로틴',
        'creatine': '크레아파이브',
      });

      expect(context.getValue<String>('favoriteExercise'), '스쿼트');
      expect(context.getValue<List>('workoutDays'), ['월', '수', '금']);
      expect(context.getValue<Map>('supplementInfo'), {
        'protein': '웨이 프로틴',
        'creatine': '크레아파이브',
      });
    });

    test('GPT 응답으로 업데이트', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
        }),
      );

      // GPT 응답 시뮬레이션
      final gptResponse = {
        'weight': 72.0, // 업데이트된 값
        'targetBodyFat': 12.0, // 새로운 필드
        'workoutPlan': '주 3회 근력운동', // 동적 필드
      };

      context.updateFromGPTResponse(gptResponse);

      expect(context.getValue<double>('weight'), 72.0);
      expect(context.getValue<double>('bodyFat'), 15.2); // 기존 값 유지
      expect(context.getValue<double>('targetBodyFat'), 12.0);
      expect(context.getValue<String>('workoutPlan'), '주 3회 근력운동');
    });

    test('키 목록 및 중복 방지 기능', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
          'customField': '사용자 정의',
        }),
      );

      // 모든 키 가져오기
      final allKeys = context.getAllKeys();
      expect(allKeys, 'weight, bodyFat, customField');

      // 키 존재 확인
      expect(context.hasKey('weight'), true);
      expect(context.hasKey('nonExistentKey'), false);

      // 프롬프트용 키 정보
      final keysPrompt = context.getKeysForPrompt();
      expect(keysPrompt.contains('weight: (설명 없음)'), true);
      expect(keysPrompt.contains('bodyFat: (설명 없음)'), true);
      expect(keysPrompt.contains('customField: (설명 없음)'), true);

      // 유사한 키 찾기
      final similarToWeight = context.findSimilarKeys('몸무게');
      // 완전히 다른 단어이므로 찾지 못할 수 있음
      
      final similarToWeight2 = context.findSimilarKeys('weigh');
      expect(similarToWeight2.contains('weight'), true);
    });

    test('키 설명 관리 기능', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({}),
      );

      // 값과 설명을 함께 설정
      context.setValue('weight', 70.5, description: '사용자의 현재 체중 (kg)');
      context.setValue('bodyFat', 15.2, description: '현재 체지방률 (%)');

      // 설명 확인
      expect(context.getKeyDescription('weight'), '사용자의 현재 체중 (kg)');
      expect(context.getKeyDescription('bodyFat'), '현재 체지방률 (%)');
      expect(context.getKeyDescription('nonExistent'), null);

      // 키와 설명을 함께 가져오기
      final keysWithDescriptions = context.getAllKeysWithDescriptions();
      expect(keysWithDescriptions['weight'], '사용자의 현재 체중 (kg)');
      expect(keysWithDescriptions['bodyFat'], '현재 체지방률 (%)');

      // 프롬프트용 키 정보 (설명 포함)
      final keysPrompt = context.getKeysForPrompt();
      expect(keysPrompt.contains('weight: 사용자의 현재 체중 (kg)'), true);
      expect(keysPrompt.contains('bodyFat: 현재 체지방률 (%)'), true);

      // 키 설명 개별 설정
      context.setKeyDescription('weight', '업데이트된 체중 설명');
      expect(context.getKeyDescription('weight'), '업데이트된 체중 설명');

      // 값 삭제 시 설명도 함께 삭제
      context.setValue<double>('weight', null);
      expect(context.getValue<double>('weight'), null);
      expect(context.getKeyDescription('weight'), null);
    });
  });

  group('FlexibleJsonAgentService 테스트', () {
    test('프롬프트 생성', () {
      final context = FlexibleGPTContext(
        userId: 'user123',
        conversationId: 'conv456',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
          'fitnessGoals': ['근육 증가', '체지방 감소'],
          'customField': '사용자 정의 정보',
        }),
      );

      final prompt = FlexibleJsonAgentService.generateStructuredPrompt(context);

      expect(prompt.contains('사용자 ID: user123'), true);
      expect(prompt.contains('대화 ID: conv456'), true);
      expect(prompt.contains('체중: 70.5kg'), true);
      expect(prompt.contains('체지방률: 15.2%'), true);
      expect(prompt.contains('운동 목표: 근육 증가, 체지방 감소'), true);
      expect(prompt.contains('customField: 사용자 정의 정보'), true);
    });

    test('스키마 유효성 검사', () {
      final validContext = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'fitnessGoals': ['근육 증가'],
        }),
      );

      final invalidContext = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': '잘못된 타입', // 숫자가 아닌 문자열
        }),
      );

      expect(FlexibleJsonAgentService.validateSchema(validContext), true);
      expect(FlexibleJsonAgentService.validateSchema(invalidContext), false);
    });

    test('컨텍스트 차이점 분석', () {
      final oldContext = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
          'oldField': '삭제될 필드',
        }),
      );

      final newContext = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 72.0, // 변경됨
          'bodyFat': 15.2, // 동일
          'newField': '새로운 필드', // 추가됨
          // oldField는 삭제됨
        }),
      );

      final differences = FlexibleJsonAgentService.getContextDifferences(oldContext, newContext);

      expect(differences['weight'], {
        'old': 70.5,
        'new': 72.0,
      });
      expect(differences['oldField'], {
        'old': '삭제될 필드',
        'new': null,
      });
      expect(differences['newField'], {
        'old': null,
        'new': '새로운 필드',
      });
      expect(differences.containsKey('bodyFat'), false); // 변경되지 않음
    });
  });

  group('실제 사용 시나리오', () {
    test('사용자 입력을 통한 프로필 업데이트 시뮬레이션', () async {
      // 초기 컨텍스트
      final context = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
        }),
      );

      // 사용자 입력 시뮬레이션
      final userInput = '목표 체지방률을 12%로 설정하고 싶어요. 그리고 매일 30분씩 운동할 예정입니다.';

      // GPT를 통한 업데이트 (시뮬레이션)
      final updatedContext = await FlexibleJsonAgentService.updateProfileWithGPT(context, userInput);

      // 업데이트 확인
      expect(updatedContext.getValue<double>('weight'), 70.5); // 기존 값 유지
      expect(updatedContext.getValue<double>('targetBodyFat'), 12.0); // GPT 응답에서 설정됨
      expect(updatedContext.getValue<String>('activityLevel'), '활발함'); // GPT 응답에서 설정됨
      expect(updatedContext.getValue<String>('workoutFrequency'), '주 3회'); // 새로운 필드 추가됨
      
      // 키 설명도 함께 저장되었는지 확인
      expect(updatedContext.getKeyDescription('weight'), '사용자의 현재 체중 (kg)');
      expect(updatedContext.getKeyDescription('targetBodyFat'), '목표 체지방률 (%)');
      expect(updatedContext.getKeyDescription('workoutFrequency'), '주간 운동 빈도');
    });

    test('컨텍스트 병합', () {
      final context1 = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'weight': 70.5,
          'bodyFat': 15.2,
        }),
      );

      final context2 = FlexibleGPTContext(
        userId: 'user123',
        jsonPayload: jsonEncode({
          'targetBodyFat': 12.0,
          'fitnessGoals': ['근육 증가'],
        }),
      );

      final mergedContext = FlexibleJsonAgentService.mergeContexts([context1, context2]);

      expect(mergedContext.getValue<double>('weight'), 70.5);
      expect(mergedContext.getValue<double>('bodyFat'), 15.2);
      expect(mergedContext.getValue<double>('targetBodyFat'), 12.0);
      expect(mergedContext.getValue<List>('fitnessGoals'), ['근육 증가']);
    });
  });
} 