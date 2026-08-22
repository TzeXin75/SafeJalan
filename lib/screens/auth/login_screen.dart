import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import '../admin/admin_home.dart';
import '../user/user_home.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool admin;
  const LoginScreen({super.key, this.admin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AppProvider>().login(
      _email.text.trim(),
      _password.text,
      admin: widget.admin,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.admin ? const AdminHome() : const UserHome(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.admin ? 'Admin Login' : 'User Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 38,
                  backgroundColor: primary.withValues(alpha: .12),
                  child: Icon(
                    widget.admin ? Icons.admin_panel_settings : Icons.person,
                    color: primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.admin ? 'SafeJalan Administration' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: safeInput('Email', icon: Icons.email_outlined),
                  validator: (value) {
                    final valid = RegExp(
                      r'^[^@]+@[^@]+\.[^@]+$',
                    ).hasMatch(value ?? '');
                    return valid ? null : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _hide,
                  decoration: safeInput('Password', icon: Icons.lock_outline)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hide ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                  validator: (value) =>
                      (value?.length ?? 0) < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _login,
                    child: const Padding(
                      padding: EdgeInsets.all(13),
                      child: Text('Login'),
                    ),
                  ),
                ),
                if (!widget.admin)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                if (!widget.admin)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Create an account'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
