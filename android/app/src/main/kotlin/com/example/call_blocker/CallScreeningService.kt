package com.example.call_blocker

import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class CallScreeningService : CallScreeningService() {
    companion object {
        private const val TAG = "CallScreeningService"
        const val ACTION_SCREEN_CALL = "android.telecom.CallScreeningService"
        const val EXTRA_PHONE_NUMBER = "phone_number"
    }

    override fun onScreenCall(callDetails: Call.Details) {
        try {
            Log.d(TAG, "Screening call from: ${callDetails.handle.schemeSpecificPart}")
            
            val response = CallResponse.Builder()
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSilenceCall(true)
                .build()

            respondToCall(callDetails, response)
            Log.i(TAG, "Call blocked successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error screening call: ${e.message}", e)
            // Default to blocking the call in case of error
            respondToCall(callDetails, CallResponse.Builder()
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSilenceCall(true)
                .build())
        }
    }
} 