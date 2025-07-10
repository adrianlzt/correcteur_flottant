import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screens/settings_screen.dart';
import 'widgets/correction_overlay.dart';

// Main application entry point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.adrianlzt.correcteurflottant/intent');
  String? _launchAction;
  String? _initialText;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _getLaunchAction();
  }

  Future<void> _getLaunchAction() async {
    Map<dynamic, dynamic>? intentData;
    // Only check on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        intentData = await platform.invokeMethod('getLaunchAction');
      } on PlatformException catch (e) {
        print("Failed to get launch action: '${e.message}'.");
      }
    }
    if (mounted) {
      setState(() {
        _launchAction = intentData?['action'];
        _initialText = intentData?['data'];
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return MaterialApp(
        home: Container(color: Colors.transparent),
        debugShowCheckedModeBanner: false,
      );
    }

    if (_launchAction == 'android.intent.action.PROCESS_TEXT') {
      return MaterialApp(
        home: ProcessTextScreen(initialText: _initialText),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Correcteur Flottant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class ProcessTextScreen extends StatefulWidget {
  final String? initialText;
  const ProcessTextScreen({Key? key, this.initialText}) : super(key: key);

  @override
  State<ProcessTextScreen> createState() => _ProcessTextScreenState();
}

class _ProcessTextScreenState extends State<ProcessTextScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialText == null || widget.initialText!.isEmpty) {
      // Use a post-frame callback to pop after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SystemNavigator.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialText == null || widget.initialText!.isEmpty) {
      // Show nothing while we prepare to pop.
      return Container(color: Colors.transparent);
    }

    // This screen is a semi-transparent fullscreen activity.
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CorrectionOverlay(text: widget.initialText!),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correcteur Flottant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.spellcheck, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                'Ready to correct your text!',
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Select any French text in another app and choose \"Correcteur Flottant\" from the menu.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
