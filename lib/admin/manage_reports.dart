import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/admin/report_detail.dart';
import 'package:safejalan/models/report.dart';
import 'package:safejalan/widgets/stored_image.dart';

class ManageReportsScreen extends StatelessWidget {
  const ManageReportsScreen({super.key, this.statusFilter, this.onShowAll});

  final String? statusFilter;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final reports = statusFilter == null
        ? app.adminVisibleReports
        : app.adminVisibleReports
              .where(
                (report) =>
                    report.status.toLowerCase() == statusFilter!.toLowerCase(),
              )
              .toList();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    statusFilter == null
                        ? 'Manage Reports (${reports.length})'
                        : '$statusFilter Reports (${reports.length})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (statusFilter != null)
                  TextButton.icon(
                    onPressed: onShowAll,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Show all'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final isPending = report.status.toLowerCase() == 'pending';
                return _AdminReportCard(
                  report: report,
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminReportDetailScreen(report: report),
                    ),
                  ),
                  onReview: isPending
                      ? () => context.read<AppProvider>().updateStatus(
                          report,
                          'Reviewed',
                        )
                      : null,
                  onReject: isPending
                      ? () => context.read<AppProvider>().updateStatus(
                          report,
                          'Rejected',
                        )
                      : null,
                  onDelete: () =>
                      context.read<AppProvider>().deleteReport(report),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminReportCard extends StatelessWidget {
  const _AdminReportCard({
    required this.report,
    required this.onOpen,
    required this.onDelete,
    this.onReview,
    this.onReject,
  });

  final RoadReport report;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback? onReview;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final isResolved = report.status.toLowerCase() == 'resolved';
    final isRejected = report.status.toLowerCase() == 'rejected';
    final resolvedDate = DateTime.tryParse(report.updatedAt)?.toLocal();
    final deleteDate = resolvedDate == null
        ? null
        : DateTime(resolvedDate.year, resolvedDate.month + 3, resolvedDate.day);
    final statusText = isResolved
        ? deleteDate == null
              ? 'Repair completed'
              : 'Completed · Archives ${deleteDate.day}/${deleteDate.month}/${deleteDate.year}'
        : isRejected
        ? 'Report closed'
        : '${report.status} · Tap to continue maintenance';
    final statusIcon = isResolved
        ? Icons.check_circle_rounded
        : isRejected
        ? Icons.cancel_rounded
        : Icons.arrow_circle_right_rounded;
    final footerColor = isResolved
        ? safeTeal
        : isRejected
        ? Colors.red
        : primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 82,
                      height: 82,
                      child: StoredImage(
                        path: report.imagePath,
                        fallback: ColoredBox(
                          color: severityColor(
                            report.severity,
                          ).withValues(alpha: .10),
                          child: Icon(
                            Icons.add_road_rounded,
                            color: severityColor(report.severity),
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            LabelBadge(
                              report.severity,
                              severityColor(report.severity),
                            ),
                            LabelBadge(
                              report.status,
                              statusColor(report.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: mutedText,
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                report.locationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: mutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${report.votes} verifications',
                          style: const TextStyle(
                            color: mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    onSelected: (value) {
                      if (value == 'delete') _confirmDelete(context);
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
              const SizedBox(height: 12),
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
                    Icon(statusIcon, color: footerColor, size: 19),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: footerColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: footerColor),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text(
          'This report will be removed after synchronization.',
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
    if (confirmed == true) onDelete();
  }
}
