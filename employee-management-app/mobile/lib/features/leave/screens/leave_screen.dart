import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  bool _isHalfDay = false;
  int? _selectedLeaveTypeId;
  List<dynamic> _leaveTypes = [];
  List<dynamic> _leaveBalances = [];
  List<dynamic> _myRequests = [];
  bool _isLoading = true;
  final _reasonController = TextEditingController();
  File? _attachmentFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);

      final responses = await Future.wait([
        apiClient.get('/leaves/types'),
        apiClient.get('/leaves/balance'),
        apiClient.get('/leaves'),
      ]);

      final types = (responses[0] is Map && responses[0]['data'] is List)
          ? responses[0]['data']
          : (responses[0] is List ? responses[0] : []);
      final balances = (responses[1] is Map && responses[1]['data'] is List)
          ? responses[1]['data']
          : (responses[1] is List ? responses[1] : []);
      final requests = (responses[2] is Map && responses[2]['data'] is List)
          ? responses[2]['data']
          : (responses[2] is List ? responses[2] : []);

      if (mounted) {
        setState(() {
          _leaveTypes = types;
          _leaveBalances = balances;
          _myRequests = requests;
          if (types.isNotEmpty && _selectedLeaveTypeId == null) {
            _selectedLeaveTypeId = types[0]['id'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _attachmentFile = File(result.files.single.path!));
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reason for leave'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_selectedLeaveTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select leave type'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final days = _isHalfDay ? 0.5 : (_toDate.difference(_fromDate).inDays + 1);

      await apiClient.post('/leaves', data: {
        'leaveTypeId': _selectedLeaveTypeId,
        'startDate': DateFormat('yyyy-MM-dd').format(_fromDate),
        'endDate': DateFormat('yyyy-MM-dd').format(_toDate),
        'numberOfDays': days > 0 ? days : 1,
        'isHalfDay': _isHalfDay,
        'reason': _reasonController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted successfully! Pending Admin Approval.'), backgroundColor: Colors.green),
        );
        _reasonController.clear();
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit leave request: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showRequestLeaveModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Request Leave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // Date Selection Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('From date *', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _fromDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setStateModal(() => _fromDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(DateFormat('d MMM yyyy').format(_fromDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('To date *', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _toDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setStateModal(() => _toDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(DateFormat('d MMM yyyy').format(_toDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Half Day Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isHalfDay,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (val) => setStateModal(() => _isHalfDay = val ?? false),
                    ),
                    const Text('Request leave for half day', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),

                // Leave Type Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedLeaveTypeId,
                  decoration: InputDecoration(
                    labelText: 'Leave Type *',
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _leaveTypes.map<DropdownMenuItem<int>>((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'],
                      child: Text(type['name'] ?? 'Leave'),
                    );
                  }).toList(),
                  onChanged: (val) => setStateModal(() => _selectedLeaveTypeId = val),
                ),
                const SizedBox(height: 14),

                // Reason for Leave
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason of leave *',
                    hintText: 'Enter reason for requesting leave...',
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // Add Attachment Section
                const Text('Add Image / Document', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickAttachment,
                  child: Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
                    ),
                    child: _attachmentFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_attachmentFile!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF0D9488)),
                              SizedBox(height: 4),
                              Text('ADD FILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _submitLeaveRequest,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Request Leave', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = _myRequests.where((req) => (req['status'] ?? '').toString().toUpperCase() == 'PENDING').toList();
    final historicalRequests = _myRequests.where((req) => (req['status'] ?? '').toString().toUpperCase() != 'PENDING').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Leave Requests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0D9488),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'PENDING (${pendingRequests.length})'),
            Tab(text: 'HISTORY (${historicalRequests.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pending Leave Requests
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Leave Balance Cards Row
                      const Text('Leave Balance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 10),
                      if (_leaveBalances.isEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildBalanceCard('Casual Leave', '8', 'days', Colors.teal),
                              const SizedBox(width: 10),
                              _buildBalanceCard('Sick Leave', '6', 'days', Colors.orange),
                              const SizedBox(width: 10),
                              _buildBalanceCard('Privilege Leave', '12', 'days', Colors.purple),
                            ],
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _leaveBalances.map((bal) {
                              final name = bal['leaveType']?['name'] ?? 'Leave';
                              final rem = (bal['remainingDays'] ?? 10).toString();
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: _buildBalanceCard(name, rem, 'days', AppColors.primary),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 20),

                      const Text('Pending Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 12),

                      if (pendingRequests.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available_outlined, size: 56, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No Pending Leave Requests', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      else
                        ...pendingRequests.map((item) {
                          final leaveTypeName = item['leaveType']?['name'] ?? 'Leave';
                          final startDate = item['startDate'] != null
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['startDate']))
                              : '';
                          final endDate = item['endDate'] != null
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['endDate']))
                              : '';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: _buildHistoryTile(leaveTypeName, '$startDate - $endDate', 'PENDING', Colors.orange.shade800),
                          );
                        }),
                    ],
                  ),
                ),

                // Tab 2: History View (Approved & Rejected)
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: historicalRequests.isEmpty
                      ? const Center(
                          child: Text('No previous leave history', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: historicalRequests.length,
                          itemBuilder: (context, index) {
                            final item = historicalRequests[index];
                            final status = (item['status'] ?? 'APPROVED').toString().toUpperCase();
                            final leaveTypeName = item['leaveType']?['name'] ?? 'Leave';
                            final startDate = item['startDate'] != null
                                ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['startDate']))
                                : '';
                            final endDate = item['endDate'] != null
                                ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['endDate']))
                                : '';
                            final color = status == 'APPROVED' ? Colors.green : Colors.red;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: _buildHistoryTile(leaveTypeName, '$startDate - $endDate', status, color),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestLeaveModal,
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Apply Leave', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String count, String unit, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String dates, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(dates, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
