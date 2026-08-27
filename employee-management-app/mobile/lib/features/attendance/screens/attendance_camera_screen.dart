import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'selfie_preview_screen.dart';

class AttendanceCameraScreen extends StatefulWidget {
  const AttendanceCameraScreen({super.key, required this.isPunchIn});
  final bool isPunchIn;

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen> {
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openFrontCamera();
    });
  }

  Future<void> _openFrontCamera() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final file = File(photo.path);
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SelfiePreviewScreen(
              imageFile: file,
              isPunchIn: widget.isPunchIn,
            ),
          ),
        );

        if (result == true && mounted) {
          Navigator.pop(context, true);
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isPunchIn ? 'Selfie Punch In' : 'Selfie Punch Out',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D9488), width: 3),
                ),
                child: const Icon(Icons.camera_front, size: 72, color: Color(0xFF0D9488)),
              ),
              const SizedBox(height: 24),
              Text(
                widget.isPunchIn ? 'Front Camera Selfie Punch In' : 'Front Camera Selfie Punch Out',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Position your face clearly in front of the camera',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    _isCapturing ? 'Opening Camera...' : 'Open Front Camera',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isCapturing ? null : _openFrontCamera,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
