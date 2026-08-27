import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class AdminLeaveRequestsScreen extends StatefulWidget {
  const AdminLeaveRequestsScreen({super.key});

  @override
  State<AdminLeaveRequestsScreen> createState() => _AdminLeaveRequestsScreenState();
}

class _AdminLeaveRequestsScreenState extends State<AdminLeaveRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _leaveRequests = [];
  String? _actionRunningId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLeaveRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaveRequests() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final res = await apiClient.get('/leaves?all=true');
      final List data = (res is Map && res['data'] is List)
          ? res['data']
          : (res is List ? res : []);

      if (mounted) {
        setState(() {
          _leaveRequests = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load leave requests: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveLeave(int requestId) async {
    setState(() => _actionRunningId = requestId.toString());
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      await apiClient.patch('/leaves/$requestId/approve');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave Request Approved Successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _fetchLeaveRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve request: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _actionRunningId = null);
    }
  }

  Future<void> _rejectLeave(int requestId) async {
    final reasonController = TextEditingController(text: 'Rejected by Admin');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Leave Request', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please specify reason for rejection:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Reason...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('REJECT REQUEST'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _actionRunningId = requestId.toString());
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      await apiClient.patch('/leaves/$requestId/reject', data: {
        'rejectionReason': reasonController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave Request Rejected!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        _fetchLeaveRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject request: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _actionRunningId = null);
    }
  }

  List<dynamic> _filterRequests(String status) {
    if (status == 'ALL') return _leaveRequests;
    return _leaveRequests.where((req) => (req['status'] ?? '').toString().toUpperCase() == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Leave Requests Approval',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchLeaveRequests,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'PENDING (${_filterRequests("PENDING").length})'),
            Tab(text: 'APPROVED (${_filterRequests("APPROVED").length})'),
            Tab(text: 'REJECTED (${_filterRequests("REJECTED").length})'),
            Tab(text: 'ALL (${_leaveRequests.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestListView(_filterRequests('PENDING')),
                _buildRequestListView(_filterRequests('APPROVED')),
                _buildRequestListView(_filterRequests('REJECTED')),
                _buildRequestListView(_leaveRequests),
              ],
            ),
    );
  }

  Widget _buildRequestListView(List<dynamic> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No leave requests found in this category', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLeaveRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final id = item['id'];
          final status = (item['status'] ?? 'PENDING').toString().toUpperCase();
          final emp = item['employee'] ?? {};
          final empName = item['employeeName'] ?? '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
          final empCode = emp['employeeCode'] ?? 'EMP';
          final deptName = emp['department']?['name'] ?? 'General';
          final leaveTypeName = item['leaveType']?['name'] ?? item['leaveType'] ?? 'Leave';
          final startDate = item['startDate'] != null
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['startDate']))
              : '';
          final endDate = item['endDate'] != null
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['endDate']))
              : '';
          final numDays = item['numberOfDays'] ?? 1;
          final reason = item['reason'] ?? 'No reason provided';
          final isProcessing = _actionRunningId == id.toString();

          Color statusColor;
          if (status == 'APPROVED') {
            statusColor = Colors.green;
          } else if (status == 'REJECTED') {
            statusColor = Colors.red;
          } else {
            statusColor = Colors.orange.shade800;
          }

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Employee Avatar & Name + Status Badge
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          empName.isNotEmpty ? empName[0].toUpperCase() : 'E',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              empName.isNotEmpty ? empName : 'Sample Employee',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '$empCode • $deptName',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Leave Type & Duration Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            leaveTypeName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$numDays Day(s)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date range
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        '$startDate to $endDate',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Reason
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'Reason: $reason',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ),

                  // If Action Pending: Show Approve / Reject Buttons
                  if (status == 'PENDING') ...[
                    const SizedBox(height: 14),
                    if (isProcessing)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _approveLeave(id),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _rejectLeave(id),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
