import 'dart:async';
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    // For sharing text coming from outside the app while it is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) async {
      if (value.isNotEmpty && value.first.type == SharedMediaType.text) {
        final bool success = await _handleText(value.first.path);
        if (success) {
          SystemNavigator.pop();
        }
      }
    }, onError: (err) {
      print("getMediaStream error: ");
    });

    // For sharing text coming from outside the app while it is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) async {
      if (value.isNotEmpty && value.first.type == SharedMediaType.text) {
        final bool success = await _handleText(value.first.path);
        if (success) {
          SystemNavigator.pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Future<bool> _handleText(String? text) async {
    if (text == null || text.isEmpty) return false;

    final bool? isPermissionGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (isPermissionGranted != true) {
      final bool? granted = await FlutterOverlayWindow.requestPermission();
      if (granted != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Overlay permission is required to show corrections.')),
          );
        }
        return false;
      }
    }

    await FlutterOverlayWindow.showOverlay(
      height: 400,
      width: 350,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.focusPointer,
    );
    await FlutterOverlayWindow.shareData(text);
    return true;
  }

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
