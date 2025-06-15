import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:openfit/models/gpt_context.dart';
import 'package:openfit/services/prompt_layer_service.dart';
import 'package:openfit/services/api_key_service.dart';

class ChatService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  Future<String> getResponse(String userInput, dynamic gptContext, {List<Map<String, String>>? history, String? systemPrompt}) async {
    try {
      final apiKey = await ApiKeyService.getOpenAiApiKey();
      if (apiKey == null) {
        throw Exception('OpenAI API 키가 설정되지 않았습니다.');
      }

      // input 배열 준비
      List<Map<String, dynamic>> inputMessages = [];
      
      // 시스템 프롬프트가 있으면 맨 앞에 추가
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        inputMessages.add({
          'role': 'system',
          'type': 'message',
          'content': systemPrompt
        });
      }
      
      // 히스토리가 있으면 최근 2개의 사용자 메시지만 추가
      if (history != null && history.isNotEmpty) {
        final userMessages = history
            .where((msg) => 
                msg['role'] == 'user' && 
                msg['content'] != null && 
                msg['content']!.trim().isNotEmpty)
            .toList();
        
        // 최근 2개의 사용자 메시지만 가져오기
        final recentUserMessages = userMessages.length > 2 
            ? userMessages.sublist(userMessages.length - 2)
            : userMessages;
            
        for (final msg in recentUserMessages) {
          inputMessages.add({
            'role': 'user',
            'type': 'message',
            'content': msg['content']
          });
        }
      }
      
      // 현재 사용자 입력 추가
      inputMessages.add({
        'role': 'user',
        'type': 'message',
        'content': userInput
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/responses'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "o4-mini",
          "reasoning": {"effort": "medium"},
          "input": inputMessages,
          "max_output_tokens": 4096,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('data: $data');
        // Responses API의 응답 구조에 맞게 수정
        if (data['output'] != null && data['output'] is List) {
          // output 배열에서 message 타입 찾기
          for (final output in data['output']) {
            if (output['type'] == 'message' && output['content'] != null) {
              if (output['content'] is List && output['content'].isNotEmpty) {
                return output['content'][0]['text'] ?? '';
              } else if (output['content'] is String) {
                return output['content'];
              }
            }
          }
        }
        return '응답 파싱 실패';
      } else {
        throw Exception('API 요청 실패: ${response.statusCode}\n응답: ${response.body}');
      }
    } catch (e) {
      debugPrint('ChatService 오류: $e');
      rethrow;
    }
  }

  Future<String> sendMessageWithPrompt(String prompt) async {
    try {
      final apiKey = await ApiKeyService.getOpenAiApiKey();
      if (apiKey == null) {
        throw Exception('OpenAI API 키가 설정되지 않았습니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('메시지 전송 중 오류 발생: $e');
      rethrow;
    }
  }

  Stream<String> sendMessageWithStream(List<Map<String, String>> history, String prompt) async* {
    try {
      debugPrint('history: $history');
      final apiKey = await ApiKeyService.getOpenAiApiKey();
      if (apiKey == null) {
        throw Exception('OpenAI API 키가 설정되지 않았습니다.');
      }

      final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
      request.headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      });
      request.body = jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          ...history,
          {'role': 'user', 'content': prompt},
        ],
        'stream': true,
      });

      final streamedResponse = await request.send();
      final stream = streamedResponse.stream.transform(utf8.decoder);
      
      await for (final chunk in stream) {
        for (final line in const LineSplitter().convert(chunk)) {
          if (line.trim().isEmpty || !line.startsWith('data:')) continue;

          final raw = line.replaceFirst('data:', '').trim();
          if (raw == '[DONE]') return;

          try {
            final json = jsonDecode(raw);
            final content = json['choices'][0]['delta']['content'];
            if (content != null) {
              yield content;
            }
          } catch (e) {
            debugPrint('JSON 파싱 오류: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('메시지 전송 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<ChatService> createGPTClientFromProfile() async {
    // 단순히 현재 인스턴스를 반환 (API 키는 이미 ApiKeyService에서 관리됨)
    return this;
  }
} 