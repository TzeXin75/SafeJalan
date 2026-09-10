import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:provider/provider.dart';
import 'package:safejalan/models/connectivity_report.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';

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
          _ConnectivityProgressCard(report: current),
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
      latitude: input.latitude,
      longitude: input.longitude,
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

class _ConnectivityProgressCard extends StatelessWidget {
  const _ConnectivityProgressCard({required this.report});

  final ConnectivityReport report;

  int get _stage => switch (report.status.toLowerCase()) {
    'reviewed' => 1,
    'resolved' => 2,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final updated = _formatDateTime(report.updatedAt);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status history',
              style: TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _ConnectivityProgressStep(
              title: 'Report submitted',
              detail: _formatDateTime(report.createdAt),
              completed: true,
              current: _stage == 0,
            ),
            _ConnectivityProgressStep(
              title: 'Reviewed by admin',
              detail: _stage >= 1
                  ? (_stage == 1 ? updated : 'Completed')
                  : 'Waiting for review',
              completed: _stage >= 1,
              current: _stage == 1,
            ),
            _ConnectivityProgressStep(
              title: 'Connectivity issue resolved',
              detail: _stage == 2 ? updated : 'Waiting for resolution',
              completed: _stage == 2,
              current: _stage == 2,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectivityProgressStep extends StatelessWidget {
  const _ConnectivityProgressStep({
    required this.title,
    required this.detail,
    required this.completed,
    required this.current,
    this.isLast = false,
  });

  final String title;
  final String detail;
  final bool completed;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = current
        ? safeOrange
        : completed
        ? safeTeal
        : const Color(0xFFCBD5E1);
    return SizedBox(
      height: isLast ? 62 : 82,
      child: Stack(
        children: [
          if (!isLast)
            Positioned(
              left: 17,
              top: 34,
              bottom: 0,
              child: Container(
                width: 3,
                color: completed ? safeTeal : const Color(0xFFE2E8F0),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  completed ? Icons.check_rounded : Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: current || completed ? navy : mutedText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: const TextStyle(color: mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    required this.latitude,
    required this.longitude,
  });

  final String issueType;
  final String carrier;
  final String notes;
  final String area;
  final double latitude;
  final double longitude;
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
  bool _checkingArea = false;

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
        onPressed: _checkingArea ? null : _confirmAndSave,
        child: Text(_checkingArea ? 'Checking address...' : 'Save changes'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _confirmAndSave() async {
    if (!_key.currentState!.validate()) return;
    var confirmedArea = _area.text.trim();
    var confirmedLatitude = widget.report.latitude;
    var confirmedLongitude = widget.report.longitude;

    if (confirmedArea != widget.report.area.trim()) {
      setState(() => _checkingArea = true);
      try {
        final query = confirmedArea.toLowerCase().contains('malaysia')
            ? confirmedArea
            : '$confirmedArea, Malaysia';
        final locations = await geo.locationFromAddress(query);
        if (!mounted || locations.isEmpty) {
          if (mounted) _showAddressError();
          return;
        }
        final location = locations.first;
        confirmedLatitude = location.latitude;
        confirmedLongitude = location.longitude;
        final places = await geo.placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (!mounted) return;
        if (places.isNotEmpty) {
          final place = places.first;
          final parts =
          <String?>[
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country,
          ]
              .whereType<String>()
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toSet()
              .toList();
          if (parts.isNotEmpty) confirmedArea = parts.join(', ');
        }

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Confirm affected area'),
            content: Text(
              'We found this address:\n\n$confirmedArea\n\nIs this correct?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Edit address'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
      } catch (_) {
        if (mounted) _showAddressError();
        return;
      } finally {
        if (mounted) setState(() => _checkingArea = false);
      }
    }

    if (!mounted) return;
    Navigator.pop(
      context,
      _ConnectivityInput(
        issueType: _issueType,
        carrier: _carrier.text.trim(),
        notes: _notes.text.trim(),
        area: confirmedArea,
        latitude: confirmedLatitude,
        longitude: confirmedLongitude,
      ),
    );
  }

  void _showAddressError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Address not found. Enter a more specific Malaysian address.',
        ),
      ),
    );
  }
}

String _formatDateTime(String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return value;
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
      '${two(parsed.hour)}:${two(parsed.minute)}';
}
