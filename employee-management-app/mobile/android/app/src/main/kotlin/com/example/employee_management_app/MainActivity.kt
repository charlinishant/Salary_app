package com.example.employee_management_app

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.Ringtone
import android.media.RingtoneManager
import android.media.ToneGenerator
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.salarybox/alarm_sound"
    private var activeRingtone: Ringtone? = null
    private var toneGen: ToneGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playAlarm" -> {
                    try {
                        stopRingtone()
                        val type = call.argument<String>("type") ?: "ALARM"
                        val ringtoneUri: Uri = if (type == "NOTIFICATION") {
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                        } else {
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                        }

                        val ringtone = RingtoneManager.getRingtone(applicationContext, ringtoneUri)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            ringtone.audioAttributes = AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_ALARM)
                                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                .build()
                        }
                        ringtone.play()
                        activeRingtone = ringtone

                        triggerVibration(1000)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "stopAlarm" -> {
                    stopRingtone()
                    result.success(true)
                }
                "playBeep" -> {
                    try {
                        if (toneGen == null) {
                            toneGen = ToneGenerator(AudioManager.STREAM_ALARM, 100)
                        }
                        toneGen?.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 400)
                        triggerVibration(300)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "playSuccess" -> {
                    try {
                        if (toneGen == null) {
                            toneGen = ToneGenerator(AudioManager.STREAM_MUSIC, 100)
                        }
                        toneGen?.startTone(ToneGenerator.TONE_PROP_BEEP2, 250)
                        triggerVibration(150)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopRingtone() {
        try {
            if (activeRingtone != null && activeRingtone!!.isPlaying) {
                activeRingtone!!.stop()
            }
            activeRingtone = null
        } catch (_: Exception) {}
    }

    private fun triggerVibration(durationMs: Long) {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(durationMs)
            }
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        stopRingtone()
        try {
            toneGen?.release()
            toneGen = null
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
