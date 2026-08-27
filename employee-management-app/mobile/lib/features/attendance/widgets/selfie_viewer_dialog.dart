import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/constants/app_colors.dart';

class SelfieViewerDialog extends StatelessWidget {
  const SelfieViewerDialog({
    super.key,
    required this.employeeName,
    required this.employeeCode,
    required this.date,
    required this.punchType,
    required this.time,
    required this.selfieUrl,
  });

  final String employeeName;
  final String employeeCode;
  final String date;
  final String punchType; // 'Punch In' or 'Punch Out'
  final String time;
  final String selfieUrl;

  @override
  Widget build(BuildContext context) {
    final fullUrl = selfieUrl.startsWith('http')
        ? selfieUrl
        : '${ApiConfig.baseUrl.replaceAll('/api', '')}$selfieUrl';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '$employeeCode • $date',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: punchType == 'Punch In'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$punchType at $time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: punchType == 'Punch In' ? Colors.green.shade800 : Colors.orange.shade800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Selfie Image Not Found', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}
