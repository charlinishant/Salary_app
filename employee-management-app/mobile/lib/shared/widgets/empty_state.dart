import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.message = AppStrings.noData});
  final String message;

  @override
  Widget build(BuildContext context) => Center(child: Text(message, textAlign: TextAlign.center));
}
