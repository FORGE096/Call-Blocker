package com.example.call_blocker

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.example.call_blocker/blocker"
        private const val PERMISSION_REQUEST_CODE = 123
        private val PERMISSIONS = arrayOf(
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.ANSWER_PHONE_CALLS,
            Manifest.permission.READ_CONTACTS
        )
    }

    private lateinit var channel: MethodChannel
    private val isBlockerInitialized = AtomicBoolean(false)
    private val callReceiver = CallReceiver()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initializeBlocker" -> {
                        if (checkAndRequestPermissions()) {
                            initializeBlocker()
                            result.success(true)
                        } else {
                            result.error("PERMISSION_DENIED", "Required permissions not granted", null)
                        }
                    }
                    "setBlockerEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setBlockerEnabled(enabled)
                        result.success(true)
                    }
                    "setBlockAllCalls" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setBlockAllCalls(enabled)
                        result.success(true)
                    }
                    "setBlockUnknownNumbers" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setBlockUnknownNumbers(enabled)
                        result.success(true)
                    }
                    "setBlockPrivateNumbers" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setBlockPrivateNumbers(enabled)
                        result.success(true)
                    }
                    "updateBlockedNumbers" -> {
                        val numbers = call.argument<List<String>>("numbers")?.toSet() ?: emptySet()
                        val prefixes = call.argument<List<String>>("prefixes")?.toSet() ?: emptySet()
                        updateBlockedNumbers(numbers, prefixes)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error handling method call: ${e.message}", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun checkAndRequestPermissions(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }

        val permissionsToRequest = PERMISSIONS.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }.toTypedArray()

        if (permissionsToRequest.isEmpty()) {
            return true
        }

        ActivityCompat.requestPermissions(this, permissionsToRequest, PERMISSION_REQUEST_CODE)
        return false
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                initializeBlocker()
                channel.invokeMethod("permissionsGranted", null)
            } else {
                channel.invokeMethod("permissionsDenied", null)
            }
        }
    }

    private fun initializeBlocker() {
        try {
            if (isBlockerInitialized.get()) {
                return
            }

            val intent = Intent(this, CallScreeningService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }

            isBlockerInitialized.set(true)
            Log.i(TAG, "Blocker initialized successfully")
            channel.invokeMethod("nativeBlockerInitialized", null)
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing blocker: ${e.message}", e)
            channel.invokeMethod("nativeBlockerError", e.message)
        }
    }

    private fun setBlockerEnabled(enabled: Boolean) {
        try {
            callReceiver.updateSettings(
                enabled = enabled,
                blockAll = false,
                blockUnknown = false,
                blockPrivate = false,
                blockedNumbers = emptySet(),
                blockedPrefixes = emptySet()
            )
            Log.i(TAG, "Blocker ${if (enabled) "enabled" else "disabled"}")
            channel.invokeMethod("blockerStateChanged", enabled)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting blocker state: ${e.message}", e)
            channel.invokeMethod("blockerError", e.message)
        }
    }

    private fun setBlockAllCalls(enabled: Boolean) {
        try {
            callReceiver.updateSettings(
                enabled = true,
                blockAll = enabled,
                blockUnknown = false,
                blockPrivate = false,
                blockedNumbers = emptySet(),
                blockedPrefixes = emptySet()
            )
            Log.i(TAG, "Block all calls ${if (enabled) "enabled" else "disabled"}")
            channel.invokeMethod("blockAllCallsStateChanged", enabled)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting block all calls: ${e.message}", e)
            channel.invokeMethod("blockerError", e.message)
        }
    }

    private fun setBlockUnknownNumbers(enabled: Boolean) {
        try {
            callReceiver.updateSettings(
                enabled = true,
                blockAll = false,
                blockUnknown = enabled,
                blockPrivate = false,
                blockedNumbers = emptySet(),
                blockedPrefixes = emptySet()
            )
            Log.i(TAG, "Block unknown numbers ${if (enabled) "enabled" else "disabled"}")
            channel.invokeMethod("blockUnknownNumbersStateChanged", enabled)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting block unknown numbers: ${e.message}", e)
            channel.invokeMethod("blockerError", e.message)
        }
    }

    private fun setBlockPrivateNumbers(enabled: Boolean) {
        try {
            callReceiver.updateSettings(
                enabled = true,
                blockAll = false,
                blockUnknown = false,
                blockPrivate = enabled,
                blockedNumbers = emptySet(),
                blockedPrefixes = emptySet()
            )
            Log.i(TAG, "Block private numbers ${if (enabled) "enabled" else "disabled"}")
            channel.invokeMethod("blockPrivateNumbersStateChanged", enabled)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting block private numbers: ${e.message}", e)
            channel.invokeMethod("blockerError", e.message)
        }
    }

    private fun updateBlockedNumbers(numbers: Set<String>, prefixes: Set<String>) {
        try {
            callReceiver.updateSettings(
                enabled = true,
                blockAll = false,
                blockUnknown = false,
                blockPrivate = false,
                blockedNumbers = numbers,
                blockedPrefixes = prefixes
            )
            Log.i(TAG, "Blocked numbers updated: ${numbers.size} numbers, ${prefixes.size} prefixes")
            channel.invokeMethod("blockedNumbersUpdated", null)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating blocked numbers: ${e.message}", e)
            channel.invokeMethod("blockerError", e.message)
        }
    }
}