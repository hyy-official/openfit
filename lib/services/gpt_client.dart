import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GPTClient {
  final String apiKey;

  GPTClient(this.apiKey);
  Future<String> sendMessageWithPrompt(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/responses');
    final inputMessages = [
      {'role': 'system', 'content': prompt},
    ];

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'o4-mini',
        'stream': false,
        'input': inputMessages,
        'reasoning': {'effort': 'medium'},
        'max_output_tokens': 2048,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final outputList = data['output'] as List?;
      if (outputList != null) {
        final message = outputList.firstWhere(
          (e) => e['type'] == 'message',
          orElse: () => null,
        );
        return message?['content']?[0]?['text'] ?? '[응답 없음]';
      } else {
        return '[출력이 비어 있음]';
      }
    } else {
      throw Exception('GPT 요청 실패: ${response.statusCode}\n${response.body}');
    }
  }

  Future<String> sendMessageWithHistory(List<Map<String, String>> history, String systemPrompt) async {
    final url = Uri.parse('https://api.openai.com/v1/responses');
    final inputMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...history,
    ];

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'o4-mini',
        "stream": true,
        'reasoning': {'effort': 'medium'},
        'input': inputMessages,
        'max_output_tokens': 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final outputList = data['output'] as List?;

      if (outputList != null) {
        final message = outputList.firstWhere(
          (e) => e['type'] == 'message',
          orElse: () => null,
        );
        return message?['content']?[0]?['text'] ?? '[응답 없음]';
      } else {
        return '[출력이 비어 있음]';
      }
    } else {
      throw Exception('GPT 요청 실패: ${response.statusCode}\n${response.body}');
    }
  }

  Stream<String> sendMessageWithStream(List<Map<String, String>> history, String systemPrompt) async* {
    final url = Uri.parse('https://api.openai.com/v1/responses');
    final inputMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...history,
    ];

    final request = http.Request("POST", url);
    request.headers.addAll({
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    });

    request.body = jsonEncode({
      'model': 'o4-mini',
      'stream': true,
      'reasoning': {'effort': 'medium'},
      'input': inputMessages,
      'max_output_tokens': 1024,
    });

    final response = await request.send();
    final stream = response.stream.transform(utf8.decoder);

    await for (final chunk in stream) {
      for (final line in const LineSplitter().convert(chunk)) {
        if (line.trim().isEmpty || !line.startsWith('data:')) continue;

        final raw = line.replaceFirst('data:', '').trim();
        if (raw == '[DONE]') return;

        try {
          // JSON incomplete chunk skip (optional fallback)
          if (!raw.endsWith('}') && !raw.endsWith(']')) {
            continue;
          }

          final jsonData = jsonDecode(raw);

          if (jsonData['type'] == 'response.output_item.added' ||
              jsonData['type'] == 'response.output_item.done') {
            final item = jsonData['item'];

            // case 1: item.type == 'text'
            if (item?['type'] == 'text' && item['text'] != null) {
              final text = item['text'];
              yield text;
            }

            // case 2: item.type == 'message' && content 내부에 output_text 목록 존재
            else if (item?['type'] == 'message') {
              final contents = item['content'] as List?;
              if (contents != null) {
                for (final part in contents) {
                  if (part['type'] == 'output_text' && part['text'] != null) {
                    final text = part['text'];
                    yield text;
                  }
                }
              }
            }

            // case 3: item.type == 'reasoning'
            else if (item?['type'] == 'reasoning') {
              print('🧠 reasoning summary: ${item['summary']}');
            }
            else {
              print('⚠️ 처리되지 않은 item 타입: ${item?['type']}');
            }
          }
        } catch (e) {
          yield '[JSON 파싱 오류: $e]';
        }
      }
    }
  }
}
