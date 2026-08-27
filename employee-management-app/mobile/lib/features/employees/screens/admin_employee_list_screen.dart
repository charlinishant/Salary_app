import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/active_filter_chip.dart';
import '../../../shared/widgets/admin_filter_bottom_sheet.dart';
import '../../../shared/widgets/search_field.dart';
import '../models/employee_model.dart';
import '../providers/employee_provider.dart';
import 'add_employee_stepper_screen.dart';
import 'admin_employee_profile_screen.dart';

class AdminEmployeeListScreen extends StatefulWidget {
  const AdminEmployeeListScreen({super.key});

  @override
  State<AdminEmployeeListScreen> createState() => _AdminEmployeeListScreenState();
}

class _AdminEmployeeListScreenState extends State<AdminEmployeeListScreen> {
  String _searchTerm = '';
  FilterState _filters = FilterState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<EmployeeProvider>().loadEmployees(
          search: _searchTerm,
          departmentId: _filters.departmentId,
          designationId: _filters.designationId,
          status: _filters.status,
        );
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminFilterBottomSheet(
        initialFilters: _filters,
        departments: const [
          {'id': 1, 'name': 'HR'},
          {'id': 2, 'name': 'Sales'},
          {'id': 3, 'name': 'Engineering'},
          {'id': 4, 'name': 'Finance'},
        ],
        designations: const [
          {'id': 1, 'name': 'HR Manager'},
          {'id': 2, 'name': 'Sales Executive'},
          {'id': 3, 'name': 'Senior Developer'},
          {'id': 4, 'name': 'Accountant'},
        ],
        shifts: const [
          {'id': 1, 'name': 'General Shift'},
          {'id': 2, 'name': 'Night Shift'},
        ],
        onApply: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final employees = employeeProvider.employees;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Employees', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hintText: 'Search employee name, code, mobile...',
                    onSearch: (term) {
                      setState(() => _searchTerm = term);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: _filters.hasFilters ? AppColors.primary : Colors.grey.shade200,
                    foregroundColor: _filters.hasFilters ? Colors.white : AppColors.textPrimary,
                  ),
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: _openFilterBottomSheet,
                ),
              ],
            ),
          ),

          // Active Filter Chips
          if (_filters.hasFilters)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_filters.departmentName != null)
                    ActiveFilterChip(
                      label: 'Dept: ${_filters.departmentName}',
                      onDeleted: () {
                        setState(() => _filters.departmentId = null);
                        _loadData();
                      },
                    ),
                  if (_filters.designationName != null)
                    ActiveFilterChip(
                      label: 'Desig: ${_filters.designationName}',
                      onDeleted: () {
                        setState(() => _filters.designationId = null);
                        _loadData();
                      },
                    ),
                  if (_filters.status != null)
                    ActiveFilterChip(
                      label: 'Status: ${_filters.status}',
                      onDeleted: () {
                        setState(() => _filters.status = null);
                        _loadData();
                      },
                    ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${employees.length} employees',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('+ Add Employee', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final res = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddEmployeeStepperScreen()),
                    );
                    if (res == true) _loadData();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: employeeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : employees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No employees found matching criteria.', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          return _buildEmployeeCard(emp);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel emp) {
    final statusColor = emp.isActive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : 'E',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
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
                          Text(
                            emp.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              emp.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${emp.employeeCode} • ${emp.designationName ?? "Staff"}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        '${emp.departmentName ?? "General"} • ${emp.phone ?? "No mobile"}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const Text('Today: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      emp.todayAttendanceStatus ?? 'Present',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: emp.todayAttendanceStatus == 'ABSENT' ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdminEmployeeProfileScreen(employeeId: emp.id),
                          ),
                        );
                      },
                      child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Editing profile for ${emp.name}')),
                        );
                      },
                      child: const Text('Edit'),
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
