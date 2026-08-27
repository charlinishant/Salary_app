import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/department_model.dart';
import '../providers/department_provider.dart';
import 'department_form_screen.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DepartmentProvider>().loadDepartments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DepartmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Departments', style: TextStyle(color: Color(0xFF1B241A), fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1B241A)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DepartmentFormScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            color: const Color(0xFFE5ECE2),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search departments...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Department Cards
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
                    : provider.departments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.corporate_fare_outlined, size: 64, color: AppColors.muted),
                                const SizedBox(height: 12),
                                const Text('No departments found', style: TextStyle(fontSize: 16, color: AppColors.muted)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DepartmentFormScreen()));
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Department'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.departments.length,
                            itemBuilder: (context, index) {
                              final dept = provider.departments[index];
                              return _buildDepartmentCard(context, dept);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, DepartmentModel dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9DE)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE5ECE2),
          child: Icon(Icons.corporate_fare_outlined, color: dept.isActive ? AppColors.primary : Colors.grey),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                dept.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B241A)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: dept.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dept.isActive ? 'Active' : 'Inactive',
                style: TextStyle(color: dept.isActive ? Colors.green[800] : Colors.red[800], fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Code: ${dept.code ?? 'N/A'} • Branch: ${dept.branchName}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('Head: ${dept.departmentHeadName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${dept.employeeCount} Employees', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) async {
            if (val == 'edit') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DepartmentFormScreen(department: dept)));
            } else if (val == 'delete') {
              if (dept.employeeCount > 0) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cannot Delete Department'),
                    content: Text('This department contains ${dept.employeeCount} employee(s). You cannot permanently delete a department containing employees.\n\nPlease deactivate the department instead.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                    ],
                  ),
                );
                return;
              }

              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Department'),
                  content: Text('Are you sure you want to delete ${dept.name}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );

              if (ok == true && mounted) {
                final success = await context.read<DepartmentProvider>().deleteDepartment(dept.id);
                if (!success && mounted) {
                  final err = context.read<DepartmentProvider>().error;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Failed to delete department')));
                }
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }
}
