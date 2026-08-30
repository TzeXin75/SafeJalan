import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import '../admin/admin_home.dart';
import '../user/user_home.dart';
import 'forgot_password.dart';
import 'register.dart';

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
  String? _loginError;
  String? _successMessage;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loginError = null);
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AppProvider>().login(
      _email.text.trim(),
      _password.text,
      admin: widget.admin,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _loginError = error);
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.admin ? 'Admin Login' : 'User Login')),
    body: AuthBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
          child: FormCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  widget.admin
                      ? Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: primary,
                            size: 36,
                          ),
                        )
                      : const SafeLogo(size: 116),
                  const SizedBox(height: 20),
                  Text(
                    widget.admin ? 'SafeJalan Admin' : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.admin
                        ? 'Manage reports and community activity'
                        : 'Sign in to continue making roads safer',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: mutedText),
                  ),
                  const SizedBox(height: 26),
                  if (_successMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: safeTeal.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: Color(0xFF087F5B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: safeInput('Email', icon: Icons.email_outlined),
                    validator: (value) =>
                        RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value ?? '')
                        ? null
                        : 'Enter a valid email',
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
                    validator: (value) => (value?.length ?? 0) < 6
                        ? 'Minimum 6 characters'
                        : null,
                  ),
                  if (_loginError != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _loginError!,
                        style: const TextStyle(
                          color: Color(0xFFD92D20),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Login'),
                    ),
                  ),
                  if (!widget.admin) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () async {
                        final success = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                        if (success == true && mounted) {
                          setState(() {
                            _loginError = null;
                            _successMessage =
                                'Password reset successfully. Please log in.';
                          });
                        }
                      },
                      child: const Text('Forgot password?'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New to SafeJalan?',
                          style: TextStyle(color: mutedText),
                        ),
                        TextButton(
                          onPressed: () async {
                            final result =
                                await Navigator.push<RegistrationResult>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                            if (result != null && mounted) {
                              setState(() {
                                _email.text = result.email;
                                _password.text = result.password;
                                _loginError = null;
                                _successMessage =
                                    'Registration successful. Your login details are ready.';
                              });
                            }
                          },
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
