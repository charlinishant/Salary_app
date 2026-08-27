import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/app_state.dart';
import '../../dashboard/screens/home_shell.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.state.status == LoadStatus.loading || auth.state.status == LoadStatus.idle) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isAuthenticated ? const HomeShell() : const LoginScreen();
  }
}
