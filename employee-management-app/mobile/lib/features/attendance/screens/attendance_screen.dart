import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import 'attendance_history_screen.dart';
import 'selfie_punch_screen.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AttendanceProvider>().loadToday());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Selfie Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: provider.todayState.status == LoadStatus.loading
            ? const AppLoader()
            : provider.todayState.status == LoadStatus.error
                ? AppError(message: provider.todayState.message, onRetry: provider.loadToday)
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    AppCard(child: Text(provider.punchedIn ? 'You are punched in. Ready for punch out.' : 'No active punch-in for today.')),
                    const SizedBox(height: 16),
                    AppButton(
                      label: provider.punchedIn ? 'Punch Out' : 'Punch In',
                      icon: Icons.camera_alt,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelfiePunchScreen(action: provider.punchedIn ? 'punch-out' : 'punch-in'))),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen())),
                      icon: const Icon(Icons.history),
                      label: const Text('Attendance History'),
                    ),
                  ]),
      ),
    );
  }
}
