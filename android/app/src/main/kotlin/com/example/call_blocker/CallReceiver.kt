package com.example.call_blocker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.TelephonyManager
import android.util.Log
import java.util.concurrent.ConcurrentHashMap
import android.telecom.CallScreeningService

class CallReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "CallReceiver"
        private const val ACTION_UPDATE_SETTINGS = "com.example.call_blocker.UPDATE_SETTINGS"
        private val settings = ConcurrentHashMap<String, Any>()
    }

    override fun onReceive(context: Context, intent: Intent) {
        try {
            if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
                return
            }

            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            if (state != TelephonyManager.EXTRA_STATE_RINGING) {
                return
            }

            val phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
            Log.d(TAG, "Incoming call from: $phoneNumber")

            if (shouldBlockCall(phoneNumber)) {
                Log.i(TAG, "Blocking call from: $phoneNumber")
                blockCall(context, phoneNumber)
            } else {
                Log.d(TAG, "Allowing call from: $phoneNumber")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing call: ${e.message}", e)
        }
    }

    private fun shouldBlockCall(phoneNumber: String?): Boolean {
        try {
            if (!isEnabled()) {
                return false
            }

            if (phoneNumber == null) {
                return isBlockPrivateEnabled()
            }

            if (isBlockAllEnabled()) {
                return true
            }

            if (isBlockUnknownEnabled() && !isNumberInContacts(phoneNumber)) {
                return true
            }

            val blockedNumbers = getBlockedNumbers()
            val blockedPrefixes = getBlockedPrefixes()

            return blockedNumbers.contains(phoneNumber) ||
                   blockedPrefixes.any { prefix -> phoneNumber.startsWith(prefix) }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking if call should be blocked: ${e.message}", e)
            return false
        }
    }

    private fun blockCall(context: Context, phoneNumber: String?) {
        try {
            val intent = Intent(context, CallScreeningService::class.java).apply {
                action = CallScreeningService.ACTION_SCREEN_CALL
                putExtra(CallScreeningService.EXTRA_PHONE_NUMBER, phoneNumber)
            }
            context.startService(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error blocking call: ${e.message}", e)
        }
    }

    fun updateSettings(
        enabled: Boolean,
        blockAll: Boolean,
        blockUnknown: Boolean,
        blockPrivate: Boolean,
        blockedNumbers: Set<String>,
        blockedPrefixes: Set<String>
    ) {
        try {
            settings["enabled"] = enabled
            settings["blockAll"] = blockAll
            settings["blockUnknown"] = blockUnknown
            settings["blockPrivate"] = blockPrivate
            settings["blockedNumbers"] = blockedNumbers
            settings["blockedPrefixes"] = blockedPrefixes

            Log.d(TAG, "Settings updated successfully")
            Log.i(TAG, "Settings updated: enabled=$enabled, blockAll=$blockAll, " +
                      "blockUnknown=$blockUnknown, blockPrivate=$blockPrivate, " +
                      "blockedNumbers=${blockedNumbers.size}, blockedPrefixes=${blockedPrefixes.size}")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating settings: ${e.message}", e)
        }
    }

    private fun isEnabled(): Boolean = settings["enabled"] as? Boolean ?: false
    private fun isBlockAllEnabled(): Boolean = settings["blockAll"] as? Boolean ?: false
    private fun isBlockUnknownEnabled(): Boolean = settings["blockUnknown"] as? Boolean ?: false
    private fun isBlockPrivateEnabled(): Boolean = settings["blockPrivate"] as? Boolean ?: false

    @Suppress("UNCHECKED_CAST")
    private fun getBlockedNumbers(): Set<String> = 
        (settings["blockedNumbers"] as? Set<String>) ?: emptySet()

    @Suppress("UNCHECKED_CAST")
    private fun getBlockedPrefixes(): Set<String> = 
        (settings["blockedPrefixes"] as? Set<String>) ?: emptySet()

    private fun isNumberInContacts(phoneNumber: String): Boolean {
        // TODO: Implement contact checking logic
        return false
    }
}