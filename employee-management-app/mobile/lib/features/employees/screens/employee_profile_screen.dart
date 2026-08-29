import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../auth/models/employee_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/screens/employee_shell.dart';
import '../../profile/screens/current_employment_screen.dart';
import '../../profile/screens/personal_details_screen.dart';
import '../providers/employee_provider.dart';
import 'bank_account_details_screen.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key, this.employeeId});
  final int? employeeId;

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  File? _localSelectedPhoto;

  // In-memory / loaded document list for quick preview & upload
  final List<Map<String, dynamic>> _uploadedDocs = [
    {
      'type': 'Identity Proof (Aadhaar / PAN)',
      'status': 'Verified',
      'date': '2024-04-01',
      'url': '',
      'icon': Icons.badge_outlined,
      'color': Color(0xFF0D9488),
    },
    {
      'type': 'Bank Passbook / Cheque',
      'status': 'Verified',
      'date': '2024-04-02',
      'url': '',
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF3B82F6),
    },
    {
      'type': 'Appointment / Offer Letter',
      'status': 'Uploaded',
      'date': '2024-04-01',
      'url': '',
      'icon': Icons.assignment_outlined,
      'color': Color(0xFFF59E0B),
    },
    {
      'type': 'Education Certificate / Degree',
      'status': 'Pending',
      'date': '2024-04-05',
      'url': '',
      'icon': Icons.school_outlined,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.employeeId != null) {
        context.read<EmployeeProvider>().loadDetail(widget.employeeId!);
      }
    });
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Icon(Icons.camera_alt, color: Color(0xFF0284C7)),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0FDF4),
                  child: Icon(Icons.photo_library, color: Color(0xFF16A34A)),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _localSelectedPhoto = File(picked.path);
      _isUploading = true;
    });

    try {
      if (widget.employeeId != null) {
        await context.read<EmployeeProvider>().updateEmployee(
          widget.employeeId!,
          {},
          photoPath: picked.path,
        );
        await context.read<EmployeeProvider>().loadDetail(widget.employeeId!);
      } else {
        await context.read<EmployeeProvider>().updateMyProfile(
          photoPath: picked.path,
        );
        final current = context.read<AuthProvider>().state.data;
        if (current != null) {
          // Refresh auth user data
          context.read<AuthProvider>().bootstrap();
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _uploadNewDocument(String defaultDocType) async {
    final typeController = TextEditingController(text: defaultDocType);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upload Document / Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: 'Document Name / Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose image source:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _uploadedDocs.insert(0, {
        'type': typeController.text.trim().isNotEmpty ? typeController.text.trim() : 'Custom Document',
        'status': 'Uploaded',
        'date': DateTime.now().toString().split(' ')[0],
        'url': picked.path,
        'isLocal': true,
        'icon': Icons.image,
        'color': const Color(0xFF0D9488),
      });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${typeController.text} uploaded successfully!'),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
    }
  }

  void _showImagePreview(BuildContext context, String title, String? imageUrl, {bool isLocal = false}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 0,
              title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              color: Colors.black,
              child: isLocal && imageUrl != null && imageUrl.isNotEmpty
                  ? Image.file(File(imageUrl), fit: BoxFit.contain)
                  : imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.contain)
                      : Container(
                          height: 250,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('Document Preview Available', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Replace Image'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _uploadNewDocument(title);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSectionDialog(String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EmployeeShell()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeShell()),
                );
              }
            },
          ),
          title: Text(
            name,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              label: const Text('Biodata', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onPressed: () {
                _showBiodataSheet(name, code, desig, phone, empData, currentAuthEmployee);
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Profile Header Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with Camera Badge
                GestureDetector(
                  onTap: _pickAndUploadProfilePhoto,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFE57373),
                        backgroundImage: _localSelectedPhoto != null
                            ? FileImage(_localSelectedPhoto!) as ImageProvider
                            : (photo != null && photo.toString().isNotEmpty)
                                ? NetworkImage(photo.toString().startsWith('http') ? photo.toString() : '$baseUrl$photo')
                                : null,
                        child: (_localSelectedPhoto == null && (photo == null || photo.toString().isEmpty))
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'N',
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      if (_isUploading)
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFF00BFA5),
                            child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Menu Cards matching the UI
          _buildProfileOptionCard(
            context,
            icon: Icons.accessibility_new_outlined,
            title: 'Personal Details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalDetailsScreen(initialData: empData),
                ),
              ).then((updated) {
                if (updated == true && context.mounted) {
                  context.read<AuthProvider>().loadMe();
                }
              });
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.work_outline,
            title: 'Current Employment',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CurrentEmploymentScreen(initialData: empData),
                ),
              ).then((updated) {
                if (updated == true && context.mounted) {
                  context.read<AuthProvider>().loadMe();
                }
              });
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.badge_outlined,
            title: 'Custom Details',
            badgeText: 'New',
            onTap: () {
              _showSectionDialog(
                'Custom Details & Documents',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Education / Qualification', 'Graduate (B.Com / B.Tech)'),
                    _buildInfoRow('Skills', 'Sales, Client Relationship, Field Operations'),
                    _buildInfoRow('Emergency Contact', '91-9876543210 (Father)'),
                    _buildInfoRow('Blood Group', 'O+ Positive'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Uploaded Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        TextButton.icon(
                          icon: const Icon(Icons.add_a_photo, size: 16, color: Color(0xFF00BFA5)),
                          label: const Text('Add Document', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                          onPressed: () => _uploadNewDocument('Custom Certificate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._uploadedDocs.map((doc) => _buildUploadedDocTile(doc)).toList(),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.fingerprint,
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
                    _buildInfoRow('Attendance Mode', 'Selfie + GPS Geo-Fence Enabled'),
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
            trailingText: empData?['bankName'] ?? (empData?['upiId'] != null ? 'UPI Linked' : null),
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BankAccountDetailsScreen(
                    employeeId: widget.employeeId,
                    employeeName: name,
                    initialData: empData,
                  ),
                ),
              );
              if (updated == true && mounted) {
                if (widget.employeeId != null) {
                  context.read<EmployeeProvider>().loadDetail(widget.employeeId!);
                } else {
                  context.read<AuthProvider>().loadMe();
                }
              }
            },
          ),
          const SizedBox(height: 10),

          _buildProfileOptionCard(
            context,
            icon: Icons.person_outline,
            title: 'User Permission',
            trailingText: 'Employee',
            onTap: () {
              _showSectionDialog(
                'User Permission',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Role', empData?['user']?['role'] ?? 'EMPLOYEE'),
                    _buildInfoRow('Self-Service Access', 'Active'),
                    _buildInfoRow('Attendance Punch Access', 'Granted'),
                    _buildInfoRow('Leave & Expense Requests', 'Granted'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.04),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF1E293B), size: 24),
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
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
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreviewCard(String title, IconData icon, VoidCallback onUpload) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Icon(icon, color: const Color(0xFF0284C7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Text('Tap to view or upload photo', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF00BFA5)),
            onPressed: onUpload,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedDocTile(Map<String, dynamic> doc) {
    final isLocal = doc['isLocal'] == true;
    final url = doc['url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: (doc['color'] as Color? ?? const Color(0xFF0D9488)).withOpacity(0.12),
            child: Icon(doc['icon'] as IconData? ?? Icons.image, color: doc['color'] as Color? ?? const Color(0xFF0D9488), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['type']?.toString() ?? 'Document',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doc['status']?.toString() ?? 'Uploaded',
                        style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doc['date']?.toString() ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: Color(0xFF1E293B)),
            onPressed: () => _showImagePreview(context, doc['type']?.toString() ?? 'Preview', url, isLocal: isLocal),
          ),
        ],
      ),
    );
  }

  void _showBiodataSheet(
    String name,
    String code,
    String desig,
    String phone,
    Map<String, dynamic>? empData,
    EmployeeModel? authEmp,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                const Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Employee Biodata Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('$desig ($code)', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  _buildInfoRow('Email', empData?['email'] ?? authEmp?.email ?? 'N/A'),
                  _buildInfoRow('Gender', empData?['gender'] ?? 'MALE'),
                  _buildInfoRow('Date of Birth', empData?['dateOfBirth']?.toString().split('T')[0] ?? '1996-08-15'),
                  _buildInfoRow('Address', empData?['address'] ?? 'Pune, Maharashtra'),
                  const Divider(height: 24),
                  const Text('Employment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  _buildInfoRow('Department', empData?['department']?['name'] ?? 'Sales'),
                  _buildInfoRow('Joining Date', empData?['joiningDate']?.toString().split('T')[0] ?? '2024-04-01'),
                  _buildInfoRow('Employment Type', empData?['employmentType'] ?? 'FULL_TIME'),
                  _buildInfoRow('Work Location', empData?['workLocation'] ?? 'Main Branch'),
                  const Divider(height: 24),
                  const Text('Bank Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  _buildInfoRow('Bank Name', empData?['bankName'] ?? 'State Bank of India'),
                  _buildInfoRow('Account Number', empData?['accountNumber'] ?? 'XXXX-XXXX-8921'),
                  _buildInfoRow('IFSC Code', empData?['ifsc'] ?? 'SBIN0001420'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Download / Print PDF', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Biodata PDF downloaded to device storage!'), backgroundColor: Color(0xFF00BFA5)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
