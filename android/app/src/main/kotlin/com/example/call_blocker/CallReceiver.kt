package com.example.call_blocker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class CallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return
        
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
        if (state == TelephonyManager.EXTRA_STATE_RINGING) {
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
            Log.d("CallBlocker", "Incoming call from: $number")
            
            if (isBlockingEnabled(context)) {
                Log.d("CallBlocker", "Blocking is enabled, checking number")
                endCall(context)
            } else {
                Log.d("CallBlocker", "Blocking is disabled, allowing call")
            }
        }
    }

    private fun isBlockingEnabled(context: Context): Boolean {
        val prefs = context.getSharedPreferences("blocker_prefs", Context.MODE_PRIVATE)
        return prefs.getBoolean("blocking_enabled", false)
    }

    private fun endCall(context: Context) {
        try {
            Log.d("CallBlocker", "Attempting to end call")
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager
                telecomManager.endCall()
                Log.d("CallBlocker", "Call ended using TelecomManager")
                return
            }
            try {
                val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                val getITelephony = telephonyManager.javaClass.getDeclaredMethod("getITelephony")
                getITelephony.isAccessible = true
                val telephonyService = getITelephony.invoke(telephonyManager)
                val endCall = telephonyService.javaClass.getDeclaredMethod("endCall")
                endCall.invoke(telephonyService)
                Log.d("CallBlocker", "Call ended using ITelephony")
            } catch (e: Exception) {
                Log.e("CallBlocker", "Error ending call with ITelephony", e)
            }
        } catch (e: Exception) {
            Log.e("CallBlocker", "General error ending call", e)
        }
    }
}