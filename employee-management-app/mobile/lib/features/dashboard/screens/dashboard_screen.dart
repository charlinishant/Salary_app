import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../core/config/app_config.dart';
import '../../../routes/app_routes.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../attendance/screens/attendance_camera_screen.dart';
import '../../attendance/screens/attendance_history_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../employees/screens/admin_attendance_screen.dart';
import '../../employees/screens/add_employee_screen.dart';
import '../../employees/screens/employee_list_screen.dart';
import '../../employees/screens/employee_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final employee = authProvider.state.data;
    final attProvider = context.watch<AttendanceProvider>();
    final todayData = attProvider.todayState.data?['attendance'] ?? attProvider.todayState.data ?? {};

    final isAdminView = authProvider.isAdmin;
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    final checkIn = todayData['checkIn'] ?? todayData['punchInTime'];
    final checkOut = todayData['checkOut'] ?? todayData['punchOutTime'];
    final workMins = todayData['workingMinutes'] ?? 0;
    final hrs = workMins is int ? workMins ~/ 60 : 0;
    final mins = workMins is int ? workMins % 60 : 0;

    final isPunchedIn = checkIn != null && (checkOut == null || checkOut == '--');
    final isPunchedOut = checkIn != null && checkOut != null && checkOut != '--';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(AppConfig.logoAsset, height: 36, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'YOGESH KRUSHI SEVA KENDRA',
                style: TextStyle(color: Color(0xFF1B241A), fontSize: 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF1B241A)),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AttendanceProvider>().loadToday();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // PROMINENT 1-TAP VIEW TOGGLE (ADMIN VIEW vs EMPLOYEE VIEW)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => authProvider.switchToAdminView(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isAdminView ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 18,
                              color: isAdminView ? Colors.white : Colors.grey[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Admin View',
                              style: TextStyle(
                                color: isAdminView ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => authProvider.switchToEmployeeView(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isAdminView ? const Color(0xFF0D9488) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_pin_circle_rounded,
                              size: 18,
                              color: !isAdminView ? Colors.white : Colors.grey[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Employee View',
                              style: TextStyle(
                                color: !isAdminView ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header User Greeting Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isAdminView ? const Color(0xFF1E293B) : const Color(0xFF0D9488),
                    backgroundImage: employee?.profilePhoto != null
                        ? NetworkImage(employee!.profilePhoto!.startsWith('http') ? employee.profilePhoto! : '$baseUrl${employee.profilePhoto}')
                        : null,
                    child: employee?.profilePhoto == null
                        ? Text(
                            employee?.name.isNotEmpty == true ? employee!.name[0].toUpperCase() : 'E',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAdminView ? 'Active Mode: ADMIN' : 'Active Mode: EMPLOYEE',
                          style: TextStyle(
                            color: isAdminView ? const Color(0xFF1E293B) : const Color(0xFF0D9488),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          employee?.name ?? (isAdminView ? 'System Administrator' : 'Kuldeep Kumavat'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          '${employee?.employeeCode ?? (isAdminView ? 'ADM-001' : 'EMP-0025')} • Tap toggle above to change mode',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IF ADMIN VIEW ACTIVE: Show Admin Modules & Direct Controls
            if (isAdminView) ...[
              const Text(
                'Admin Management Controls',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),

              _buildAdminActionTile(
                context,
                title: '1. Employee List',
                subtitle: 'View all employees, search, filter & toggle active/inactive status',
                icon: Icons.people_alt_outlined,
                color: const Color(0xFF0D9488),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeListScreen()));
                },
              ),
              const SizedBox(height: 10),

              _buildAdminActionTile(
                context,
                title: '2. Add New Employee',
                subtitle: 'Create employee record with auto EMP-XXXX ID across 5 sections',
                icon: Icons.person_add_alt_1_outlined,
                color: const Color(0xFF0284C7),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEmployeeScreen()));
                },
              ),
              const SizedBox(height: 10),

              _buildAdminActionTile(
                context,
                title: '3. Attendance Management',
                subtitle: 'View summary metrics, check selfie photos & perform manual corrections',
                icon: Icons.co_present_outlined,
                color: const Color(0xFFD97706),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAttendanceScreen()));
                },
              ),
              const SizedBox(height: 20),
            ],

            // IF EMPLOYEE VIEW ACTIVE (or on both): Show Camera Selfie Attendance Card
            const Text(
              'Selfie Attendance Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),

            // SALARYBOX-STYLE CAMERA SELFIE ATTENDANCE CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Attendance",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isPunchedIn || isPunchedOut) ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPunchedOut ? 'Completed' : (isPunchedIn ? 'Present' : 'Not Punched In'),
                          style: TextStyle(
                            color: (isPunchedIn || isPunchedOut) ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Punch In', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            checkIn ?? '--:--',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Text('Punch Out', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            checkOut ?? '--:--',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Text('Working Hours', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            isPunchedOut ? '${hrs}h ${mins}m' : (isPunchedIn ? 'Running' : '--'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Dynamic Punch Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPunchedOut
                            ? Colors.grey
                            : (isPunchedIn ? const Color(0xFFDC2626) : const Color(0xFF0D9488)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      icon: Icon(
                        isPunchedOut ? Icons.check_circle : (isPunchedIn ? Icons.logout : Icons.camera_front),
                        color: Colors.white,
                      ),
                      label: Text(
                        isPunchedOut ? 'ATTENDANCE COMPLETED TODAY' : (isPunchedIn ? 'PUNCH OUT' : 'MARK ATTENDANCE'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      onPressed: isPunchedOut
                          ? null
                          : () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttendanceCameraScreen(isPunchIn: !isPunchedIn),
                                ),
                              );
                              if (updated == true && context.mounted) {
                                context.read<AttendanceProvider>().loadToday();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Access Grid
            const Text(
              'Quick Access Tools',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),

            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _buildGridOption(
                  context,
                  title: 'Profile',
                  icon: Icons.person_outline,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeProfileScreen()));
                  },
                ),
                _buildGridOption(
                  context,
                  title: 'View Attendance',
                  icon: Icons.calendar_today_outlined,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
                  },
                ),
                _buildGridOption(
                  context,
                  title: 'Announcements',
                  icon: Icons.campaign_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.announcements),
                ),
                _buildGridOption(
                  context,
                  title: 'Set alarm',
                  icon: Icons.alarm_outlined,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.attendanceAlarms),
                ),
                _buildGridOption(
                  context,
                  title: 'Request Leave',
                  icon: Icons.beach_access_outlined,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.leave),
                ),
                _buildGridOption(
                  context,
                  title: 'Expenses',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.amber,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.expenses),
                ),
                _buildGridOption(
                  context,
                  title: 'Notes',
                  icon: Icons.note_alt_outlined,
                  color: Colors.indigo,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
                ),
                _buildGridOption(
                  context,
                  title: 'Holiday List',
                  icon: Icons.event_outlined,
                  color: Colors.pink,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.holidays),
                ),
                _buildGridOption(
                  context,
                  title: 'Referral',
                  icon: Icons.card_giftcard_outlined,
                  color: Colors.deepOrange,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.referral),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          radius: 22,
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildGridOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
