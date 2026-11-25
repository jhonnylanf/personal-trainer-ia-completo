package com.personaltrainer.ia

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "com.personaltrainer.ia/native"
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
      when (call.method) {
        "scheduleRest" -> { scheduleRest(call.argument<Long>("endAt") ?: 0L); result.success(true) }
        "cancelRest" -> { cancelRest(); result.success(true) }
        "vibrate" -> { vibrate((call.argument<Int>("ms") ?: 400).toLong()); result.success(true) }
        "beep" -> { beep(); result.success(true) }
        "consumeFinishedRest" -> {
          val prefs=getSharedPreferences("personal_ia",Context.MODE_PRIVATE)
          if(prefs.getBoolean("rest_finished",false)){
            prefs.edit().putBoolean("rest_finished",false).apply()
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger,channelName).invokeMethod("restFinished",null)
          }
          result.success(true)
        }
        else -> result.notImplemented()
      }
    }
  }
  private fun alarmIntent()=PendingIntent.getBroadcast(this,7401,Intent(this,RestAlarmReceiver::class.java),PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
  private fun scheduleRest(endAt:Long){
    val am=getSystemService(ALARM_SERVICE) as AlarmManager
    cancelRest()
    if(Build.VERSION.SDK_INT>=31 && am.canScheduleExactAlarms()) am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP,endAt,alarmIntent())
    else am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP,endAt,alarmIntent())
  }
  private fun cancelRest(){(getSystemService(ALARM_SERVICE) as AlarmManager).cancel(alarmIntent())}
  private fun vibrate(ms:Long){val v=getSystemService(VIBRATOR_SERVICE) as Vibrator;if(Build.VERSION.SDK_INT>=26)v.vibrate(VibrationEffect.createOneShot(ms,VibrationEffect.DEFAULT_AMPLITUDE))else @Suppress("DEPRECATION") v.vibrate(ms)}
  private fun beep(){ToneGenerator(AudioManager.STREAM_NOTIFICATION,82).apply{startTone(ToneGenerator.TONE_PROP_BEEP,260);android.os.Handler(mainLooper).postDelayed({release()},350)}}
}
