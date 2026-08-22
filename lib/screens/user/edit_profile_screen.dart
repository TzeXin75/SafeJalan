import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _name = TextEditingController(text: app.userName);
    _email = TextEditingController(text: app.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) setState(() => _newImage = File(picked.path));
  }

  Future<String?> _saveImage() async {
    if (_newImage == null) return null;
    final directory = await getApplicationDocumentsDirectory();
    final extension = _newImage!.path.toLowerCase().endsWith('.png')
        ? 'png'
        : 'jpg';
    final path =
        '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _newImage!.copy(path);
    return path;
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    final imagePath = await _saveImage();
    if (!mounted) return;
    final error = await context.read<AppProvider>().saveProfile(
      _name.text.trim(),
      _email.text.trim(),
      imagePath: imagePath,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final oldPath = context.watch<AppProvider>().profileImagePath;
    final oldImage = oldPath != null && File(oldPath).existsSync()
        ? File(oldPath)
        : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(60),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFFDDE4FF),
                  backgroundImage: _newImage != null
                      ? FileImage(_newImage!)
                      : oldImage == null
                      ? null
                      : FileImage(oldImage),
                  child: _newImage == null && oldImage == null
                      ? const Icon(Icons.add_a_photo, color: primary, size: 42)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              decoration: safeInput('Full name', icon: Icons.person_outline),
              validator: (value) =>
                  (value?.trim().length ?? 0) < 2 ? 'Enter a valid name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: safeInput('Email', icon: Icons.email_outlined),
              validator: (value) =>
                  RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value ?? '')
                  ? null
                  : 'Enter a valid email',
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: _save, child: const Text('Save Profile')),
          ],
        ),
      ),
    );
  }
}
