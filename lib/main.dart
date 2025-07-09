import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'screens/settings_screen.dart';
import 'widgets/correction_overlay.dart';

// Entry point for the overlay service
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CorrectionOverlay(),
  ));
}

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
  static const platform = MethodChannel('com.example.correcteur_flottant/intent');
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
    // Use a post-frame callback to ensure the widget is built before we pop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTextAndClose(widget.initialText);
    });
  }

  Future<void> _handleTextAndClose(String? text) async {
    // If there's no text, we can just close the app.
    if (text == null || text.isEmpty) {
      SystemNavigator.pop();
      return;
    }

    await _handleText(text);

    // Close the invisible activity.
    SystemNavigator.pop();
  }

  Future<bool> _handleText(String? text) async {
    if (text == null || text.isEmpty) return false;

    final bool? isPermissionGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (isPermissionGranted != true) {
      final bool? granted = await FlutterOverlayWindow.requestPermission();
      if (granted != true) {
        print('Overlay permission is required to show corrections.');
        return false;
      }
    }

    await FlutterOverlayWindow.showOverlay(
      height: 600,
      width: FlutterOverlayWindow.matchParent,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.focusPointer,
      enableDrag: true,
    );
    await FlutterOverlayWindow.shareData(text);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // This screen should be invisible.
    return Container(color: Colors.transparent);
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
