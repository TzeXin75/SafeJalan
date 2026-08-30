import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/user_account.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/services/database_service.dart';

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

  Future<void> _changeRole(UserAccount user) async {
    final nextRole = user.isAdmin ? 'User' : 'Admin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change to $nextRole?'),
        content: Text(
          '${user.name} will ${user.isAdmin ? 'lose' : 'receive'} administrator access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await DatabaseService.instance.updateManagedUser(
      user.id!,
      user.name,
      user.email,
      !user.isAdmin,
    );
    final updated = await DatabaseService.instance.findUserById(user.id!);
    if (updated != null && mounted) {
      await context.read<AppProvider>().syncUsers();
    }
    if (mounted) setState(_reload);
  }

  Future<void> _deleteUser(UserAccount user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text(
          '${user.name} (${user.email}) will be hidden and unable to log in. The database record is retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await DatabaseService.instance.deactivateUser(user.id!);
    if (mounted) await context.read<AppProvider>().syncUsers();
    if (mounted) setState(_reload);
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
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: user.isAdmin
                                          ? 'Change to User'
                                          : 'Change to Admin',
                                      onPressed: () => _changeRole(user),
                                      icon: Icon(
                                        user.isAdmin
                                            ? Icons.person_outline_rounded
                                            : Icons
                                                  .admin_panel_settings_outlined,
                                        color: user.isAdmin
                                            ? Colors.blueGrey
                                            : const Color(0xFF4361EE),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Deactivate user',
                                      onPressed: () => _deleteUser(user),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
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
