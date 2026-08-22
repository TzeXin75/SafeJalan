import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../user/user_home.dart';
import '../../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Register')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _key,
        child: Column(
          children: [
            const Text(
              'Join SafeJalan',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _name,
              decoration: safeInput('Full name', icon: Icons.person_outline),
              validator: (v) =>
                  v == null || !RegExp(r"^[A-Za-z .'-]{2,}$").hasMatch(v)
                  ? 'Enter a valid name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: safeInput('Email', icon: Icons.email_outlined),
              validator: (v) =>
                  v == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: safeInput('Password', icon: Icons.lock_outline),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!_key.currentState!.validate()) return;
                  final error = await context.read<AppProvider>().register(
                    _name.text.trim(),
                    _email.text.trim(),
                    _password.text,
                  );
                  if (!context.mounted) return;
                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const UserHome()),
                    (route) => false,
                  );
                },
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
