package com.inmeet_core.example
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.res.Configuration
import android.util.Log


import android.os.Bundle

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.util.Rational
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


class MainActivity : FlutterActivity() {

    private val CHANNEL = "inMeetChannel"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
                call, result ->
            when (call.method) {
                "startInMeetScreenShareService" -> {
                    startService(Intent(this, ForegroundService::class.java))
                    result.success("Started!")
                }

                "stopInMeetScreenShareService" -> {
                    stopService(Intent(this, ForegroundService::class.java))
                    result.success("Stopped!")
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

   
}