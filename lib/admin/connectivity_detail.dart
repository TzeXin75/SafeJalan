import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/models/connectivity_report.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';

class AdminConnectivityDetailScreen extends StatefulWidget {
  const AdminConnectivityDetailScreen({super.key, required this.report});

  final ConnectivityReport report;

  @override
  State<AdminConnectivityDetailScreen> createState() =>
      _AdminConnectivityDetailScreenState();
}

class _AdminConnectivityDetailScreenState
    extends State<AdminConnectivityDetailScreen> {
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.report.status;
  }

  @override
  Widget build(BuildContext context) {
    final report = context
        .watch<AppProvider>()
        .latestConnectivityVersionOf(widget.report);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Connectivity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0x148B5CF6),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.issueType,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              report.carrier,
                              style: const TextStyle(color: mutedText),
                            ),
                          ],
                        ),
                      ),
                      LabelBadge(report.status, statusColor(report.status)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DetailRow(Icons.location_on_outlined, 'Area', report.area),
                  _DetailRow(Icons.notes_outlined, 'Notes', report.notes),
                  _DetailRow(
                    Icons.person_outline_rounded,
                    'Reporter',
                    report.reporterEmail,
                  ),
                  _DetailRow(
                    Icons.schedule_rounded,
                    'Submitted',
                    _formatDateTime(report.createdAt),
                  ),
                  _DetailRow(
                    Icons.pin_drop_outlined,
                    'Coordinates',
                    '${report.latitude.toStringAsFixed(5)}, '
                        '${report.longitude.toStringAsFixed(5)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update status',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: safeInput('Current status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'Reviewed',
                        child: Text('Reviewed'),
                      ),
                      DropdownMenuItem(
                        value: 'Resolved',
                        child: Text('Resolved'),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving || _status == report.status
                          ? null
                          : () => _save(report),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Saving...' : 'Save status'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: _saving ? null : () => _confirmDelete(report),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete connectivity report'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(ConnectivityReport report) async {
    setState(() => _saving = true);
    final synced = await context
        .read<AppProvider>()
        .updateConnectivityStatus(report, _status);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced
              ? 'Status updated and synced.'
              : 'Status saved locally and will sync when online.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ConnectivityReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete connectivity report?'),
        content: const Text(
          'This report will be removed locally and from Supabase after synchronization.',
        ),
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
    if (confirmed != true || !mounted) return;
    await context.read<AppProvider>().deleteConnectivityReport(report);
    if (mounted) Navigator.pop(context);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 19),
        const SizedBox(width: 9),
        SizedBox(
          width: 90,
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

String _formatDateTime(String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return value;
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
      '${two(parsed.hour)}:${two(parsed.minute)}';
}
