import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ApiKeyService {
  static const String _promptLayerKey = 'prompt_layer_api_key';
  static const String _openAiKey = 'openai_api_key';
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (!dotenv.isInitialized) {
        print('Loading .env file...');
        await dotenv.load();
        print('Successfully loaded .env file in ApiKeyService');
        
        // .env에서 API 키를 가져와서 SharedPreferences에 저장
        final promptLayerKey = dotenv.env['PROMPTLAYER_API_KEY'];
        final openAiKey = dotenv.env['OPENAI_API_KEY'];
        
        print('PROMPTLAYER_API_KEY from .env: ${promptLayerKey != null ? 'exists' : 'not found'}');
        print('OPENAI_API_KEY from .env: ${openAiKey != null ? 'exists' : 'not found'}');
        
        if (promptLayerKey != null && promptLayerKey.isNotEmpty) {
          await savePromptLayerApiKey(promptLayerKey);
          print('Saved PromptLayer API key to SharedPreferences');
        }
        if (openAiKey != null && openAiKey.isNotEmpty) {
          await saveOpenAiApiKey(openAiKey);
          print('Saved OpenAI API key to SharedPreferences');
        }
      }
      _isInitialized = true;
    } catch (e) {
      print('환경 변수 로드 실패: $e');
      print('Error stack trace: ${StackTrace.current}');
      _isInitialized = true;
    }
  }

  // API 키 가져오기
  static Future<String?> getPromptLayerApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }

    // .env에서 먼저 시도
    if (dotenv.isInitialized) {
      final envKey = dotenv.env['PROMPTLAYER_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        return envKey;
      }
    }

    // SharedPreferences에서 시도
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_promptLayerKey);
  }

  static Future<String?> getOpenAiApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }

    // .env에서 먼저 시도
    if (dotenv.isInitialized) {
      final envKey = dotenv.env['OPENAI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        return envKey;
      }
    }

    // SharedPreferences에서 시도
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openAiKey);
  }

  // API 키 저장하기
  static Future<void> savePromptLayerApiKey(String apiKey) async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_promptLayerKey, apiKey);
  }

  static Future<void> saveOpenAiApiKey(String apiKey) async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openAiKey, apiKey);
  }

  // API 키 삭제하기
  static Future<void> deletePromptLayerApiKey() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_promptLayerKey);
  }

  static Future<void> deleteOpenAiApiKey() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_openAiKey);
  }

  // API 키 존재 여부 확인
  static Future<bool> hasPromptLayerApiKey() async {
    if (!kDebugMode) return false;
    
    // .env 파일에서 API 키 확인
    final envKey = dotenv.env['PROMPTLAYER_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return true;
    }

    // SharedPreferences에서 API 키 확인
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_promptLayerKey);
  }

  static Future<bool> hasOpenAiApiKey() async {
    if (!kDebugMode) return false;
    
    // .env 파일에서 API 키 확인
    final envKey = dotenv.env['OPENAI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return true;
    }

    // SharedPreferences에서 API 키 확인
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_openAiKey);
  }
} 