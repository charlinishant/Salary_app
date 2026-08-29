import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmSoundService {
  AlarmSoundService._internal();
  static final AlarmSoundService instance = AlarmSoundService._internal();

  static const MethodChannel _channel = MethodChannel('com.salarybox/alarm_sound');
  Timer? _alarmCheckTimer;
  Timer? _ringtoneLoopTimer;
  bool _isPlaying = false;
  String _lastTriggeredMinute = '';

  /// Play high-volume continuous native alarm ringtone + vibration
  Future<void> playAlarmSound({String ringtoneType = 'ALARM'}) async {
    _isPlaying = true;
    try {
      await _channel.invokeMethod('playAlarm', {'type': ringtoneType});
    } catch (_) {
      try {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }

    // Keep ringtone looping every 3 seconds while active
    _ringtoneLoopTimer?.cancel();
    _ringtoneLoopTimer = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (!_isPlaying) {
        t.cancel();
        return;
      }
      try {
        await _channel.invokeMethod('playAlarm', {'type': ringtoneType});
      } catch (_) {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.vibrate();
      }
    });
  }

  /// Stop playing alarm sound
  Future<void> stopAlarmSound() async {
    _isPlaying = false;
    _ringtoneLoopTimer?.cancel();
    _ringtoneLoopTimer = null;
    try {
      await _channel.invokeMethod('stopAlarm');
    } catch (_) {}
  }

  /// Play audible beep
  Future<void> playBeep() async {
    try {
      await _channel.invokeMethod('playBeep');
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Play punch success tone when employee punches in/out
  Future<void> playPunchSuccessSound() async {
    try {
      await _channel.invokeMethod('playSuccess');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.mediumImpact();
    }
  }

  /// Start background checker to trigger alarm dialog when current time matches set alarm
  void startAlarmMonitor(GlobalKey<NavigatorState> navigatorKey) {
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final now = DateTime.now();
      final currentFormatted = DateFormat('h:mm a').format(now).toLowerCase();
      final currentMinuteKey = DateFormat('yyyy-MM-dd HH:mm').format(now);

      if (_lastTriggeredMinute == currentMinuteKey) return;

      final prefs = await SharedPreferences.getInstance();
      final punchInAlarm = prefs.getString('punch_in_alarm')?.toLowerCase() ?? '';
      final punchOutAlarm = prefs.getString('punch_out_alarm')?.toLowerCase() ?? '';
      final isAlarmEnabled = prefs.getBool('alarm_sound_enabled') ?? true;

      if (!isAlarmEnabled) return;

      if (punchInAlarm.isNotEmpty && punchInAlarm != 'not set' && punchInAlarm == currentFormatted) {
        _lastTriggeredMinute = currentMinuteKey;
        _triggerAlarmPopup(navigatorKey, 'Punch In', 'It is time to punch in for your shift!');
      } else if (punchOutAlarm.isNotEmpty && punchOutAlarm != 'not set' && punchOutAlarm == currentFormatted) {
        _lastTriggeredMinute = currentMinuteKey;
        _triggerAlarmPopup(navigatorKey, 'Punch Out', 'It is time to punch out for your shift!');
      }
    });
  }

  void _triggerAlarmPopup(GlobalKey<NavigatorState> navigatorKey, String type, String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    playAlarmSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          stopAlarmSound();
        },
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alarm_on,
                    size: 46,
                    color: Color(0xFF00BFA5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$type Reminder!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          stopAlarmSound();
                          Navigator.pop(ctx);
                        },
                        child: const Text('DISMISS', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          stopAlarmSound();
                          Navigator.pop(ctx);
                        },
                        child: const Text('PUNCH NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
