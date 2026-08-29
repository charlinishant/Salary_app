import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/session/app_session.dart';
import '../../announcements/screens/announcements_screen.dart';
import '../../auth/screens/employee_selector_screen.dart';
import '../../auth/screens/role_selection_screen.dart';
import '../../documents/screens/documents_screen.dart';
import '../../expenses/screens/expenses_screen.dart';
import '../../expenses/screens/request_reimbursement_screen.dart';
import '../../holidays/screens/holidays_screen.dart';
import '../../leave/screens/leave_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../referral/screens/referral_screen.dart';
import '../../reports/screens/admin_reports_screen.dart';
import '../../trips/screens/trips_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance;
    final isAdmin = session.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Management' : 'More Modules', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isAdmin) ...[
              _buildSectionHeader('Communication & Tasks'),
              _buildTile(context, 'Announcements', Icons.campaign_outlined, const Color(0xFFD97706), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
              }),
              _buildTile(context, 'Employee Notes', Icons.note_alt_outlined, const Color(0xFF4B5563), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotesScreen()));
              }),
              const SizedBox(height: 16),
              _buildSectionHeader('Workforce Requests'),
              _buildTile(context, 'Leave Management', Icons.event_note_outlined, const Color(0xFF7C3AED), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaveScreen()));
              }),
              _buildTile(context, 'Trips & Meetings', Icons.explore_outlined, const Color(0xFFDC2626), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripsScreen()));
              }),
              _buildTile(context, 'Expense Reimbursement', Icons.receipt_long_outlined, const Color(0xFF0891B2), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestReimbursementScreen()));
              }),
              const SizedBox(height: 16),
              _buildSectionHeader('Organization & Benefits'),
              _buildTile(context, 'Holiday Calendar', Icons.beach_access_outlined, const Color(0xFF059669), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HolidaysScreen()));
              }),
              _buildTile(context, 'My Documents', Icons.folder_outlined, const Color(0xFF4338CA), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsScreen()));
              }),
              _buildTile(context, 'Referral Programme', Icons.card_giftcard_outlined, const Color(0xFFBE185D), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReferralScreen()));
              }),
            ] else ...[
              _buildSectionHeader('Admin Management Modules'),
              _buildTile(context, 'Leave Management', Icons.event_note_outlined, const Color(0xFF7C3AED), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaveScreen()));
              }),
              _buildTile(context, 'Expense Claims', Icons.receipt_long_outlined, const Color(0xFF0891B2), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExpensesScreen()));
              }),
              _buildTile(context, 'Announcements', Icons.campaign_outlined, const Color(0xFFD97706), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
              }),
              _buildTile(context, 'Trips & Meetings', Icons.explore_outlined, const Color(0xFFDC2626), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripsScreen()));
              }),
              _buildTile(context, 'Holiday Calendar', Icons.beach_access_outlined, const Color(0xFF059669), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HolidaysScreen()));
              }),
              _buildTile(context, 'Documents Repository', Icons.folder_outlined, const Color(0xFF4338CA), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsScreen()));
              }),
              _buildTile(context, 'Executive Reports', Icons.insert_chart_outlined_rounded, const Color(0xFF1E3A8A), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminReportsScreen()));
              }),
            ],

            const SizedBox(height: 20),
            _buildSectionHeader('System & Switch Options'),

            if (!isAdmin)
              _buildTile(context, 'Change Employee Profile', Icons.swap_horizontal_circle_outlined, const Color(0xFF0284C7), () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmployeeSelectorScreen()));
              }),

            _buildTile(context, 'Switch Role (Admin / Employee)', Icons.published_with_changes_rounded, const Color(0xFFEA580C), () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
