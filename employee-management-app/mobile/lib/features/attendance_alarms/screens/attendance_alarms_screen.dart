import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/alarm_sound_service.dart';

class AttendanceAlarmsScreen extends StatefulWidget {
  const AttendanceAlarmsScreen({super.key});

  @override
  State<AttendanceAlarmsScreen> createState() => _AttendanceAlarmsScreenState();
}

class _AttendanceAlarmsScreenState extends State<AttendanceAlarmsScreen> {
  String _punchInAlarm = 'Not set';
  String _punchOutAlarm = 'Not set';
  bool _soundEnabled = true;
  String _selectedRingtone = 'ALARM';
  bool _isTestingSound = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  @override
  void dispose() {
    AlarmSoundService.instance.stopAlarmSound();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _punchInAlarm = prefs.getString('punch_in_alarm') ?? 'Not set';
      _punchOutAlarm = prefs.getString('punch_out_alarm') ?? 'Not set';
      _soundEnabled = prefs.getBool('alarm_sound_enabled') ?? true;
      _selectedRingtone = prefs.getString('alarm_ringtone') ?? 'ALARM';
      _isLoading = false;
    });
  }

  Future<void> _saveAlarm(String type, String timeStr) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == 'PUNCH_IN') {
      await prefs.setString('punch_in_alarm', timeStr);
      setState(() => _punchInAlarm = timeStr);
    } else {
      await prefs.setString('punch_out_alarm', timeStr);
      setState(() => _punchOutAlarm = timeStr);
    }

    if (_soundEnabled) {
      AlarmSoundService.instance.playPunchSuccessSound();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.alarm_on, color: Colors.white),
              const SizedBox(width: 10),
              Text('$type alarm set for $timeStr! Sound enabled.'),
            ],
          ),
          backgroundColor: const Color(0xFF00BFA5),
        ),
      );
    }
  }

  Future<void> _toggleSound(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_sound_enabled', val);
    setState(() => _soundEnabled = val);
    if (!val && _isTestingSound) {
      await _stopTestSound();
    }
  }

  Future<void> _changeRingtone(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarm_ringtone', name);
    setState(() => _selectedRingtone = name);
    if (_isTestingSound) {
      await AlarmSoundService.instance.playAlarmSound(ringtoneType: name);
    }
  }

  Future<void> _testAlarmSound() async {
    if (_isTestingSound) {
      await _stopTestSound();
    } else {
      setState(() => _isTestingSound = true);
      await AlarmSoundService.instance.playAlarmSound(ringtoneType: _selectedRingtone);
    }
  }

  Future<void> _stopTestSound() async {
    setState(() => _isTestingSound = false);
    await AlarmSoundService.instance.stopAlarmSound();
  }

  void _showSetAlarmDialog(String type) {
    int selectedHour = 10;
    int selectedMinute = 0;
    String selectedPeriod = 'am';

    final isPunchIn = type == 'PUNCH_IN';
    final existing = isPunchIn ? _punchInAlarm : _punchOutAlarm;

    if (existing != 'Not set') {
      try {
        final parts = existing.split(' ');
        final hm = parts[0].split(':');
        selectedHour = int.tryParse(hm[0]) ?? 10;
        selectedMinute = int.tryParse(hm[1]) ?? 0;
        selectedPeriod = parts.length > 1 ? parts[1].toLowerCase() : 'am';
      } catch (_) {}
    } else if (!isPunchIn) {
      selectedHour = 6;
      selectedMinute = 30;
      selectedPeriod = 'pm';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set alarm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87, size: 24),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Text(
                'Set an alarm to mark daily attendance',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Drum/Wheel Time Picker Matching Image 4
              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour Wheel
                    SizedBox(
                      width: 70,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedHour - 1),
                        itemExtent: 44,
                        selectionOverlay: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 1.5),
                              bottom: BorderSide(color: Colors.grey, width: 1.5),
                            ),
                          ),
                        ),
                        onSelectedItemChanged: (idx) {
                          setStateModal(() => selectedHour = idx + 1);
                        },
                        children: List.generate(12, (i) {
                          final h = i + 1;
                          final isCurrent = h == selectedHour;
                          return Center(
                            child: Text(
                              '$h',
                              style: TextStyle(
                                fontSize: isCurrent ? 22 : 16,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? Colors.black87 : Colors.grey.shade400,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),

                    // Minute Wheel
                    SizedBox(
                      width: 70,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                        itemExtent: 44,
                        selectionOverlay: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 1.5),
                              bottom: BorderSide(color: Colors.grey, width: 1.5),
                            ),
                          ),
                        ),
                        onSelectedItemChanged: (idx) {
                          setStateModal(() => selectedMinute = idx);
                        },
                        children: List.generate(60, (i) {
                          final m = i < 10 ? '0$i' : '$i';
                          final isCurrent = i == selectedMinute;
                          return Center(
                            child: Text(
                              m,
                              style: TextStyle(
                                fontSize: isCurrent ? 22 : 16,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? Colors.black87 : Colors.grey.shade400,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // AM / PM Wheel
                    SizedBox(
                      width: 70,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedPeriod == 'am' ? 0 : 1),
                        itemExtent: 44,
                        selectionOverlay: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 1.5),
                              bottom: BorderSide(color: Colors.grey, width: 1.5),
                            ),
                          ),
                        ),
                        onSelectedItemChanged: (idx) {
                          setStateModal(() => selectedPeriod = idx == 0 ? 'am' : 'pm');
                        },
                        children: [
                          Center(
                            child: Text(
                              'am',
                              style: TextStyle(
                                fontSize: selectedPeriod == 'am' ? 22 : 16,
                                fontWeight: selectedPeriod == 'am' ? FontWeight.bold : FontWeight.normal,
                                color: selectedPeriod == 'am' ? Colors.black87 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'pm',
                              style: TextStyle(
                                fontSize: selectedPeriod == 'pm' ? 22 : 16,
                                fontWeight: selectedPeriod == 'pm' ? FontWeight.bold : FontWeight.normal,
                                color: selectedPeriod == 'pm' ? Colors.black87 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Full Width "Set Alarm" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final minStr = selectedMinute < 10 ? '0$selectedMinute' : '$selectedMinute';
                    final timeFormatted = '$selectedHour:$minStr ${selectedPeriod.toUpperCase()}';
                    Navigator.pop(ctx);
                    _saveAlarm(type, timeFormatted);
                  },
                  child: const Text(
                    'Set Alarm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alarms',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alarms',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can set multiple alarms',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Punch In Alarm Option (Matches Image 3)
                  InkWell(
                    onTap: () => _showSetAlarmDialog('PUNCH_IN'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Punch In Alarm',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Row(
                            children: [
                              Text(
                                _punchInAlarm,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _punchInAlarm != 'Not set' ? const Color(0xFF00BFA5) : Colors.grey,
                                  fontWeight: _punchInAlarm != 'Not set' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),

                  // Punch Out Alarm Option (Matches Image 3)
                  InkWell(
                    onTap: () => _showSetAlarmDialog('PUNCH_OUT'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Punch Out Alarm',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Row(
                            children: [
                              Text(
                                _punchOutAlarm,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _punchOutAlarm != 'Not set' ? const Color(0xFF00BFA5) : Colors.grey,
                                  fontWeight: _punchOutAlarm != 'Not set' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Alarm Sound & Ringtone Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.volume_up, color: Color(0xFF00BFA5), size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Alarm Sound & Vibration',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                            Switch(
                              value: _soundEnabled,
                              activeColor: const Color(0xFF00BFA5),
                              onChanged: (val) => _toggleSound(val),
                            ),
                          ],
                        ),
                        if (_soundEnabled) ...[
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ringtone Style', style: TextStyle(fontSize: 14, color: Colors.black87)),
                              DropdownButton<String>(
                                value: _selectedRingtone,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(value: 'ALARM', child: Text('Loud Alarm Bell')),
                                  DropdownMenuItem(value: 'NOTIFICATION', child: Text('Gentle Chime')),
                                ],
                                onChanged: (val) {
                                  if (val != null) _changeRingtone(val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _isTestingSound ? Colors.red : const Color(0xFF00BFA5)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: Icon(
                                _isTestingSound ? Icons.stop : Icons.play_arrow,
                                color: _isTestingSound ? Colors.red : const Color(0xFF00BFA5),
                              ),
                              label: Text(
                                _isTestingSound ? 'Stop Test Ringtone' : 'Test Alarm Ringtone 🔔',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isTestingSound ? Colors.red : const Color(0xFF00BFA5),
                                ),
                              ),
                              onPressed: _testAlarmSound,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
