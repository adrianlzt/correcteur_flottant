package com.example.correcteur_flottant

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.correcteur_flottant/intent"

    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.action == Intent.ACTION_PROCESS_TEXT) {
            setTheme(R.style.TransparentTheme)
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getLaunchAction") {
                result.success(intent.action)
            } else {
                result.notImplemented()
            }
        }
    }
}
