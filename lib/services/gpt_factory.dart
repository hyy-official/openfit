import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart';
import 'package:openfit/services/gpt_client.dart';

Future<GPTClient> createGPTClientFromProfile() async {
  final box = await Hive.openBox<UserProfile>('userProfileBox');
  final profile = box.get('main');

  final key = profile?.gptKey?.trim();
  if (key == null || key.isEmpty) {
    throw Exception('API 키가 없습니다. 설정에서 입력해 주세요.');
  }

  return GPTClient(key);
}
