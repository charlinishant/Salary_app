import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(AppConfig.logoAsset, height: 104, fit: BoxFit.contain),
                  const SizedBox(height: 28),
                  Text('Employee Login', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 18),
                  AppTextField(label: 'Employee ID / Email', controller: _identifier, validator: Validators.emailOrEmployee),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Password', controller: _password, obscureText: true, validator: (v) => Validators.required(v, 'Password')),
                  if (auth.state.status == LoadStatus.error) Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(auth.state.message ?? 'Login failed', style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: auth.state.status == LoadStatus.loading ? 'Signing in...' : 'Login',
                    icon: Icons.login,
                    onPressed: auth.state.status == LoadStatus.loading ? null : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<AuthProvider>().login(_identifier.text.trim(), _password.text);
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
