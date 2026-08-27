import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../attendance/screens/attendance_history_screen.dart';
import '../../more/screens/more_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'employee_dashboard_screen.dart';

class EmployeeHomeShell extends StatefulWidget {
  const EmployeeHomeShell({super.key});

  @override
  State<EmployeeHomeShell> createState() => _EmployeeHomeShellState();
}

class _EmployeeHomeShellState extends State<EmployeeHomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    EmployeeDashboardScreen(),
    AttendanceHistoryScreen(),
    ProfileScreen(),
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
        selectedItemColor: const Color(0xFF059669),
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_outlined), activeIcon: Icon(Icons.access_time_filled), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'More'),
        ],
      ),
    );
  }
}
