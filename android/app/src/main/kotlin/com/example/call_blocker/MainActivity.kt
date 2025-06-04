package com.example.call_blocker

import io.flutter.embedding.android.FlutterActivity
import android.content.SharedPreferences
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "callblocker.channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("CallBlocker", "Setting up method channel")
        
        val sharedPref = applicationContext.getSharedPreferences("blocker_prefs", Context.MODE_PRIVATE)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBlockingEnabled" -> {
                    val isEnabled = sharedPref.getBoolean("blocking_enabled", false)
                    Log.d("CallBlocker", "isBlockingEnabled called: $isEnabled")
                    result.success(isEnabled)
                }
                "setBlockingEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled")
                    if (enabled != null) {
                        Log.d("CallBlocker", "setBlockingEnabled called: $enabled")
                        sharedPref.edit().putBoolean("blocking_enabled", enabled).apply()
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Enabled state is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}