import 'package:flutter/material.dart';
import 'package:openfit/services/summary_loader.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({Key? key}) : super(key: key);

  @override
  _DevSettingsScreenState createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  final _summaryLoader = SummaryLoader();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개발자 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _reloadData,
              child: Text(_isLoading ? '로딩 중...' : '데이터 다시 로드'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_summaryLoader.lastSyncTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '마지막 동기화: ${_summaryLoader.lastSyncTime!.toString()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _reloadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _summaryLoader.loadData();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 