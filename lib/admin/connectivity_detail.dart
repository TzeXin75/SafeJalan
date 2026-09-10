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
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final report = context
        .watch<AppProvider>()
        .latestConnectivityVersionOf(widget.report);
    final currentStatus = report.status.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Connectivity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ConnectivityInformationCard(report: report),
          const SizedBox(height: 12),
          if (currentStatus == 'pending')
            _ReviewCard(
              saving: _saving,
              onReject: () => _setStatus(report, 'Rejected'),
              onReview: () => _setStatus(report, 'Reviewed'),
            )
          else if (currentStatus == 'reviewed')
            _ManageCard(
              saving: _saving,
              onResolve: () => _setStatus(report, 'Resolved'),
            )
          else
            _ClosedStatusCard(report: report),
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

  Future<void> _setStatus(
      ConnectivityReport report,
      String status,
      ) async {
    setState(() => _saving = true);
    final synced = await context
        .read<AppProvider>()
        .updateConnectivityStatus(report, status);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced
              ? 'Status updated to $status and synced.'
              : 'Status updated to $status and will sync when online.',
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

class _ConnectivityInformationCard extends StatelessWidget {
  const _ConnectivityInformationCard({required this.report});

  final ConnectivityReport report;

  @override
  Widget build(BuildContext context) => Card(
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
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.saving,
    required this.onReject,
    required this.onReview,
  });

  final bool saving;
  final VoidCallback onReject;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review submission',
            style: TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check the submitted area and details before continuing.',
            style: TextStyle(color: mutedText),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: saving ? null : onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving ? null : onReview,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(saving ? 'Saving...' : 'Review'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ManageCard extends StatelessWidget {
  const _ManageCard({required this.saving, required this.onResolve});

  final bool saving;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Connectivity',
            style: TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'The report has been reviewed. Mark it as resolved when the connectivity issue has been handled.',
            style: TextStyle(color: mutedText),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: saving ? null : onResolve,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(saving ? 'Saving...' : 'Mark as Resolved'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ClosedStatusCard extends StatelessWidget {
  const _ClosedStatusCard({required this.report});

  final ConnectivityReport report;

  @override
  Widget build(BuildContext context) {
    final resolved = report.status.toLowerCase() == 'resolved';
    final color = statusColor(report.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              resolved ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                resolved
                    ? 'This connectivity issue has been resolved.'
                    : 'This connectivity report has been rejected.',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
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
