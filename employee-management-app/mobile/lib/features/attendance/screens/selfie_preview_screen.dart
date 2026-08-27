import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'attendance_success_screen.dart';

class SelfiePreviewScreen extends StatefulWidget {
  const SelfiePreviewScreen({
    super.key,
    required this.imageFile,
    required this.isPunchIn,
  });

  final File imageFile;
  final bool isPunchIn;

  @override
  State<SelfiePreviewScreen> createState() => _SelfiePreviewScreenState();
}

class _SelfiePreviewScreenState extends State<SelfiePreviewScreen> {
  bool _isSubmitting = false;

  Future<void> _submitSelfie() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<AttendanceProvider>();
      final Map<String, dynamic> result;

      if (widget.isPunchIn) {
        result = await provider.submitPunchIn(widget.imageFile.path);
      } else {
        result = await provider.submitPunchOut(widget.imageFile.path);
      }

      if (!mounted) return;

      // Navigate to clean Success Confirmation Screen
      final authEmp = context.read<AuthProvider>().state.data;
      final empName = authEmp?.name ?? 'Kuldeep Kumavat';

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceSuccessScreen(
            isPunchIn: widget.isPunchIn,
            employeeName: empName,
            punchTime: result['data']?['checkInTime'] ?? result['data']?['checkOutTime'] ?? DateFormat('hh:mm a').format(DateTime.now()),
            workingHoursFormatted: result['data']?['workingHoursFormatted'],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ApiException: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = context.watch<AuthProvider>().state.data?.name ?? 'Kuldeep Kumavat';
    final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final timeStr = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
        ),
        title: Text(
          widget.isPunchIn ? 'Confirm Punch In' : 'Confirm Punch Out',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Employee Info Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      employeeName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr • $timeStr',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isPunchIn ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.isPunchIn ? 'Punching in at $timeStr' : 'Punching out at $timeStr',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Captured Selfie Image Preview Frame
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0D9488), width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.file(widget.imageFile, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Retake & Confirm Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('RETAKE', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        _isSubmitting
                            ? 'Marking attendance...'
                            : (widget.isPunchIn ? 'CONFIRM PUNCH IN' : 'CONFIRM PUNCH OUT'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: _isSubmitting ? null : _submitSelfie,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
