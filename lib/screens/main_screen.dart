import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfit/screens/dev_settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenFit'),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DevSettingsScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
} 