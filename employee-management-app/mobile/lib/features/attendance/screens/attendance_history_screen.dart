import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _loadHistory() {
    context.read<AttendanceProvider>().loadHistory(
          month: _selectedMonth,
          year: _selectedYear,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final state = provider.historyState;
    final list = state.data ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Attendance History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        child: Column(
          children: [
            // Month Selector Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Month:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  DropdownButton<int>(
                    value: _selectedMonth,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('January')),
                      DropdownMenuItem(value: 2, child: Text('February')),
                      DropdownMenuItem(value: 3, child: Text('March')),
                      DropdownMenuItem(value: 4, child: Text('April')),
                      DropdownMenuItem(value: 5, child: Text('May')),
                      DropdownMenuItem(value: 6, child: Text('June')),
                      DropdownMenuItem(value: 7, child: Text('July')),
                      DropdownMenuItem(value: 8, child: Text('August')),
                      DropdownMenuItem(value: 9, child: Text('September')),
                      DropdownMenuItem(value: 10, child: Text('October')),
                      DropdownMenuItem(value: 11, child: Text('November')),
                      DropdownMenuItem(value: 12, child: Text('December')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedMonth = val);
                        _loadHistory();
                      }
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.status == LoadStatus.loading) {
                    return const AppLoader();
                  }
                  if (state.status == LoadStatus.error) {
                    return AppError(message: state.message ?? 'Failed to load history', onRetry: _loadHistory);
                  }
                  if (list.isEmpty) {
                    return const Center(child: Text('No attendance history found for this month.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _buildHistoryCard(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final dateStr = item['date'] != null ? item['date'].toString().split('T')[0] : 'Date';
    final status = item['status'] ?? 'PRESENT';
    final checkIn = item['checkIn'] ?? '--';
    final checkOut = item['checkOut'] ?? '--';
    final workHrs = item['workingHoursFormatted'] ?? '--';

    Color statusColor;
    switch (status) {
      case 'PRESENT':
        statusColor = Colors.green;
        break;
      case 'LATE':
        statusColor = Colors.orange;
        break;
      case 'LEAVE':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  dateStr.length >= 10 ? dateStr.substring(8, 10) : dateStr,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$checkIn → $checkOut', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Working Hours: $workHrs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
