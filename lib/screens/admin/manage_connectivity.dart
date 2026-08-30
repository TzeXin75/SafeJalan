import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/connectivity_report.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class ManageConnectivityScreen extends StatelessWidget {
  const ManageConnectivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().connectivityReports;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: context.read<AppProvider>().syncConnectivityReports,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageTitle(
              'Connectivity (${reports.length})',
              'Review mobile signal and Wi-Fi gaps',
            ),
            const SizedBox(height: 14),
            if (reports.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No connectivity reports.')),
                ),
              ),
            ...reports.map((report) => _ConnectivityCard(report)),
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
              LabelBadge(
                report.status,
                report.status == 'Resolved' ? Colors.green : primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(report.notes),
          const SizedBox(height: 5),
          Text(
            report.reporterEmail,
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
                  onChanged: (value) {
                    if (value != null && value != report.status) {
                      context.read<AppProvider>().updateConnectivityStatus(
                        report,
                        value,
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
