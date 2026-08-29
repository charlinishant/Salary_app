import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/alarm_sound_service.dart';
import '../../../core/session/app_session.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../attendance/screens/attendance_history_screen.dart';
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

  List<Widget> _buildPages() {
    return [
      DashboardScreen(
        onMarkAttendanceTap: () {
          setState(() => _selectedIndex = 1);
        },
      ),
      const EmployeeMarkAttendanceTab(),
      const LeaveScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF00BFA5),
          unselectedItemColor: const Color(0xFF757575),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.dashboard_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.dashboard, size: 26),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.fingerprint, size: 26),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.fingerprint, size: 28),
              ),
              label: 'Mark Attendance',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.beach_access_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.beach_access, size: 26),
              ),
              label: 'Leaves',
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeMarkAttendanceTab extends StatefulWidget {
  const EmployeeMarkAttendanceTab({super.key});

  @override
  State<EmployeeMarkAttendanceTab> createState() => _EmployeeMarkAttendanceTabState();
}

class _EmployeeMarkAttendanceTabState extends State<EmployeeMarkAttendanceTab> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AttendanceProvider>().loadToday();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_isDisposed) return;
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      int frontIndex = _cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _currentCameraIndex = frontIndex >= 0 ? frontIndex : 0;

      await _setupCameraController(_cameras![_currentCameraIndex]);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription cameraDescription) async {
    if (_isDisposed) return;
    await _disposeCamera();

    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted && !_isDisposed) {
        setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera controller init error: $e');
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      final old = _cameraController;
      _cameraController = null;
      if (mounted) setState(() => _isCameraReady = false);
      try {
        await old?.dispose();
      } catch (_) {}
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _setupCameraController(_cameras![_currentCameraIndex]);
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _onPunchButtonPressed(bool isPunchedIn) async {
    if (_isProcessing) return;

    File? selfieFile;
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile shot = await _cameraController!.takePicture();
        selfieFile = File(shot.path);
      } catch (e) {
        debugPrint('Snapshot error: $e');
      }
    }

    final empName = AppSession.instance.selectedEmployeeName ?? 'Kuldeep Kumavat';
    final currentTimeStr = DateFormat('hh:mm a').format(DateTime.now());
    final isPunchOut = isPunchedIn;

    if (!mounted) return;

    // Show Confirmation Dialog matching uploaded screenshot
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Employee Photo Thumbnail
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: selfieFile != null
                      ? Image.file(selfieFile, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 14),

              // Employee Name
              Text(
                empName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Punch Message
              Text(
                isPunchOut ? 'Punching out at\n$currentTimeStr' : 'Punching in at\n$currentTimeStr',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Row (Confirm / Cancel)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEEEEE),
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      _executePunch(isPunchOut, selfieFile);
    }
  }

  Future<void> _executePunch(bool isPunchOut, File? selfieFile) async {
    setState(() => _isProcessing = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final endpoint = isPunchOut ? '/attendance/punch-out' : '/attendance/punch-in';

      final map = <String, dynamic>{
        'employeeId': AppSession.instance.selectedEmployeeId ?? 1,
      };

      if (selfieFile != null) {
        map['selfie'] = await MultipartFile.fromFile(
          selfieFile.path,
          filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final formData = FormData.fromMap(map);
      await apiClient.multipart(endpoint, formData);

      if (!mounted) return;

      AlarmSoundService.instance.playPunchSuccessSound();
      await context.read<AttendanceProvider>().loadToday();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPunchOut ? 'Punched Out successfully!' : 'Punched In successfully! Marked Present.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isPunchOut ? Colors.orange.shade800 : const Color(0xFF00BFA5),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attProvider = context.watch<AttendanceProvider>();
    final todayData = attProvider.todayState.data?['attendance'] ?? attProvider.todayState.data ?? {};

    final checkIn = todayData['checkIn'] ?? todayData['punchInTime'];
    final checkOut = todayData['checkOut'] ?? todayData['punchOutTime'];

    final isPunchedIn = checkIn != null && (checkOut == null || checkOut == '--');
    final isPunchedOut = checkIn != null && checkOut != null && checkOut != '--';

    final todayFormatted = DateFormat('dd MMMM').format(DateTime.now());
    final statusText = isPunchedIn || isPunchedOut ? 'Present' : 'Absent';
    final statusColor = isPunchedIn || isPunchedOut ? const Color(0xFF00BFA5) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset('assets/images/yogesh_krushi_logo.jpg', fit: BoxFit.cover),
            ),
          ),
        ),
        title: const Text(
          'YOGESH KRUSHI SEVA KENDRA',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF00BFA5)),
            tooltip: 'Attendance History',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date + Status Header Banner (Matches uploaded screenshot)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$todayFormatted ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          // Thin status indicator line
          Container(
            height: 3,
            width: double.infinity,
            color: statusColor,
          ),

          // Live In-App Camera View with Circular Vignette Cutout
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_isCameraReady && _cameraController != null)
                  CameraPreview(_cameraController!)
                else
                  Container(
                    color: Colors.black87,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
                    ),
                  ),

                // Darkened Overlay with Clear Circular Cutout in Center
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HolePainter(),
                  ),
                ),

                // Switch Camera Icon Button (top right of viewfinder)
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Punch In / Punch Out Button Overlaid at bottom of camera view
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPunchedIn ? const Color(0xFFEF4444) : const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isProcessing ? null : () => _onPunchButtonPressed(isPunchedIn),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  isPunchedIn ? 'Punch Out' : 'Punch In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // "Check Today's Notes" full-width light blue banner (Matches uploaded screenshot)
          InkWell(
            onTap: () {
              _showNotesModal(context, todayData);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: const Color(0xFF80D8FF),
              child: const Text(
                "Check Today's Notes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesModal(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Shift & Notes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const Divider(height: 20),
            Text(
              'Shift: ${data['shiftName'] ?? "General Shift (09:30 AM - 06:30 PM)"}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Punch In Time: ${data['checkIn'] != null ? data['checkIn'].toString().split('T').last.substring(0, 5) : "Not recorded"}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              'Punch Out Time: ${data['checkOut'] != null && data['checkOut'] != '--' ? data['checkOut'].toString().split('T').last.substring(0, 5) : "Not recorded"}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for camera circular face viewfinder vignette
class _HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.width * 0.38;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Subtle white border around circle
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
