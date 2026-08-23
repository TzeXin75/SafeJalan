import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_account.dart';
import '../../providers/app_provider.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late Future<List<UserAccount>> _users;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _users = DatabaseService.instance.getUsers();
  }

  Future<void> _editUser(UserAccount user) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: user.name);
    final email = TextEditingController(text: user.email);
    String? databaseError;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit User'),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: safeInput('Full name'),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? 'Enter a valid name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: safeInput('Email'),
                  validator: (value) =>
                      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value ?? '')
                      ? null
                      : 'Enter a valid email',
                ),
                if (databaseError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    databaseError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                setDialogState(() => databaseError = null);
                if (!key.currentState!.validate()) return;
                final existing = await DatabaseService.instance.findUserByEmail(
                  email.text.trim(),
                );
                if (existing != null && existing.id != user.id) {
                  setDialogState(
                    () => databaseError = 'This email is already registered',
                  );
                  return;
                }
                await DatabaseService.instance.updateManagedUser(
                  user.id!,
                  name.text.trim(),
                  email.text.trim(),
                  user.isAdmin,
                );
                final updated = await DatabaseService.instance.findUserById(
                  user.id!,
                );
                if (updated != null) {
                  await _trySyncProfile(updated, previousEmail: user.email);
                }
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    email.dispose();
    if (saved == true && mounted) setState(_reload);
  }

  Future<void> _changeRole(UserAccount user) async {
    await DatabaseService.instance.updateManagedUser(
      user.id!,
      user.name,
      user.email,
      !user.isAdmin,
    );
    final updated = await DatabaseService.instance.findUserById(user.id!);
    if (updated != null) await _trySyncProfile(updated);
    if (mounted) setState(_reload);
  }

  Future<void> _deleteUser(UserAccount user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete ${user.name} (${user.email})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (SupabaseService.instance.isConfigured) {
      try {
        await SupabaseService.instance.deleteUserProfile(user.email);
      } catch (_) {
        // Keep local account management usable while offline.
      }
    }
    await DatabaseService.instance.deleteUser(user.id!);
    if (mounted) setState(_reload);
  }

  Future<void> _trySyncProfile(
    UserAccount user, {
    String? previousEmail,
  }) async {
    if (!SupabaseService.instance.isConfigured) return;
    try {
      await SupabaseService.instance.upsertUserProfile(
        user,
        previousEmail: previousEmail,
      );
    } catch (_) {
      // SQLite remains available while the device is offline.
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AppProvider>().currentUserId;
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Manage Users',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserAccount>>(
              future: _users,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('No registered users yet.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(_reload),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isCurrentUser = user.id == currentUserId;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              user.isAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: isCurrentUser
                              ? const Chip(label: Text('You'))
                              : PopupMenuButton<String>(
                                  onSelected: (action) {
                                    if (action == 'edit') _editUser(user);
                                    if (action == 'role') _changeRole(user);
                                    if (action == 'delete') _deleteUser(user);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit user'),
                                    ),
                                    PopupMenuItem(
                                      value: 'role',
                                      child: Text(
                                        user.isAdmin
                                            ? 'Change to User'
                                            : 'Change to Admin',
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete user',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
