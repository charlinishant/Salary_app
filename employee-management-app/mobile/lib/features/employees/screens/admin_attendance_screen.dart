import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../attendance/providers/attendance_provider.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final dateStr = _selectedDate.toString().split(' ')[0];
    context.read<AttendanceProvider>().loadAdminAttendance(
          date: dateStr,
          search: _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  void _showSelfieDialog(Map<String, dynamic> item) {
    final name = item['employeeName'] ?? 'Employee';
    final code = item['employeeCode'] ?? '';
    final date = item['date'] != null ? item['date'].toString().split('T')[0] : '';
    final inSelfie = item['punchInSelfie'];
    final outSelfie = item['punchOutSelfie'];
    final pIn = item['punchInTime'] ?? '--';
    final pOut = item['punchOutTime'] ?? '--';

    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$name ($code)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: $date', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Punch In Selfie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: inSelfie != null && inSelfie.toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    inSelfie.toString().startsWith('http') ? inSelfie.toString() : '$baseUrl${inSelfie.toString()}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  ),
                                )
                              : const Center(child: Text('No Selfie', style: TextStyle(fontSize: 12, color: Colors.grey))),
                        ),
                        const SizedBox(height: 4),
                        Text(pIn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Punch Out Selfie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: outSelfie != null && outSelfie.toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    outSelfie.toString().startsWith('http') ? outSelfie.toString() : '$baseUrl${outSelfie.toString()}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  ),
                                )
                              : const Center(child: Text('No Selfie', style: TextStyle(fontSize: 12, color: Colors.grey))),
                        ),
                        const SizedBox(height: 4),
                        Text(pOut, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showCorrectionDialog(Map<String, dynamic> item) {
    String status = item['status'] ?? 'PRESENT';
    final reasonController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Attendance: ${item['employeeName']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'PRESENT', child: Text('PRESENT')),
                  DropdownMenuItem(value: 'ABSENT', child: Text('ABSENT')),
                  DropdownMenuItem(value: 'LATE', child: Text('LATE')),
                  DropdownMenuItem(value: 'LEAVE', child: Text('LEAVE')),
                ],
                onChanged: (v) => setStateDialog(() => status = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Modification *',
                  hintText: 'Mandatory audit reason',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: 'Notes / Remarks',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reason for Modification is required!'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await context.read<AttendanceProvider>().adminCorrectAttendance(
                        item['id'] as int,
                        status: status,
                        changeReason: reasonController.text.trim(),
                        remarks: remarksController.text.trim(),
                      );
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance updated with audit log!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final state = provider.adminAttendanceState;
    final summary = (state.data?['summary'] as Map?) ?? {};
    final list = (state.data?['data'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Attendance Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: Column(
          children: [
            // Date Banner & Search Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${_selectedDate.toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.edit_calendar, size: 16, color: Color(0xFF0D9488)),
                        label: const Text('Change Date', style: TextStyle(color: Color(0xFF0D9488))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _loadData(),
                    decoration: InputDecoration(
                      hintText: 'Search employee...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                      suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _loadData),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            // Top Summary Cards Grid
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildSummaryCard('Total', '${summary['totalEmployees'] ?? 0}', Colors.blue),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Present', '${summary['presentToday'] ?? 0}', Colors.green),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Absent', '${summary['absentToday'] ?? 0}', Colors.red),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Late', '${summary['lateToday'] ?? 0}', Colors.orange),
                ],
              ),
            ),

            // Attendance List
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.status == LoadStatus.loading) {
                    return const AppLoader();
                  }
                  if (state.status == LoadStatus.error) {
                    return AppError(message: state.message ?? 'Failed to load attendance', onRetry: _loadData);
                  }
                  if (list.isEmpty) {
                    return const Center(child: Text('No attendance records found for this date.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = Map<String, dynamic>.from(list[index] as Map);
                      return _buildAttendanceRowCard(item);
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

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRowCard(Map<String, dynamic> item) {
    final name = item['employeeName'] ?? 'Employee';
    final code = item['employeeCode'] ?? '';
    final dept = item['department'] ?? '';
    final pIn = item['punchInTime'] ?? '--';
    final pOut = item['punchOutTime'] ?? '--';
    final status = item['status'] ?? 'ABSENT';
    final workHrs = item['workingHours'] ?? '--';

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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('$code • $dept', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Punch In', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(pIn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Punch Out', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(pOut, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hours', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(workHrs, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0D9488), size: 20),
                      tooltip: 'View Selfies',
                      onPressed: () => _showSelfieDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue, size: 22),
                      tooltip: 'Edit Attendance',
                      onPressed: () => _showCorrectionDialog(item),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
