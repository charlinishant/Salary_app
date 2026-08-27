import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class MoreModulesScreen extends StatelessWidget {
  const MoreModulesScreen({super.key});

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
            title: 'Company',
            icon: Icons.business_outlined,
            route: AppRoutes.company,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Branches',
            icon: Icons.domain_outlined,
            route: AppRoutes.branches,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Departments',
            icon: Icons.corporate_fare_outlined,
            route: AppRoutes.departments,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Roles & Permissions',
            icon: Icons.admin_panel_settings_outlined,
            route: AppRoutes.roles,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Leave & Holidays',
            icon: Icons.beach_access_outlined,
            route: AppRoutes.leaveHolidays,
          ),
          const SizedBox(height: 12),
          _buildModuleCard(
            context,
            title: 'Shifts',
            icon: Icons.access_time_outlined,
            route: AppRoutes.shifts,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
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
          onTap: () {
            Navigator.pushNamed(context, route);
          },
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
