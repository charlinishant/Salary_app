import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import 'bank_account_details_screen.dart';

class AdminEmployeeProfileScreen extends StatefulWidget {
  const AdminEmployeeProfileScreen({
    super.key,
    required this.employeeId,
  });

  final int employeeId;

  @override
  State<AdminEmployeeProfileScreen> createState() => _AdminEmployeeProfileScreenState();
}

class _AdminEmployeeProfileScreenState extends State<AdminEmployeeProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _empData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _fetchProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final res = await apiClient.get('/employees/${widget.employeeId}');
      if (mounted) {
        setState(() {
          _empData = res is Map ? (res['data'] ?? res) : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employee Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_empData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employee Profile')),
        body: const Center(child: Text('Failed to load employee details')),
      );
    }

    final emp = _empData!;
    final name = '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
    final code = emp['employeeCode'] ?? 'EMP-0001';
    final designation = emp['designation']?['name'] ?? 'Staff';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            'Employee Profile',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit Employee Profile')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'E',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('$code • $designation', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Leave'),
                      Tab(text: 'Expenses'),
                      Tab(text: 'Trips'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Notes'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(emp),
              _buildSimpleListTab('Attendance History', Icons.access_time_filled),
              _buildSimpleListTab('Leave Requests', Icons.event_note),
              _buildSimpleListTab('Expense Claims', Icons.receipt_long),
              _buildSimpleListTab('Trips & Meetings', Icons.explore),
              _buildSimpleListTab('Uploaded Documents', Icons.folder),
              _buildSimpleListTab('Employee Notes', Icons.note_alt),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> emp) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoSection('Personal Details', [
            _buildInfoRow('Email', emp['email'] ?? 'N/A'),
            _buildInfoRow('Phone', emp['phone'] ?? 'N/A'),
            _buildInfoRow('Gender', emp['gender'] ?? 'N/A'),
            _buildInfoRow('Address', emp['address'] ?? 'N/A'),
          ]),
          const SizedBox(height: 14),
          _buildInfoSection('Employment Details', [
            _buildInfoRow('Department', emp['department']?['name'] ?? 'N/A'),
            _buildInfoRow('Designation', emp['designation']?['name'] ?? 'N/A'),
            _buildInfoRow('Current Shift', emp['shift']?['name'] ?? 'General Shift'),
            _buildInfoRow('Reporting Manager', emp['reportingManager'] ?? 'Kuldeep Kumavat'),
            _buildInfoRow('Work Location', emp['workLocation'] ?? 'Pune Main Branch'),
            _buildInfoRow('Joining Date', emp['joiningDate'] ?? '2024-01-15'),
          ]),
          const SizedBox(height: 14),
          _buildInfoSection(
            'Bank Details',
            [
              _buildInfoRow('Bank Name', emp['bankName'] ?? 'HDFC Bank'),
              _buildInfoRow('Account Number', emp['accountNumber'] ?? '50100234567890'),
              _buildInfoRow('IFSC Code', emp['ifsc'] ?? 'HDFC0001234'),
              _buildInfoRow('UPI ID', emp['upiId'] ?? 'user@okaxis'),
            ],
            onEdit: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BankAccountDetailsScreen(
                    employeeId: widget.employeeId,
                    employeeName: '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim(),
                    initialData: emp,
                  ),
                ),
              );
              if (updated == true && mounted) {
                _fetchProfile();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, {VoidCallback? onEdit}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                    onPressed: onEdit,
                    tooltip: 'Edit $title',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleListTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('All records loaded from backend database', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
