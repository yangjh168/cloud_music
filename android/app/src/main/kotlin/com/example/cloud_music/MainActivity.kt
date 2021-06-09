package com.example.cloud_music

import android.os.Bundle
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode.transparent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity: FlutterActivity() {
  private val CHANNEL = "android/back/desktop"
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
      GeneratedPluginRegistrant.registerWith(flutterEngine);
      MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, result ->
          if (methodCall.method == "backDesktop") {
              result.success(true)
              moveTaskToBack(false)
          }
      }
  }
}
