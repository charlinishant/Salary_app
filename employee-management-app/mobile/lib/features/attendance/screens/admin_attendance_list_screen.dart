import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../widgets/selfie_viewer_dialog.dart';

class AdminAttendanceListScreen extends StatefulWidget {
  const AdminAttendanceListScreen({super.key});

  @override
  State<AdminAttendanceListScreen> createState() => _AdminAttendanceListScreenState();
}

class _AdminAttendanceListScreenState extends State<AdminAttendanceListScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};
  List<dynamic> _records = [];
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      String url = '/attendance/admin/list';
      if (_statusFilter.isNotEmpty) url += '?status=$_statusFilter';

      final res = await apiClient.get(url);
      if (mounted) {
        setState(() {
          _summary = res['summary'] ?? {};
          _records = res['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAttendance),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryBadge('Total', _summary['totalEmployees'] ?? 10, Colors.blue),
                  _buildSummaryBadge('Present', _summary['presentToday'] ?? 0, Colors.green),
                  _buildSummaryBadge('Absent', _summary['absentToday'] ?? 0, Colors.red),
                  _buildSummaryBadge('Late', _summary['lateToday'] ?? 0, Colors.orange),
                  _buildSummaryBadge('Leave', _summary['onLeave'] ?? 0, Colors.purple),
                ],
              ),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Status', ''),
                        _buildFilterChip('PRESENT', 'PRESENT'),
                        _buildFilterChip('LATE', 'LATE'),
                        _buildFilterChip('ABSENT', 'ABSENT'),
                        _buildFilterChip('LEAVE', 'LEAVE'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const Center(child: Text('No attendance records found.', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final rec = _records[index] as Map<String, dynamic>;
                          return _buildAttendanceCard(rec);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge(String label, int value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 12)),
        selected: isSelected,
        selectedColor: AppColors.primary,
        onSelected: (val) {
          if (val) {
            setState(() => _statusFilter = value);
            _fetchAttendance();
          }
        },
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> rec) {
    final status = rec['status'] ?? 'PRESENT';
    final punchInSelfie = rec['punchInSelfie'];
    final punchOutSelfie = rec['punchOutSelfie'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rec['employeeName'] ?? 'Employee',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'PRESENT'
                        ? Colors.green.withOpacity(0.12)
                        : status == 'LATE'
                            ? Colors.orange.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: status == 'PRESENT'
                          ? Colors.green
                          : status == 'LATE'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${rec['employeeCode'] ?? ''} • ${rec['department'] ?? 'General'}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Check In', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(rec['punchInTime'] ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Check Out', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(rec['punchOutTime'] ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Working Hours', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(rec['workingHours'] ?? '--', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (punchInSelfie != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      icon: const Icon(Icons.photo_camera, size: 16),
                      label: const Text('View Punch In Selfie', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => SelfieViewerDialog(
                            employeeName: rec['employeeName'] ?? '',
                            employeeCode: rec['employeeCode'] ?? '',
                            date: rec['date']?.toString().split('T')[0] ?? '',
                            punchType: 'Punch In',
                            time: rec['punchInTime'] ?? '',
                            selfieUrl: punchInSelfie.toString(),
                          ),
                        );
                      },
                    ),
                  ),
                if (punchInSelfie != null && punchOutSelfie != null) const SizedBox(width: 8),
                if (punchOutSelfie != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      icon: const Icon(Icons.photo_camera_front, size: 16),
                      label: const Text('View Punch Out Selfie', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => SelfieViewerDialog(
                            employeeName: rec['employeeName'] ?? '',
                            employeeCode: rec['employeeCode'] ?? '',
                            date: rec['date']?.toString().split('T')[0] ?? '',
                            punchType: 'Punch Out',
                            time: rec['punchOutTime'] ?? '',
                            selfieUrl: punchOutSelfie.toString(),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
