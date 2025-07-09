import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../models/llm_response.dart';
import '../services/llm_service.dart';

class CorrectionOverlay extends StatefulWidget {
  const CorrectionOverlay({Key? key}) : super(key: key);

  @override
  State<CorrectionOverlay> createState() => _CorrectionOverlayState();
}

class _CorrectionOverlayState extends State<CorrectionOverlay> {
  final LlmService _llmService = LlmService();
  Future<LlmResponse>? _correctionFuture;

  @override
  void initState() {
    super.initState();
    // Listen for data sent from the main app.
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is String) {
        setState(() {
          _correctionFuture = _llmService.getCorrection(data);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
            ),
          ],
        ),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: _buildContent(),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => FlutterOverlayWindow.closeOverlay(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_correctionFuture == null) {
      return const Center(
        child: Text('Waiting for text...'),
      );
    }

    return FutureBuilder<LlmResponse>(
      future: _correctionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorView(snapshot.error.toString());
        }
        if (snapshot.hasData) {
          return _buildSuccessView(snapshot.data!);
        }
        return const Center(child: Text('Something went wrong.'));
      },
    );
  }

  Widget _buildErrorView(String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(error, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildSuccessView(LlmResponse response) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Correction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Corrected Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(response.correctedText),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: response.correctedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Explanation of Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            response.errors.isEmpty
                ? const Center(child: Text('No errors found.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: response.errors.length,
                    itemBuilder: (context, index) {
                      final error = response.errors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(error.type, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                              const SizedBox(height: 4),
                              Text('Original: ${error.original}'),
                              Text('Corrected: ${error.corrected}'),
                              const SizedBox(height: 4),
                              Text(error.explanation, style: const TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
    );
  }
}
