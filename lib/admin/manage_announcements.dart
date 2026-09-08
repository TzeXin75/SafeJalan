import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/safety_announcement.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class ManageAnnouncementsScreen extends StatelessWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = context.watch<AppProvider>().announcements;
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Announcements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: RefreshIndicator(
        onRefresh: context.read<AppProvider>().syncSafetyAnnouncements,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageTitle(
              'Announcement Management',
              'Create, read, update and delete safety notices',
            ),
            const SizedBox(height: 14),
            if (announcements.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No announcements created.')),
                ),
              ),
            ...announcements.map(
              (announcement) => _AnnouncementAdminCard(
                announcement: announcement,
                onEdit: () => _edit(context, announcement),
                onDelete: () => _delete(context, announcement),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context, [
    SafetyAnnouncement? announcement,
  ]) async {
    final result = await showDialog<_AnnouncementInput>(
      context: context,
      builder: (_) => _AnnouncementDialog(announcement: announcement),
    );
    if (result == null || !context.mounted) return;
    final app = context.read<AppProvider>();
    if (announcement == null) {
      await app.addSafetyAnnouncement(
        title: result.title,
        message: result.message,
        priority: result.priority,
        isActive: result.isActive,
      );
    } else {
      await app.updateSafetyAnnouncement(
        announcement,
        title: result.title,
        message: result.message,
        priority: result.priority,
        isActive: result.isActive,
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    SafetyAnnouncement announcement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete announcement?'),
        content: Text('Delete “${announcement.title}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppProvider>().deleteSafetyAnnouncement(announcement);
    }
  }
}

class _AnnouncementAdminCard extends StatelessWidget {
  const _AnnouncementAdminCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
  });

  final SafetyAnnouncement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (announcement.priority) {
      'Emergency' => Colors.red,
      'Important' => safeOrange,
      _ => primary,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                LabelBadge(announcement.priority, color),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcement.message),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  announcement.isActive
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: announcement.isActive ? Colors.green : mutedText,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  announcement.isActive ? 'Visible to users' : 'Hidden',
                  style: const TextStyle(color: mutedText, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete',
                  color: Colors.red,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementInput {
  const _AnnouncementInput({
    required this.title,
    required this.message,
    required this.priority,
    required this.isActive,
  });

  final String title;
  final String message;
  final String priority;
  final bool isActive;
}

class _AnnouncementDialog extends StatefulWidget {
  const _AnnouncementDialog({this.announcement});

  final SafetyAnnouncement? announcement;

  @override
  State<_AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<_AnnouncementDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _message;
  late String _priority;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.announcement?.title ?? '');
    _message = TextEditingController(text: widget.announcement?.message ?? '');
    _priority = widget.announcement?.priority ?? 'Normal';
    _isActive = widget.announcement?.isActive ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.announcement == null ? 'New announcement' : 'Edit announcement',
    ),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                maxLength: 80,
                decoration: safeInput('Title'),
                validator: (value) => (value?.trim().length ?? 0) < 5
                    ? 'Enter at least 5 characters'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _message,
                maxLines: 5,
                maxLength: 500,
                decoration: safeInput('Message'),
                validator: (value) => (value?.trim().length ?? 0) < 10
                    ? 'Enter at least 10 characters'
                    : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: safeInput('Priority'),
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(
                    value: 'Important',
                    child: Text('Important'),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency',
                    child: Text('Emergency'),
                  ),
                ],
                onChanged: (value) => setState(() => _priority = value!),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible to users'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_key.currentState!.validate()) return;
          Navigator.pop(
            context,
            _AnnouncementInput(
              title: _title.text.trim(),
              message: _message.text.trim(),
              priority: _priority,
              isActive: _isActive,
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}
