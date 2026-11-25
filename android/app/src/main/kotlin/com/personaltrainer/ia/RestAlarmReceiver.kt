package com.personaltrainer.ia

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator

class RestAlarmReceiver:BroadcastReceiver(){
 override fun onReceive(context:Context,intent:Intent?){
  context.getSharedPreferences("personal_ia",Context.MODE_PRIVATE).edit().putBoolean("rest_finished",true).apply()
  val vibrator=context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
  val pattern=longArrayOf(0,320,120,320)
  if(Build.VERSION.SDK_INT>=26)vibrator.vibrate(VibrationEffect.createWaveform(pattern,-1))else @Suppress("DEPRECATION") vibrator.vibrate(pattern,-1)
  ToneGenerator(AudioManager.STREAM_NOTIFICATION,88).apply{startTone(ToneGenerator.TONE_PROP_BEEP2,350);android.os.Handler(context.mainLooper).postDelayed({release()},500)}
 }
}
