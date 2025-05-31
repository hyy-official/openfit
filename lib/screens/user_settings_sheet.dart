import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:openfit/models/user_profile.dart';

class UserSettingsSheet extends StatefulWidget {
  const UserSettingsSheet({super.key});

  @override
  State<UserSettingsSheet> createState() => _UserSettingsSheetState();
}

class _UserSettingsSheetState extends State<UserSettingsSheet> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _goalController = TextEditingController();
  final _dietController = TextEditingController();
  final _keyController = TextEditingController();
  String _gender = '남성';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox<UserProfile>('userProfileBox');
    final profile = box.get('main');
    if (profile != null) {
      _nameController.text = profile.name;
      _weightController.text = profile.weight.toString();
      _bodyFatController.text = profile.bodyFat.toString();
      _goalController.text = profile.goal;
      _dietController.text = profile.dietHabit;
      _keyController.text = profile.gptKey ?? '';
      _gender = profile.gender;
      setState(() {}); // 추가: 변경 반영
    }
  }

  Future<void> _saveProfile() async {
    final profile = UserProfile(
      name: _nameController.text,
      gender: _gender,
      weight: double.tryParse(_weightController.text) ?? 0,
      bodyFat: double.tryParse(_bodyFatController.text) ?? 0,
      goal: _goalController.text,
      dietHabit: _dietController.text,
      gptKey: _keyController.text ?? '',
    );
    final box = await Hive.openBox<UserProfile>('userProfileBox');
    await box.put('main', profile);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 모달 사이즈 자동 조절
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("⚙ 개인 설정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['남성', '여성'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gender = v ?? '남성'),
                decoration: const InputDecoration(labelText: '성별'),
              ),
              const SizedBox(height: 10),
              TextField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '체중 (kg)')),
              const SizedBox(height: 10),
              TextField(controller: _bodyFatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '체지방률 (%)')),
              const SizedBox(height: 10),
              TextField(controller: _dietController, decoration: const InputDecoration(labelText: '식습관')),
              const SizedBox(height: 10),
              TextField(controller: _goalController, decoration: const InputDecoration(labelText: '건강 목표')),
              const SizedBox(height: 20),
              TextField(controller: _keyController, decoration: const InputDecoration(labelText: 'API_KEY')),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('저장'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
