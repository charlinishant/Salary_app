import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedReport = 'Attendance Report';
  bool _isLoading = false;
  List<dynamic> _reportData = [];

  final List<String> _reportTypes = [
    'Employee Report',
    'Attendance Report',
    'Late Attendance Report',
    'Working Hours Report',
    'Leave Report',
    'Expense Report',
    'Documents Report',
  ];

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      String endpoint = '/reports/attendance';
      if (_selectedReport == 'Employee Report') endpoint = '/reports/employees';
      if (_selectedReport == 'Late Attendance Report') endpoint = '/reports/late-attendance';
      if (_selectedReport == 'Working Hours Report') endpoint = '/reports/working-hours';
      if (_selectedReport == 'Leave Report') endpoint = '/reports/leave';
      if (_selectedReport == 'Expense Report') endpoint = '/reports/expenses';
      if (_selectedReport == 'Documents Report') endpoint = '/reports/documents';

      final res = await apiClient.get(endpoint);
      if (mounted) {
        setState(() {
          _reportData = res is List ? res : (res['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reportData = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReport,
                  isExpanded: true,
                  items: _reportTypes
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedReport = val);
                      _fetchReport();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Records: ${_reportData.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: _fetchReport,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reportData.isEmpty
                      ? const Center(
                          child: Text('No report records found.', style: TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: _reportData.length,
                          itemBuilder: (context, index) {
                            final item = _reportData[index] as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.12),
                                  child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                                title: Text(
                                  item['employeeName'] ?? item['name'] ?? 'Record #${item['id']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(_formatReportSubtitle(item)),
                                trailing: _formatReportBadge(item),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReportSubtitle(Map<String, dynamic> item) {
    if (item.containsKey('date')) return 'Date: ${item['date']} • Dept: ${item['department'] ?? 'N/A'}';
    if (item.containsKey('email')) return 'Email: ${item['email']} • ${item['department'] ?? 'N/A'}';
    if (item.containsKey('fromDate')) return 'From: ${item['fromDate']} to ${item['toDate']}';
    if (item.containsKey('amount')) return 'Amount: ₹${item['amount']} • ${item['category'] ?? 'N/A'}';
    return 'Dept: ${item['department'] ?? 'N/A'}';
  }

  Widget _formatReportBadge(Map<String, dynamic> item) {
    final status = item['status'] ?? item['workingHours'] ?? '--';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}
