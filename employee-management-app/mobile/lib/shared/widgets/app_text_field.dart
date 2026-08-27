import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.label, this.controller, this.validator, this.obscureText = false});
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      );
}
