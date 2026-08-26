import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class ManageReportsScreen extends StatelessWidget {
  const ManageReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final reports = app.adminVisibleReports;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Manage Reports (${reports.length})',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final isPending = report.status.toLowerCase() == 'pending';
                final isResolved = report.status.toLowerCase() == 'resolved';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReportTile(report: report, onTap: () {}),
                        if (isPending)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context
                                      .read<AppProvider>()
                                      .updateStatus(report, 'Resolved'),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context
                                      .read<AppProvider>()
                                      .updateStatus(report, 'Rejected'),
                                  child: const Text('Reject'),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete report',
                                color: Colors.red,
                                onPressed: () => context
                                    .read<AppProvider>()
                                    .deleteReport(report),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          )
                        else
                          _CompletedReportMessage(
                            isResolved: isResolved,
                            resolvedAt: report.updatedAt,
                          ),
                      ],
                    ),
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

class _CompletedReportMessage extends StatelessWidget {
  const _CompletedReportMessage({
    required this.isResolved,
    required this.resolvedAt,
  });

  final bool isResolved;
  final String resolvedAt;

  @override
  Widget build(BuildContext context) {
    final resolvedDate = DateTime.tryParse(resolvedAt)?.toLocal();
    final deleteDate = resolvedDate == null
        ? null
        : DateTime(resolvedDate.year, resolvedDate.month + 3, resolvedDate.day);
    final dateText = deleteDate == null
        ? ''
        : ' Auto-archive on ${deleteDate.day}/${deleteDate.month}/${deleteDate.year}.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isResolved ? Colors.green : Colors.red).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isResolved
            ? 'Approved. This report stays visible for 3 months.$dateText'
            : 'Rejected. No further approval action is required.',
        style: TextStyle(
          color: isResolved ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
