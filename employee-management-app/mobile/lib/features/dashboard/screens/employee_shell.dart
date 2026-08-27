import 'package:flutter/material.dart';
import '../../attendance/screens/attendance_camera_screen.dart';
import '../../employees/screens/employee_profile_screen.dart';
import '../../leave/screens/leave_screen.dart';
import 'dashboard_screen.dart';

class EmployeeShell extends StatefulWidget {
  const EmployeeShell({super.key});

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> {
  int _selectedIndex = 0;

  final _pages = const [
    DashboardScreen(),
    LeaveScreen(),
    EmployeeProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF0D9488),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint),
              activeIcon: Icon(Icons.fingerprint, size: 28),
              label: 'Mark Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.beach_access_outlined),
              activeIcon: Icon(Icons.beach_access, size: 28),
              label: 'Leaves',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
