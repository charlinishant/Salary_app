import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/screens/home_shell.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().switchToAdminView();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Open main app directly without any login requirement
    return const HomeShell();
  }
}
