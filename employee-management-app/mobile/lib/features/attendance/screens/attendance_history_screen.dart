import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AttendanceProvider>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AttendanceProvider>().historyState;
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: state.status == LoadStatus.loading
          ? const AppLoader()
          : state.status == LoadStatus.error
              ? AppError(message: state.message, onRetry: context.read<AttendanceProvider>().loadHistory)
              : state.status == LoadStatus.empty
                  ? const EmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: state.data!.map((row) => ListTile(
                        title: Text(row['attendanceDate']?.toString() ?? 'Date'),
                        subtitle: Text('In: ${row['punchInTime'] ?? '--'}  Out: ${row['punchOutTime'] ?? '--'}'),
                        trailing: Text(row['attendanceStatus']?.toString() ?? ''),
                      )).toList(),
                    ),
    );
  }
}
