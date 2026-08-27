import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/app_session.dart';
import '../providers/attendance_provider.dart';

class CameraSelfieAttendanceScreen extends StatefulWidget {
  const CameraSelfieAttendanceScreen({
    super.key,
    required this.isPunchOut,
  });

  final bool isPunchOut;

  @override
  State<CameraSelfieAttendanceScreen> createState() => _CameraSelfieAttendanceScreenState();
}

class _CameraSelfieAttendanceScreenState extends State<CameraSelfieAttendanceScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  String? _errorMessage;
  XFile? _capturedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No camera available on device';
          _isInitializing = false;
        });
        return;
      }

      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera initialization failed: ${e.toString()}';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isTakingPicture) {
      return;
    }
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture selfie: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitAttendance() async {
    if (_capturedImage == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final endpoint = widget.isPunchOut ? '/attendance/punch-out' : '/attendance/punch-in';

      final formData = FormData.fromMap({
        'employeeId': AppSession.instance.selectedEmployeeId ?? 1,
        'selfie': await MultipartFile.fromFile(
          _capturedImage!.path,
          filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      await apiClient.multipart(endpoint, formData);

      if (!mounted) return;

      // Refresh local attendance state
      await Provider.of<AttendanceProvider>(context, listen: false).loadTodayAttendance();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isPunchOut ? 'Punched Out successfully!' : 'Punched In successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('ApiException:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : 'Attendance submission failed'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isPunchOut ? 'Punch Out Selfie' : 'Punch In Selfie';
    final empName = AppSession.instance.selectedEmployeeName ?? 'Employee';
    final empCode = AppSession.instance.selectedEmployeeCode ?? 'EMP-0001';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
        elevation: 0,
      ),
      body: _capturedImage != null
          ? _buildPreviewScreen(empName, empCode)
          : _buildCameraScreen(),
    );
  }

  Widget _buildCameraScreen() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isInitializing = true);
                  _initCamera();
                },
                child: const Text('RETRY CAMERA'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),
        // Oval Face Guide Frame Overlay
        Positioned.fill(
          child: Center(
            child: Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
                borderRadius: BorderRadius.all(Radius.elliptical(260, 340)),
              ),
            ),
          ),
        ),
        // Instruction Banner
        Positioned(
          top: 30,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Position your face inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Bottom Shutter Button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takeSelfie,
              child: Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 36),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewScreen(String empName, String empCode) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Colors.greenAccent, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '$empCode • ${widget.isPunchOut ? "Punch Out Confirmation" : "Punch In Confirmation"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_capturedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : () => setState(() => _capturedImage = null),
                    child: const Text('RETAKE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isPunchOut ? Colors.orange.shade800 : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _submitAttendance,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.isPunchOut ? 'CONFIRM PUNCH OUT' : 'CONFIRM PUNCH IN',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
