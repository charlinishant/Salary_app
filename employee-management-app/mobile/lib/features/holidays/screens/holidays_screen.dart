import 'package:flutter/material.dart';
import '../../common/module_screen.dart';
import '../providers/holiday_provider.dart';
class HolidaysScreen extends StatelessWidget { const HolidaysScreen({super.key}); @override Widget build(BuildContext context) => const ModuleScreen<HolidayProvider>(title: 'Holiday Calendar'); }
