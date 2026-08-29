import 'package:flutter/material.dart';

import '../features/announcements/screens/announcements_screen.dart';
import '../features/attendance_alarms/screens/attendance_alarms_screen.dart';
import '../features/branches/screens/branch_list_screen.dart';
import '../features/company/screens/company_profile_screen.dart';
import '../features/departments/screens/department_list_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/expenses/screens/request_reimbursement_screen.dart';
import '../features/holidays/screens/holidays_screen.dart';
import '../features/leave/screens/admin_leave_requests_screen.dart';
import '../features/leave/screens/leave_holidays_tab_screen.dart';
import '../features/leave/screens/leave_screen.dart';
import '../features/notes/screens/notes_screen.dart';
import '../features/referral/screens/referral_screen.dart';
import '../features/roles/screens/role_list_screen.dart';
import '../features/salary/screens/salary_screen.dart';
import '../features/shifts/screens/shift_list_screen.dart';
import '../features/trips/screens/trips_screen.dart';

class ModuleItem {
  final String label;
  final IconData icon;
  final String route;

  const ModuleItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class AppRoutes {
  static const announcements = '/announcements';
  static const attendanceAlarms = '/attendance-alarms';
  static const leave = '/leave';
  static const adminLeaveRequests = '/admin-leave-requests';
  static const leaveHolidays = '/leave-holidays';
  static const trips = '/trips';
  static const expenses = '/expenses';
  static const reimbursements = '/reimbursements';
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

  static final modules = <ModuleItem>[
    const ModuleItem(label: 'Leave', icon: Icons.beach_access_outlined, route: leave),
    const ModuleItem(label: 'Leave Approvals', icon: Icons.approval_outlined, route: adminLeaveRequests),
    const ModuleItem(label: 'Trips', icon: Icons.directions_car_outlined, route: trips),
    const ModuleItem(label: 'Expenses', icon: Icons.receipt_long_outlined, route: expenses),
    const ModuleItem(label: 'Notes', icon: Icons.note_alt_outlined, route: notes),
    const ModuleItem(label: 'Holidays', icon: Icons.event_outlined, route: holidays),
    const ModuleItem(label: 'Documents', icon: Icons.folder_outlined, route: documents),
    const ModuleItem(label: 'Referral', icon: Icons.card_giftcard_outlined, route: referral),
    const ModuleItem(label: 'Salary', icon: Icons.account_balance_wallet_outlined, route: salary),
    const ModuleItem(label: 'Announcements', icon: Icons.campaign_outlined, route: announcements),
  ];

  static final routes = <String, WidgetBuilder>{
    announcements: (_) => const AnnouncementsScreen(),
    attendanceAlarms: (_) => const AttendanceAlarmsScreen(),
    leave: (_) => const LeaveScreen(),
    adminLeaveRequests: (_) => const AdminLeaveRequestsScreen(),
    leaveHolidays: (_) => const LeaveHolidaysTabScreen(),
    trips: (_) => const TripsScreen(),
    expenses: (_) => const ExpensesScreen(),
    reimbursements: (_) => const RequestReimbursementScreen(),
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
