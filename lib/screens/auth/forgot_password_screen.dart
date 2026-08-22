import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_key.currentState!.validate()) return;
    final error = await context.read<AppProvider>().resetPassword(
      _email.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. Please log in.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset Password')),
    body: Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Reset your local account password',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This classroom version verifies the registered email in SQLite and resets the password on this device.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: safeInput(
              'Registered email',
              icon: Icons.email_outlined,
            ),
            validator: (value) =>
                RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value ?? '')
                ? null
                : 'Enter a valid email',
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: safeInput('New password', icon: Icons.lock_reset),
            validator: (value) =>
                (value?.length ?? 0) < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 22),
          FilledButton(onPressed: _reset, child: const Text('Reset Password')),
        ],
      ),
    ),
  );
}
