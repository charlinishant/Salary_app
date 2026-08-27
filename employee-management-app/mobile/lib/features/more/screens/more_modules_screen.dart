import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../employees/screens/admin_attendance_screen.dart';
import '../../employees/screens/add_employee_screen.dart';
import '../../employees/screens/employee_list_screen.dart';

class MoreModulesScreen extends StatelessWidget {
  const MoreModulesScreen({super.key});

  void _showEmployeeModuleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin → Employees',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF0D9488), child: Icon(Icons.people, color: Colors.white)),
              title: const Text('1. Employee List', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('View, edit, search, filter and toggle status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeListScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF0284C7), child: Icon(Icons.person_add, color: Colors.white)),
              title: const Text('2. Add Employee', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Create new employee with sections A-E'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEmployeeScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFD97706), child: Icon(Icons.co_present, color: Colors.white)),
              title: const Text('3. Attendance Management', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('View summary, selfies, and perform manual corrections'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAttendanceScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text(
          'More Modules',
          style: TextStyle(
            color: Color(0xFF1B241A),
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildModuleCard(
            context,
            title: 'Admin → Employees',
            icon: Icons.badge_outlined,
            onTap: () => _showEmployeeModuleModal(context),
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Company',
            icon: Icons.business_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.company),
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Branches',
            icon: Icons.domain_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.branches),
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Departments',
            icon: Icons.corporate_fare_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.departments),
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Roles & Permissions',
            icon: Icons.admin_panel_settings_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.roles),
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Leave & Holidays',
            icon: Icons.beach_access_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.leaveHolidays),
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Shifts',
            icon: Icons.access_time_outlined,
            onTap: () => Navigator.pushNamed(context, AppRoutes.shifts),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E9DE), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2C382A),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B241A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF2C382A),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
