import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/session/app_session.dart';
import 'core/storage/secure_storage.dart';
import 'features/announcements/providers/announcement_provider.dart';
import 'features/announcements/services/announcement_service.dart';
import 'features/attendance/providers/attendance_provider.dart';
import 'features/attendance/services/attendance_service.dart';
import 'features/attendance_alarms/providers/attendance_alarm_provider.dart';
import 'features/attendance_alarms/services/attendance_alarm_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/branches/providers/branch_provider.dart';
import 'features/branches/services/branch_service.dart';
import 'features/company/providers/company_provider.dart';
import 'features/company/services/company_service.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/services/dashboard_service.dart';
import 'features/departments/providers/department_provider.dart';
import 'features/departments/services/department_service.dart';
import 'features/documents/providers/document_provider.dart';
import 'features/documents/services/document_service.dart';
import 'features/expenses/providers/expense_provider.dart';
import 'features/expenses/services/expense_service.dart';
import 'features/holidays/providers/holiday_provider.dart';
import 'features/holidays/services/holiday_service.dart';
import 'features/leave/providers/leave_policy_provider.dart';
import 'features/leave/providers/leave_provider.dart';
import 'features/leave/services/leave_policy_service.dart';
import 'features/leave/services/leave_service.dart';
import 'features/notes/providers/notes_provider.dart';
import 'features/notes/services/notes_service.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/services/profile_service.dart';
import 'features/referral/providers/referral_provider.dart';
import 'features/referral/services/referral_service.dart';
import 'features/employees/providers/employee_provider.dart';
import 'features/employees/services/employee_api_service.dart';
import 'features/roles/providers/role_provider.dart';
import 'features/roles/services/role_service.dart';
import 'features/salary/providers/salary_provider.dart';
import 'features/salary/services/salary_service.dart';
import 'features/shifts/providers/shift_provider.dart';
import 'features/shifts/services/shift_service.dart';
import 'features/trips/providers/trip_provider.dart';
import 'features/trips/services/trip_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.instance.init();

  final storage = SecureStorage(const FlutterSecureStorage());
  final apiClient = ApiClient(storage);
  final authService = AuthService(apiClient, storage);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(DashboardService(apiClient))),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(AttendanceService(apiClient))),
        ChangeNotifierProvider(create: (_) => ProfileProvider(ProfileService(apiClient))),
        ChangeNotifierProvider(create: (_) => LeaveProvider(LeaveService(apiClient))),
        ChangeNotifierProvider(create: (_) => LeavePolicyProvider(LeavePolicyService(apiClient))),
        ChangeNotifierProvider(create: (_) => CompanyProvider(CompanyService(apiClient))),
        ChangeNotifierProvider(create: (_) => BranchProvider(BranchService(apiClient))),
        ChangeNotifierProvider(create: (_) => DepartmentProvider(DepartmentService(apiClient))),
        ChangeNotifierProvider(create: (_) => RoleProvider(RoleService(apiClient))),
        ChangeNotifierProvider(create: (_) => ShiftProvider(ShiftService(apiClient))),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider(AnnouncementService(apiClient))),
        ChangeNotifierProvider(create: (_) => AttendanceAlarmProvider(AttendanceAlarmService(apiClient))),
        ChangeNotifierProvider(create: (_) => TripProvider(TripService(apiClient))),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(ExpenseService(apiClient))),
        ChangeNotifierProvider(create: (_) => NotesProvider(NotesService(apiClient))),
        ChangeNotifierProvider(create: (_) => HolidayProvider(HolidayService(apiClient))),
        ChangeNotifierProvider(create: (_) => DocumentProvider(DocumentService(apiClient))),
        ChangeNotifierProvider(create: (_) => ReferralProvider(ReferralService(apiClient))),
        ChangeNotifierProvider(create: (_) => SalaryProvider(SalaryService(apiClient))),
        ChangeNotifierProvider(create: (_) => EmployeeProvider(EmployeeApiService(apiClient))),
        ChangeNotifierProvider(create: (_) => NotificationProvider(NotificationService(apiClient))),
      ],
      child: const EmployeeManagementApp(),
    ),
  );
}

class EmployeeManagementApp extends StatelessWidget {
  const EmployeeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
      routes: AppRoutes.routes,
    );
  }
}
