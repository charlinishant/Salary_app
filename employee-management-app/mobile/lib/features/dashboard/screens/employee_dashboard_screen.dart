import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/session/app_session.dart';
import '../../announcements/screens/announcements_screen.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../attendance/screens/attendance_history_screen.dart';
import '../../attendance/screens/camera_selfie_attendance_screen.dart';
import '../../documents/screens/documents_screen.dart';
import '../../expenses/screens/expenses_screen.dart';
import '../../holidays/screens/holidays_screen.dart';
import '../../leave/screens/leave_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../referral/screens/referral_screen.dart';
import '../../trips/screens/trips_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadTodayAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance;
    final empName = session.selectedEmployeeName ?? 'Kuldeep Kumavat';
    final empCode = session.selectedEmployeeCode ?? 'EMP-0025';
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    final attendanceProvider = context.watch<AttendanceProvider>();
    final attendance = attendanceProvider.todayAttendance;
    final canPunchIn = attendance?.canPunchIn ?? true;
    final canPunchOut = attendance?.canPunchOut ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand Logo Bar
              Row(
                children: [
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
                      ],
                    ),
                    child: Image.asset('assets/images/yogesh_krushi_logo.jpg', fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('योगेश कृषी', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFB45118))),
                      Text('परंपरा आणि निष्ठेची समर्थ साथ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0A8F4E))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Header Greeting Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(
                        empName.isNotEmpty ? empName[0].toUpperCase() : 'E',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Good Morning 👋', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(
                            empName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text('$empCode • $formattedDate', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Attendance Status Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Attendance",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: canPunchIn
                                  ? Colors.grey.withOpacity(0.12)
                                  : Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              canPunchIn
                                  ? 'Not Punched In'
                                  : (attendance?.status ?? 'Present'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: canPunchIn ? Colors.grey.shade700 : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Punch In', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                attendance?.checkIn ?? '--:--',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Punch Out', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                attendance?.checkOut ?? '--:--',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Working Hours', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                canPunchOut
                                    ? 'Running'
                                    : (attendance?.workingHoursFormatted ?? '--'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: canPunchOut ? Colors.green : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Punch In / Punch Out button
                      if (canPunchIn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('MARK ATTENDANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CameraSelfieAttendanceScreen(isPunchOut: false),
                              ),
                            );
                            if (mounted) context.read<AttendanceProvider>().loadTodayAttendance();
                          },
                        )
                      else if (canPunchOut)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('PUNCH OUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CameraSelfieAttendanceScreen(isPunchOut: true),
                              ),
                            );
                            if (mounted) context.read<AttendanceProvider>().loadTodayAttendance();
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Attendance Completed for Today 🎉',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Responsive GridView (3 per row)
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQuickActionTile(context, 'Profile', Icons.person_outline, const Color(0xFF2563EB), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                  _buildQuickActionTile(context, 'Attendance', Icons.access_time_outlined, const Color(0xFF059669), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
                  }),
                  _buildQuickActionTile(context, 'Announce', Icons.campaign_outlined, const Color(0xFFD97706), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                  }),
                  _buildQuickActionTile(context, 'Leave', Icons.event_note_outlined, const Color(0xFF7C3AED), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaveScreen()));
                  }),
                  _buildQuickActionTile(context, 'Trips', Icons.explore_outlined, const Color(0xFFDC2626), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripsScreen()));
                  }),
                  _buildQuickActionTile(context, 'Expenses', Icons.receipt_long_outlined, const Color(0xFF0891B2), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExpensesScreen()));
                  }),
                  _buildQuickActionTile(context, 'Notes', Icons.note_alt_outlined, const Color(0xFF4B5563), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotesScreen()));
                  }),
                  _buildQuickActionTile(context, 'Holidays', Icons.beach_access_outlined, const Color(0xFF059669), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HolidaysScreen()));
                  }),
                  _buildQuickActionTile(context, 'Documents', Icons.folder_outlined, const Color(0xFF4338CA), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsScreen()));
                  }),
                  _buildQuickActionTile(context, 'Referral', Icons.card_giftcard_outlined, const Color(0xFFBE185D), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReferralScreen()));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
