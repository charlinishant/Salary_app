import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/session/app_session.dart';
import '../providers/auth_provider.dart';
import '../../employees/models/employee_model.dart';
import '../../employees/providers/employee_provider.dart';
import '../../dashboard/screens/employee_shell.dart';
import '../../dashboard/screens/employee_home_shell.dart';
import 'role_selection_screen.dart';

/// Screen allowing selection of active employee when running in dev Employee mode.
///
/// TODO: Replace selectedEmployeeId with authenticated employee ID when JWT login is added.
class EmployeeSelectorScreen extends StatefulWidget {
  const EmployeeSelectorScreen({super.key});

  @override
  State<EmployeeSelectorScreen> createState() => _EmployeeSelectorScreenState();
}

class _EmployeeSelectorScreenState extends State<EmployeeSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  EmployeeModel? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final employees = employeeProvider.employees;

    final query = _searchController.text.toLowerCase().trim();
    final filtered = employees.where((emp) {
      if (query.isEmpty) return true;
      final name = emp.name.toLowerCase();
      final code = emp.employeeCode.toLowerCase();
      final dept = (emp.departmentName ?? '').toLowerCase();
      return name.contains(query) || code.contains(query) || dept.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Employee Profile',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Switch Role',
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search employee by name, code, department...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (employeeProvider.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No employees found matching your search.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final emp = filtered[index];
                      final isSelected = _selectedEmployee?.id == emp.id ||
                          (_selectedEmployee == null &&
                              AppSession.instance.selectedEmployeeId == emp.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() => _selectedEmployee = emp);
                          },
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: Text(
                              emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : 'E',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            emp.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            '${emp.employeeCode} • ${emp.departmentName ?? "General"}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final target = _selectedEmployee ??
                      (employees.isNotEmpty
                          ? employees.firstWhere(
                              (e) => e.id == AppSession.instance.selectedEmployeeId,
                              orElse: () => employees.first,
                            )
                          : null);

                  if (target != null) {
                    await AppSession.instance.setSelectedEmployee(
                      id: target.id,
                      name: target.name,
                      code: target.employeeCode,
                    );
                    if (!context.mounted) return;
                    await context.read<AuthProvider>().login(target.employeeCode, 'Password@123');
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const EmployeeShell()),
                    );
                  }
                },
                child: const Text(
                  'CONTINUE AS EMPLOYEE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
