import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import 'app_button.dart';

class AppError extends StatelessWidget {
  const AppError({super.key, this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message ?? AppStrings.somethingWrong, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppButton(label: AppStrings.retry, icon: Icons.refresh, onPressed: onRetry),
          ],
        ),
      );
}
