import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/connectivity_report.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class ManageConnectivityScreen extends StatefulWidget {
  const ManageConnectivityScreen({super.key});

  @override
  State<ManageConnectivityScreen> createState() =>
      _ManageConnectivityScreenState();
}

class _ManageConnectivityScreenState extends State<ManageConnectivityScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().connectivityReports;
    final visibleReports = _filter == 'All'
        ? reports
        : reports.where((report) => report.status == _filter).toList();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: context.read<AppProvider>().syncConnectivityReports,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageTitle(
              'Connectivity (${visibleReports.length})',
              'Review mobile signal and Wi-Fi gaps',
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Reviewed', 'Resolved']
                    .map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: _filter == status,
                          onSelected: (_) => setState(() => _filter = status),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (visibleReports.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No connectivity reports for this status.'),
                  ),
                ),
              ),
            ...visibleReports.map((report) => _ConnectivityCard(report)),
          ],
        ),
      ),
    );
  }
}

class _ConnectivityCard extends StatelessWidget {
  const _ConnectivityCard(this.report);

  final ConnectivityReport report;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.wifi_off_rounded)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.area,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${report.carrier} · ${report.issueType}',
                      style: const TextStyle(color: mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              LabelBadge(report.status, statusColor(report.status)),
            ],
          ),
          const SizedBox(height: 10),
          Text(report.notes),
          const SizedBox(height: 5),
          Text(
            report.reporterEmail,
            style: const TextStyle(color: mutedText, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            'Updated ${_formatDateTime(report.updatedAt)}',
            style: const TextStyle(color: mutedText, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: report.status,
                  decoration: safeInput('Status'),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Reviewed',
                      child: Text('Reviewed'),
                    ),
                    DropdownMenuItem(
                      value: 'Resolved',
                      child: Text('Resolved'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value != null && value != report.status) {
                      final synced = await context
                          .read<AppProvider>()
                          .updateConnectivityStatus(report, value);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            synced
                                ? 'Status updated to $value and synced.'
                                : 'Status updated to $value. Saved locally and will sync when online.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete',
                color: Colors.red,
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return value;
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
        '${two(parsed.hour)}:${two(parsed.minute)}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete connectivity report?'),
        content: const Text('This will also be removed from Supabase.'),
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
      await context.read<AppProvider>().deleteConnectivityReport(report);
    }
  }
}
