import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  const AttendanceSuccessScreen({
    super.key,
    required this.isPunchIn,
    required this.employeeName,
    required this.punchTime,
    this.workingHoursFormatted,
  });

  final bool isPunchIn;
  final String employeeName;
  final String punchTime;
  final String? workingHoursFormatted;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Checkmark Circle Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D9488),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                ),
                const SizedBox(height: 24),

                Text(
                  isPunchIn ? '✓ Attendance Marked' : '✓ Punch Out Successful',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 20),

                // Confirmation Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Employee', employeeName),
                      const Divider(height: 24),
                      _buildDetailRow('Date', dateStr),
                      const Divider(height: 24),
                      _buildDetailRow(isPunchIn ? 'Punch In Time' : 'Punch Out Time', punchTime),
                      if (!isPunchIn && workingHoursFormatted != null) ...[
                        const Divider(height: 24),
                        _buildDetailRow('Working Hours', workingHoursFormatted!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
      ],
    );
  }
}
