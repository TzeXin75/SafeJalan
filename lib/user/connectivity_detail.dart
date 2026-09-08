import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/connectivity_report.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class ConnectivityDetailScreen extends StatelessWidget {
  const ConnectivityDetailScreen({super.key, required this.report});

  final ConnectivityReport report;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final current = app.latestConnectivityVersionOf(report);
    final canModify = app.canModifyOwnConnectivityReport(current);
    return Scaffold(
      appBar: AppBar(title: const Text('Connectivity Report Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                child: Icon(Icons.wifi_off_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  current.issueType,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              LabelBadge(current.status, statusColor(current.status)),
            ],
          ),
          const SizedBox(height: 18),
          _DetailRow(Icons.location_on_outlined, 'Area', current.area),
          _DetailRow(Icons.sim_card_outlined, 'Carrier', current.carrier),
          _DetailRow(Icons.notes_rounded, 'Notes', current.notes),
          _DetailRow(
            Icons.schedule_rounded,
            'Submitted',
            _formatDateTime(current.createdAt),
          ),
          _DetailRow(
            Icons.update_rounded,
            'Last updated',
            _formatDateTime(current.updatedAt),
          ),
          const SizedBox(height: 18),
          _StatusExplanation(status: current.status),
          const SizedBox(height: 18),
          if (canModify)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _edit(context, current),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => _cancel(context, current),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel report'),
                  ),
                ),
              ],
            )
          else
            const Text(
              'Editing and cancellation are available only during the first 24 hours while the report is Pending.',
              style: TextStyle(color: mutedText, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, ConnectivityReport current) async {
    final input = await showDialog<_ConnectivityInput>(
      context: context,
      builder: (_) => _ConnectivityEditDialog(report: current),
    );
    if (input == null || !context.mounted) return;
    final error = await context.read<AppProvider>().updateOwnConnectivityReport(
      current,
      issueType: input.issueType,
      carrier: input.carrier,
      notes: input.notes,
      area: input.area,
    );
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _cancel(BuildContext context, ConnectivityReport current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel connectivity report?'),
        content: const Text(
          'The report will be removed from SQLite and Supabase after synchronization.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep report'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel report'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<AppProvider>().cancelOwnConnectivityReport(
      current,
    );
    if (!context.mounted) return;
    if (error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _StatusExplanation extends StatelessWidget {
  const _StatusExplanation({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final message = switch (status.toLowerCase()) {
      'reviewed' =>
        'Reviewed means an administrator has checked the report and is following up, but the connectivity issue is not confirmed as solved yet.',
      'resolved' => 'Resolved means the connectivity issue has been completed.',
      _ =>
        'Pending means the report is waiting for an administrator to review it.',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor(status).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: statusColor(status),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text(label, style: const TextStyle(color: mutedText)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _ConnectivityInput {
  const _ConnectivityInput({
    required this.issueType,
    required this.carrier,
    required this.notes,
    required this.area,
  });

  final String issueType;
  final String carrier;
  final String notes;
  final String area;
}

class _ConnectivityEditDialog extends StatefulWidget {
  const _ConnectivityEditDialog({required this.report});

  final ConnectivityReport report;

  @override
  State<_ConnectivityEditDialog> createState() =>
      _ConnectivityEditDialogState();
}

class _ConnectivityEditDialogState extends State<_ConnectivityEditDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _carrier;
  late final TextEditingController _notes;
  late final TextEditingController _area;
  late String _issueType;

  @override
  void initState() {
    super.initState();
    _carrier = TextEditingController(text: widget.report.carrier);
    _notes = TextEditingController(text: widget.report.notes);
    _area = TextEditingController(text: widget.report.area);
    _issueType = widget.report.issueType;
  }

  @override
  void dispose() {
    _carrier.dispose();
    _notes.dispose();
    _area.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit connectivity report'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _issueType,
              decoration: safeInput('Issue type'),
              items: const [
                DropdownMenuItem(
                  value: 'Poor Signal',
                  child: Text('Poor Signal'),
                ),
                DropdownMenuItem(value: 'No Wi-Fi', child: Text('No Wi-Fi')),
              ],
              onChanged: (value) => setState(() => _issueType = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _carrier,
              decoration: safeInput('Network carrier'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _area,
              decoration: safeInput('Area'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: safeInput('Notes'),
              validator: _required,
            ),
          ],
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
            _ConnectivityInput(
              issueType: _issueType,
              carrier: _carrier.text.trim(),
              notes: _notes.text.trim(),
              area: _area.text.trim(),
            ),
          );
        },
        child: const Text('Save changes'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

String _formatDateTime(String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return value;
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
      '${two(parsed.hour)}:${two(parsed.minute)}';
}
