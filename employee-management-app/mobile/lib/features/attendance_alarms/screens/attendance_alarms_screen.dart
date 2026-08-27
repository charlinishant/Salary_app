import 'package:flutter/material.dart';
import '../../common/module_screen.dart';
import '../providers/attendance_alarm_provider.dart';
class AttendanceAlarmsScreen extends StatelessWidget { const AttendanceAlarmsScreen({super.key}); @override Widget build(BuildContext context) => const ModuleScreen<AttendanceAlarmProvider>(title: 'Attendance Alarms'); }
