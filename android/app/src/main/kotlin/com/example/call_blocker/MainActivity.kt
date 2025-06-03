package com.example.call_blocker

import io.flutter.embedding.android.FlutterActivity
import android.content.SharedPreferences
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "callblocker.channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // استفاده از SharedPreferences اختصاصی برای برنامه
        val sharedPref = applicationContext.getSharedPreferences("blocker_prefs", Context.MODE_PRIVATE)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBlockedPrefixes" -> {
                    val blocked = sharedPref.getStringSet("blocked_prefixes", setOf()) ?: setOf()
                    result.success(blocked.toList())
                }
                "addBlockedPrefix" -> {
                    val prefix = call.argument<String>("prefix")
                    if (prefix != null) {
                        val blocked = sharedPref.getStringSet("blocked_prefixes", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
                        blocked.add(prefix)
                        sharedPref.edit().putStringSet("blocked_prefixes", blocked).apply()
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Prefix is null", null)
                    }
                }
                "removeBlockedPrefix" -> {
                    val prefix = call.argument<String>("prefix")
                    if (prefix != null) {
                        val blocked = sharedPref.getStringSet("blocked_prefixes", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
                        blocked.remove(prefix)
                        sharedPref.edit().putStringSet("blocked_prefixes", blocked).apply()
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Prefix is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
