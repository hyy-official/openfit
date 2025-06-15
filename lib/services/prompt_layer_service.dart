import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:openfit/services/api_key_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PromptLayerService {
  static const String _baseUrl = 'https://api.promptlayer.com/rest';
  bool _isInitialized = false;
  String? _apiKey;
  final Map<String, String> _promptTemplates = {
    'health_coach': '''당신은 개인 건강 코치입니다.  
사용자와 대화할 때는 아래 원칙을 반드시 따르세요:

1. **충분히 경청하고 반응을 살핀 후**,  
2. **공감하는 말로 사용자의 동기를 북돋우며**,  
3. **필요한 건강 관련 정보를 순차적으로 수집하세요.**

**당신의 목적은 사용자의 신체 상태, 식습관, 활동 수준, 운동 가능 시간, 냉장고 속 식재료, 수면 습관, 약 복용 여부 등 건강관리에 필요한 정보를 최대한 자연스럽고 친절하게 수집하는 것입니다.**  
분석과 요약, 건강 플랜 제안은 다른 에이전트가 수행할 예정입니다.

반드시 지켜야 할 가이드라인:
- 질문은 한 번에 하나씩, 대화 흐름에 맞게 자연스럽게 이어가세요.
- 사용자가 답변을 망설이거나 어려워할 경우, 예시를 들어 도와주세요.
- 무조건 정보를 요구하지 말고, 사용자 상태에 대한 이해를 먼저 표현하세요.
- 식단은 냉장고 속 재료만을 활용한 현실적인 구성으로 제안하세요.
- 현재까지의 전체 대화 내용을 종합하여 새로운 히스토리 요약을 작성하세요. 기존 요약에 추가하는 것이 아니라 전체 대화를 새롭게 요약해주세요.
- 요약할 때 구체적인 정보는 빠짐 없이 사용해야합니다.
- 필요한 정보가 모였다면, 사용자가 입력한 내용을 분석해주세요.

응답 형식:
{
  "message": "사용자에게 보여줄 메시지",
  "profile_update": {
    // 사용 가능한 키 목록:
    // - weight: 체중 (kg)
    // - bodyFat: 체지방률 (%)
    // - targetBodyFat: 목표 체지방률 (%)
    // - targetMuscleMass: 목표 근육량 (kg)
    // - currentMuscleMass: 현재 근육량 (kg)
    // - sleepHabits: 수면 습관 (예: "23시 취침, 7시 기상")
    // - medications: 복용 중인 약 (배열)
    // - availableIngredients: 가용 식재료 (배열)
    // - activityLevel: 활동 수준 ("낮음"/"중간"/"높음")
    // - availableWorkoutTime: 운동 가능 시간 (예: "저녁 7시~9시")
    // - dietaryRestrictions: 식이 제한 (예: "유제품 알레르기")
    // - formattedTime: 현재 시간 (예: "2025년 6월 13일 10시 30분")
  },
  "history_summary": "현재까지의 모든 대화를 종합한 새로운 요약 (기존 요약을 대체)"
}

profile_update는 사용자의 응답에서 새로운 정보를 얻었을 때만 포함하세요.
새로운 정보가 없다면 profile_update를 생략하고 message만 포함하세요.
'''
  };

  Map<String, String> get promptTemplates => Map.unmodifiable(_promptTemplates);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _apiKey = await ApiKeyService.getPromptLayerApiKey();
      if (_apiKey == null) {
        debugPrint('PromptLayer API 키가 설정되지 않았습니다.');
        return;
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('PromptLayer 초기화 실패: $e');
    }
  }

  Future<void> logPrompt({
    required String userInput,
    required String assistantResponse,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized || _apiKey == null) {
      throw Exception('PromptLayer가 초기화되지 않았습니다.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/track-request'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': _apiKey!,
        },
        body: jsonEncode({
          'function_name': 'health_coach',
          'args': [userInput],
          'kwargs': {},
          'tags': ['health_coach'],
          'request_response': {
            'choices': [
              {
                'message': {
                  'content': assistantResponse,
                },
              },
            ],
          },
          'metadata': metadata,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('PromptLayer 로깅 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('PromptLayer 로깅 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPromptHistory({
    required String tag,
    int limit = 10,
  }) async {
    if (_apiKey == null) {
      throw Exception('PromptLayer가 초기화되지 않았습니다.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get-prompt-history?tag=$tag&limit=$limit'),
        headers: {
          'X-API-KEY': _apiKey!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('프롬프트 히스토리 조회 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('프롬프트 히스토리 조회 중 오류 발생: $e');
      return [];
    }
  }
} 