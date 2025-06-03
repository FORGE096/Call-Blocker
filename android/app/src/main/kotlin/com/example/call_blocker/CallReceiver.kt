package com.example.call_blocker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log
import java.lang.reflect.Method

class CallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return
        
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
        if (state == TelephonyManager.EXTRA_STATE_RINGING) {
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
            Log.d("CallBlocker", "تماس ورودی از: $number")
            
            // بررسی بلاک بودن شماره
            if (shouldBlock(number, context)) {
                Log.d("CallBlocker", "تماس بلاک شد: $number")
                endCall(context)
            }
        }
    }

    private fun shouldBlock(number: String, context: Context): Boolean {
        val prefs = context.getSharedPreferences("blocker_prefs", Context.MODE_PRIVATE)
        val blockedPrefixes = prefs.getStringSet("blocked_prefixes", setOf()) ?: setOf()
        
        return blockedPrefixes.any { prefix ->
            // نرمال‌سازی شماره برای مقایسه بهتر
            val cleanNumber = number.replace("+", "").replace(" ", "")
            val cleanPrefix = prefix.replace("+", "").replace(" ", "")
            cleanNumber.startsWith(cleanPrefix)
        }
    }

    private fun endCall(context: Context) {
        try {
            // روش جدید برای قطع تماس (کاربردی‌تر)
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            
            try {
                // روش 1: استفاده از getITelephony (برای اندروید قدیمی)
                val getITelephony: Method = telephonyManager.javaClass.getDeclaredMethod("getITelephony")
                getITelephony.isAccessible = true
                val telephonyService: Any = getITelephony.invoke(telephonyManager)
                
                val endCall: Method = telephonyService.javaClass.getDeclaredMethod("endCall")
                endCall.invoke(telephonyService)
                Log.d("CallBlocker", "تماس با موفقیت قطع شد (روش 1)")
            } catch (e: Exception) {
                Log.e("CallBlocker", "خطا در روش 1، امتحان روش 2", e)
                
                // روش 2: استفاده از TelecomManager (برای اندروید جدید)
                val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                    telecomManager.endCall()
                    Log.d("CallBlocker", "تماس با موفقیت قطع شد (روش 2)")
                }
            }
        } catch (e: Exception) {
            Log.e("CallBlocker", "خطا در قطع تماس", e)
        }
    }
}