import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/employee_provider.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key, this.employeeId});
  final int? employeeId;

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.employeeId != null) {
        context.read<EmployeeProvider>().loadDetail(widget.employeeId!);
      }
    });
  }

  void _showSectionDialog(String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(child: SingleChildScrollView(child: content)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthEmployee = context.watch<AuthProvider>().state.data;
    final detailState = context.watch<EmployeeProvider>().detailState;

    final empData = widget.employeeId != null
        ? (detailState.data?['data'] as Map<String, dynamic>?)
        : null;

    final name = empData != null
        ? (empData['name'] ?? '${empData['firstName'] ?? ''} ${empData['lastName'] ?? ''}'.trim())
        : (currentAuthEmployee?.name ?? 'Kuldeep Kumavat');

    final code = empData != null ? (empData['employeeCode'] ?? 'EMP-0025') : (currentAuthEmployee?.employeeCode ?? 'EMP-0025');
    final desig = empData != null ? (empData['designation']?['name'] ?? 'Sales Executive') : 'Sales Executive';
    final phone = empData != null ? (empData['phone'] ?? '91-7249766173') : '91-7249766173';
    final photo = empData != null ? empData['profilePhoto'] : currentAuthEmployee?.profilePhoto;

    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    if (widget.employeeId != null && detailState.status == LoadStatus.loading) {
      return const Scaffold(body: AppLoader());
    }
    if (widget.employeeId != null && detailState.status == LoadStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: AppError(
          message: detailState.message ?? 'Failed to load profile',
          onRetry: () => context.read<EmployeeProvider>().loadDetail(widget.employeeId!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.description_outlined, size: 16),
              label: const Text('Biodata', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting Biodata PDF...')),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFFE0E7FF),
                      backgroundImage: photo != null && photo.toString().isNotEmpty
                          ? NetworkImage(photo.toString().startsWith('http') ? photo.toString() : '$baseUrl$photo')
                          : null,
                      child: photo == null || photo.toString().isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'K',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF0D9488),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$code • $desig', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(phone, style: const TextStyle(color: Colors.black87, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Profile Option Sections
          _buildProfileOptionCard(
            context,
            icon: Icons.person_outline,
            title: 'Personal Details',
            onTap: () {
              _showSectionDialog(
                'Personal Details',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Full Name', name),
                    _buildInfoRow('Phone', phone),
                    _buildInfoRow('Email', empData?['email'] ?? currentAuthEmployee?.email ?? 'N/A'),
                    _buildInfoRow('Gender', empData?['gender'] ?? 'MALE'),
                    _buildInfoRow('Date of Birth', empData?['dateOfBirth']?.toString().split('T')[0] ?? 'N/A'),
                    _buildInfoRow('Address', empData?['address'] ?? 'Pune, Maharashtra'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.work_outline,
            title: 'Current Employment',
            onTap: () {
              _showSectionDialog(
                'Current Employment',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Employee Code', code),
                    _buildInfoRow('Department', empData?['department']?['name'] ?? 'Sales'),
                    _buildInfoRow('Designation', desig),
                    _buildInfoRow('Employment Type', empData?['employmentType'] ?? 'FULL_TIME'),
                    _buildInfoRow('Joining Date', empData?['joiningDate']?.toString().split('T')[0] ?? '2024-04-01'),
                    _buildInfoRow('Reporting Manager', empData?['reportingManager'] ?? 'System Admin'),
                    _buildInfoRow('Work Location', empData?['workLocation'] ?? 'Pune Branch'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.school_outlined,
            title: 'Education Details',
            badgeText: 'New',
            onTap: () {
              _showSectionDialog(
                'Education Details',
                const Column(
                  children: [
                    Icon(Icons.school, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No education details added yet.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.access_time_outlined,
            title: 'Attendance Details',
            onTap: () {
              _showSectionDialog(
                'Attendance Details',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Shift Name', empData?['shift']?['name'] ?? 'General Shift'),
                    _buildInfoRow('Shift Timing', '09:30 AM - 06:30 PM'),
                    _buildInfoRow('Weekly Off', 'Sunday'),
                    _buildInfoRow('Grace Minutes', '15 Minutes'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.account_balance_outlined,
            title: 'Bank Details',
            onTap: () {
              _showSectionDialog(
                'Bank Details',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Bank Name', empData?['bankName'] ?? 'Demo Bank'),
                    _buildInfoRow('Account Holder', empData?['accountHolderName'] ?? name),
                    _buildInfoRow('Account Number', empData?['accountNumber'] ?? 'XXXX-XXXX-1234'),
                    _buildInfoRow('IFSC Code', empData?['ifsc'] ?? 'DEMO0001234'),
                    _buildInfoRow('Branch', empData?['branch'] ?? 'Pune'),
                    _buildInfoRow('UPI ID', empData?['upiId'] ?? 'N/A'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: 'User Permission',
            trailingText: 'Employee',
            onTap: () {
              _showSectionDialog(
                'User Permission',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Assigned Role', empData?['user']?['role'] ?? 'EMPLOYEE'),
                    _buildInfoRow('Self-Service Access', 'Active'),
                    _buildInfoRow('Attendance Access', 'Punch In / Punch Out Enabled'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? badgeText,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF1E293B)),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
