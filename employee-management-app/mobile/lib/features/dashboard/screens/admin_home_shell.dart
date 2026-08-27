import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../attendance/screens/admin_attendance_list_screen.dart';
import '../../employees/screens/admin_employee_list_screen.dart';
import '../../more/screens/more_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminHomeShell extends StatefulWidget {
  const AdminHomeShell({super.key});

  @override
  State<AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends State<AdminHomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    AdminEmployeeListScreen(),
    AdminAttendanceListScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Employees'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_outlined), activeIcon: Icon(Icons.access_time_filled), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'More'),
        ],
      ),
    );
  }
}
