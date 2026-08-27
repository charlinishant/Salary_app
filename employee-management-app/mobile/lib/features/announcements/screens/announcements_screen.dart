import 'package:flutter/material.dart';
import '../../common/module_screen.dart';
import '../providers/announcement_provider.dart';
class AnnouncementsScreen extends StatelessWidget { const AnnouncementsScreen({super.key}); @override Widget build(BuildContext context) => const ModuleScreen<AnnouncementProvider>(title: 'Announcements'); }
