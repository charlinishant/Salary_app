import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};
  List<dynamic> _deptStats = [];
  List<dynamic> _recentEmps = [];
  List<dynamic> _recentAttendance = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final res = await apiClient.get('/dashboard/admin');
      final Map<String, dynamic> payload = (res is Map<String, dynamic> && res['data'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(res['data'])
          : (res is Map<String, dynamic> ? res : {});

      if (mounted) {
        setState(() {
          _summary = (payload['summary'] is Map) ? Map<String, dynamic>.from(payload['summary']) : {};
          _deptStats = (payload['departmentStats'] is List) ? List.from(payload['departmentStats']) : [];
          _recentEmps = (payload['recentEmployees'] is List) ? List.from(payload['recentEmployees']) : [];
          _recentAttendance = (payload['recentAttendance'] is List) ? List.from(payload['recentAttendance']) : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: Image.asset('assets/images/yogesh_krushi_logo.jpg', fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            const Text('योगेश कृषी Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchDashboardData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Executive Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Grid of 10 Summary Cards
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 2.1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard('Total Employees', _summary['totalEmployees'] ?? 0, Icons.people, const Color(0xFF1E3A8A)),
                        _buildStatCard('Active Employees', _summary['activeEmployees'] ?? 0, Icons.person_outline, const Color(0xFF059669)),
                        _buildStatCard('Present Today', _summary['presentToday'] ?? 0, Icons.check_circle_outline, Colors.green),
                        _buildStatCard('Absent Today', _summary['absentToday'] ?? 0, Icons.cancel_outlined, Colors.red),
                        _buildStatCard('Late Today', _summary['lateToday'] ?? 0, Icons.alarm_on, Colors.orange),
                        _buildStatCard('On Leave', _summary['onLeave'] ?? 0, Icons.event_available, Colors.purple),
                        _buildStatCard('Punched In', _summary['punchedIn'] ?? 0, Icons.login, Colors.teal),
                        _buildStatCard('Punch Completed', _summary['punchCompleted'] ?? 0, Icons.logout, Colors.indigo),
                        _buildStatCard('Pending Leaves', _summary['pendingLeaves'] ?? 0, Icons.pending_actions, Colors.amber.shade900, onTap: () {
                          Navigator.pushNamed(context, AppRoutes.adminLeaveRequests);
                        }),
                        _buildStatCard('Pending Expenses', _summary['pendingExpenses'] ?? 0, Icons.payments_outlined, Colors.deepOrange),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text('Department Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Department stats cards
                    ..._deptStats.map((dept) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.business, color: Colors.white, size: 20),
                            ),
                            title: Text(dept['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Present: ${dept['presentToday']} / ${dept['totalEmployees']} employees'),
                            trailing: Text(
                              '${dept['totalEmployees'] > 0 ? ((dept['presentToday'] / dept['totalEmployees']) * 100).round() : 0}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ),
                        )),

                    const SizedBox(height: 20),
                    const Text('Recent Employees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    ..._recentEmps.map((emp) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.12),
                              child: Text(emp['name']?[0] ?? 'E', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                            title: Text(emp['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${emp['code']} • ${emp['department']}'),
                          ),
                        )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
