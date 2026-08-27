import 'package:flutter/material.dart';

import '../features/announcements/screens/announcements_screen.dart';
import '../features/attendance_alarms/screens/attendance_alarms_screen.dart';
import '../features/branches/screens/branch_list_screen.dart';
import '../features/company/screens/company_profile_screen.dart';
import '../features/departments/screens/department_list_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/holidays/screens/holidays_screen.dart';
import '../features/leave/screens/leave_holidays_tab_screen.dart';
import '../features/leave/screens/leave_screen.dart';
import '../features/notes/screens/notes_screen.dart';
import '../features/referral/screens/referral_screen.dart';
import '../features/roles/screens/role_list_screen.dart';
import '../features/salary/screens/salary_screen.dart';
import '../features/shifts/screens/shift_list_screen.dart';
import '../features/trips/screens/trips_screen.dart';

class AppRoutes {
  static const announcements = '/announcements';
  static const attendanceAlarms = '/attendance-alarms';
  static const leave = '/leave';
  static const leaveHolidays = '/leave-holidays';
  static const trips = '/trips';
  static const expenses = '/expenses';
  static const notes = '/notes';
  static const holidays = '/holidays';
  static const documents = '/documents';
  static const referral = '/referral';
  static const salary = '/salary';
  static const company = '/company';
  static const branches = '/branches';
  static const departments = '/departments';
  static const roles = '/roles';
  static const shifts = '/shifts';

  static final routes = <String, WidgetBuilder>{
    announcements: (_) => const AnnouncementsScreen(),
    attendanceAlarms: (_) => const AttendanceAlarmsScreen(),
    leave: (_) => const LeaveScreen(),
    leaveHolidays: (_) => const LeaveHolidaysTabScreen(),
    trips: (_) => const TripsScreen(),
    expenses: (_) => const ExpensesScreen(),
    notes: (_) => const NotesScreen(),
    holidays: (_) => const HolidaysScreen(),
    documents: (_) => const DocumentsScreen(),
    referral: (_) => const ReferralScreen(),
    salary: (_) => const SalaryScreen(),
    company: (_) => const CompanyProfileScreen(),
    branches: (_) => const BranchListScreen(),
    departments: (_) => const DepartmentListScreen(),
    roles: (_) => const RoleListScreen(),
    shifts: (_) => const ShiftListScreen(),
  };
}
