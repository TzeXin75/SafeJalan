import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/models/connectivity_report.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/admin/connectivity_detail.dart';

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
    final reports = context
        .watch<AppProvider>()
        .connectivityReports
        .where((report) => !report.isDeleted)
        .toList()
      ..sort((first, second) {
        final firstComplete = const {
          'resolved',
          'rejected',
        }.contains(first.status.toLowerCase())
            ? 1
            : 0;
        final secondComplete = const {
          'resolved',
          'rejected',
        }.contains(second.status.toLowerCase())
            ? 1
            : 0;
        final completion = firstComplete.compareTo(secondComplete);
        if (completion != 0) return completion;
        return second.updatedAt.compareTo(first.updatedAt);
      });
    final visibleReports = _filter == 'All'
        ? reports
        : reports
        .where(
          (report) =>
      report.status.toLowerCase() == _filter.toLowerCase(),
    )
        .toList();
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
                children: ['All', 'Pending', 'Reviewed', 'Resolved', 'Rejected']
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
            ...visibleReports.map(
                  (report) => _ConnectivityCard(
                report: report,
                onOpen: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminConnectivityDetailScreen(report: report),
                  ),
                ),
                onReview: report.status.toLowerCase() == 'pending'
                    ? () => _updateStatus(context, report, 'Reviewed')
                    : null,
                onReject: report.status.toLowerCase() == 'pending'
                    ? () => _updateStatus(context, report, 'Rejected')
                    : null,
                onDelete: () => _confirmDelete(context, report),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context,
      ConnectivityReport report,
      String status,
      ) async {
    final synced = await context
        .read<AppProvider>()
        .updateConnectivityStatus(report, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced
              ? 'Connectivity report updated to $status and synced.'
              : 'Connectivity report updated to $status. It will sync when online.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      ConnectivityReport report,
      ) async {
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

class _ConnectivityCard extends StatelessWidget {
  const _ConnectivityCard({
    required this.report,
    required this.onOpen,
    required this.onDelete,
    this.onReview,
    this.onReject,
  });

  final ConnectivityReport report;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback? onReview;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final currentStatus = report.status.toLowerCase();
    final cardColor = statusColor(report.status);
    final isResolved = currentStatus == 'resolved';
    final isRejected = currentStatus == 'rejected';
    final footerText = isResolved
        ? 'Connectivity issue resolved'
        : isRejected
        ? 'Connectivity report rejected'
        : 'Manage Connectivity';
    final footerIcon = isResolved
        ? Icons.check_circle_rounded
        : isRejected
        ? Icons.cancel_rounded
        : Icons.arrow_circle_right_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Color.alphaBlend(
        cardColor.withValues(alpha: .035),
        Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: cardColor.withValues(alpha: .34),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: cardColor, width: 5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cardColor.withValues(alpha: .12),
                    child: Icon(Icons.wifi_off_rounded, color: cardColor),
                  ),
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
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete report'),
                          ],
                        ),
                      ),
                    ],
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
              const SizedBox(height: 3),
              Text(
                'Updated ${_formatDateTime(report.updatedAt)}',
                style: const TextStyle(color: mutedText, fontSize: 11),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 11),
              if (onReview != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onReview,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Review'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(footerIcon, color: cardColor, size: 19),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        footerText,
                        style: TextStyle(
                          color: cardColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: cardColor),
                  ],
                ),
            ],
          ),
        ),
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
}
