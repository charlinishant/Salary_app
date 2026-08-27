import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.primary.withOpacity(0.12),
        deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }
}
