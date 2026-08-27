import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../providers/employee_provider.dart';
import 'add_employee_screen.dart';
import 'employee_profile_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadList();
    });
  }

  void _onSearch() {
    context.read<EmployeeProvider>().loadList(
          search: _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final state = provider.listState;
    final list = (state.data?['data'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Employees',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
              );
            },
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
            label: const Text(
              'Add',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadList(
          search: _searchController.text.trim(),
          status: _selectedStatus,
        ),
        child: Column(
          children: [
            // Search & Filter Header Bar
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search by Name, Code, Phone...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _onSearch,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Status', ''),
                        const SizedBox(width: 8),
                        _buildFilterChip('Active', 'active'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Inactive', 'inactive'),
                      ],
                    ),
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
                    return AppError(
                      message: state.message ?? 'Failed to load employees',
                      onRetry: _onSearch,
                    );
                  }
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No employees found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add New Employee', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final emp = Map<String, dynamic>.from(list[index] as Map);
                      return _buildEmployeeCard(context, emp);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D9488),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0D9488),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatus = value);
          _onSearch();
        }
      },
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Map<String, dynamic> emp) {
    final name = emp['name'] ?? '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
    final code = emp['employeeCode'] ?? 'EMP-000';
    final dept = emp['department']?['name'] ?? 'General';
    final desig = emp['designation']?['name'] ?? 'Employee';
    final phone = emp['phone'] ?? 'N/A';
    final email = emp['email'] ?? '';
    final isActive = emp['user']?['isActive'] ?? true;
    final todayAtt = emp['todayAttendance'] ?? {};
    final attStatus = todayAtt['status'] ?? 'ABSENT';

    Color attColor;
    switch (attStatus) {
      case 'PRESENT':
        attColor = Colors.green;
        break;
      case 'LATE':
        attColor = Colors.orange;
        break;
      case 'LEAVE':
        attColor = Colors.blue;
        break;
      default:
        attColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF0D9488),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'E',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: attColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Today: $attStatus',
                              style: TextStyle(color: attColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$code • $dept • $desig',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📞 $phone | ✉️ $email',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, color: Color(0xFF0D9488)),
                      tooltip: 'View Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployeeProfileScreen(employeeId: emp['id'] as int?),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isActive ? Icons.block : Icons.check_circle_outline,
                        color: isActive ? Colors.red : Colors.green,
                      ),
                      tooltip: isActive ? 'Deactivate' : 'Activate',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(isActive ? 'Deactivate Employee?' : 'Activate Employee?'),
                            content: Text('Are you sure you want to change status for $name?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<EmployeeProvider>().toggleStatus(emp['id'] as int, !isActive);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Employee status updated')),
                            );
                          }
                        }
                      },
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
