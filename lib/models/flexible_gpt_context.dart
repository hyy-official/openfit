import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:openfit/models/gpt_context.dart';
import 'package:openfit/models/user_profile.dart';

part 'flexible_gpt_context.g.dart';

@HiveType(typeId: 4) // GPTContext가 typeId: 3이므로 4 사용
class FlexibleGPTContext extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String? conversationId;

  @HiveField(2)
  String jsonPayload; // 모든 context 데이터를 JSON으로 저장

  @HiveField(3)
  String keyDescriptions; // 키에 대한 설명을 JSON으로 저장

  FlexibleGPTContext({
    required this.userId,
    this.conversationId,
    required this.jsonPayload,
    String? keyDescriptions,
  }) : keyDescriptions = keyDescriptions ?? '{}';

  // JSON 데이터에 쉽게 접근할 수 있는 getter/setter
  Map<String, dynamic> get data => jsonDecode(jsonPayload);
  set data(Map<String, dynamic> map) => jsonPayload = jsonEncode(map);

  // 키 설명에 쉽게 접근할 수 있는 getter/setter
  Map<String, String> get descriptions => Map<String, String>.from(jsonDecode(keyDescriptions));
  set descriptions(Map<String, String> map) => keyDescriptions = jsonEncode(map);
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'conversationId': conversationId,
      'data': data,
      'keyDescriptions': descriptions,
    };
  }

  factory FlexibleGPTContext.fromJson(Map<String, dynamic> json) {
    return FlexibleGPTContext(
      userId: json['userId'] as String,
      conversationId: json['conversationId'] as String?,
      jsonPayload: jsonEncode(json['data']),
      keyDescriptions: jsonEncode(json['keyDescriptions'] ?? {}),
    );
  }

  // 편의 메서드들
  T? getValue<T>(String key) {
    final value = data[key];
    return value is T ? value : null;
  }
  // 기본 키 목록 (콤마로 구분)
  String getAllKeys() {
    final keys = data.keys.toList();
    return keys.join(', ');
  }

  // 키 존재 여부 확인
  bool hasKey(String key) {
    return data.containsKey(key);
  }

  // GPT 프롬프트용 키 안내 (중복 방지 메시지 포함)
  String getKeysForPrompt() {
    final allKeys = data.keys.toList();
    final buffer = StringBuffer();
    
    buffer.writeln('📋 현재 저장된 데이터 키 목록:');
    
    if (allKeys.isNotEmpty) {
      buffer.writeln('기존 키와 설명:');
      for (final key in allKeys) {
        final description = getKeyDescription(key);
        if (description != null) {
          buffer.writeln('  • $key: $description');
        } else {
          buffer.writeln('  • $key: (설명 없음)');
        }
      }
    } else {
      buffer.writeln('  (현재 저장된 데이터 없음)');
    }
    
    return buffer.toString();
  }

  // 유사한 키 찾기 (중복 방지용)
  List<String> findSimilarKeys(String newKey) {
    final allKeys = data.keys.toList();
    final lowerNewKey = newKey.toLowerCase();
    
    return allKeys.where((existingKey) {
      final lowerExisting = existingKey.toLowerCase();
      // 부분 일치 또는 유사한 단어 포함 체크
      return lowerExisting.contains(lowerNewKey) || 
             lowerNewKey.contains(lowerExisting) ||
             _calculateSimilarity(lowerNewKey, lowerExisting) > 0.7;
    }).toList();
  }

  // 간단한 유사도 계산 (레벤슈타인 거리 기반)
  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final shorter = a.length < b.length ? a : b;
    final longer = a.length < b.length ? b : a;
    
    if (shorter.length == 0) return 0.0;
    
    int distance = _levenshteinDistance(shorter, longer);
    return (longer.length - distance) / longer.length;
  }

  int _levenshteinDistance(String a, String b) {
    List<List<int>> matrix = List.generate(
      a.length + 1, 
      (i) => List.generate(b.length + 1, (j) => 0)
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  void setValue<T>(String key, T? value, {String? description}) {
    final currentData = data;
    if (value == null) {
      currentData.remove(key);
      // 값이 삭제되면 설명도 삭제
      removeKeyDescription(key);
    } else {
      currentData[key] = value;
      // 설명이 제공되면 함께 저장
      if (description != null) {
        setKeyDescription(key, description);
      }
    }
    data = currentData;
  }

  // 키 설명 설정
  void setKeyDescription(String key, String description) {
    final currentDescriptions = descriptions;
    currentDescriptions[key] = description;
    descriptions = currentDescriptions;
  }

  // 키 설명 가져오기
  String? getKeyDescription(String key) {
    return descriptions[key];
  }

  // 키 설명 삭제
  void removeKeyDescription(String key) {
    final currentDescriptions = descriptions;
    currentDescriptions.remove(key);
    descriptions = currentDescriptions;
  }

  // 모든 키와 설명을 함께 가져오기
  Map<String, String> getAllKeysWithDescriptions() {
    final result = <String, String>{};
    for (final key in data.keys) {
      final description = getKeyDescription(key);
      result[key] = description ?? '설명 없음';
    }
    return result;
  }

  // GPT 업데이트용 메서드 (키 설명 포함)
  void updateFromGPTResponse(Map<String, dynamic> gptData, {Map<String, String>? keyDescriptions}) {
    final currentData = data;
    gptData.forEach((key, value) {
      if (value != null) {
        currentData[key] = value;
      }
    });
    data = currentData;
    
    // 키 설명도 함께 업데이트
    if (keyDescriptions != null) {
      keyDescriptions.forEach((key, description) {
        setKeyDescription(key, description);
      });
    }
  }

  FlexibleGPTContext copyWith({
    String? userId,
    String? conversationId,
    Map<String, dynamic>? newData,
    Map<String, String>? newDescriptions,
  }) {
    return FlexibleGPTContext(
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      jsonPayload: jsonEncode(newData ?? data),
      keyDescriptions: jsonEncode(newDescriptions ?? descriptions),
    );
  }
} 