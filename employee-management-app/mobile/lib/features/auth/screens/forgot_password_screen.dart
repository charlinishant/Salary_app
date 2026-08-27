import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Forgot Password')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: AppTextField(label: 'Employee ID / Email'),
        ),
      );
}
