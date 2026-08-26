import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class ReportDetailScreen extends StatelessWidget {
  final RoadReport report;
  const ReportDetailScreen({super.key, required this.report});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final current = app.latestVersionOf(report);
    final verified = app.hasVerified(current);
    final updating = app.isUpdatingVerification(current);
    return Scaffold(
      appBar: AppBar(title: const Text('Report Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (current.imagePath != null &&
              File(current.imagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(current.imagePath!),
                height: 220,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: severityColor(current.severity).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.add_road,
                size: 76,
                color: severityColor(current.severity),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              LabelBadge(current.severity, severityColor(current.severity)),
              LabelBadge(
                current.status,
                current.status == 'Resolved' ? Colors.green : primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            current.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            current.locationName,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const Divider(height: 32),
          Text(
            current.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Reported on ${current.createdOn}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 24),
          (verified ? OutlinedButton.icon : FilledButton.icon)(
            onPressed: updating
                ? null
                : () async {
                    final nowVerified = await context
                        .read<AppProvider>()
                        .toggleVerification(current);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nowVerified
                                ? 'Verification recorded.'
                                : 'Verification cancelled.',
                          ),
                        ),
                      );
                    }
                  },
            icon: Icon(verified ? Icons.undo : Icons.thumb_up),
            label: Text(
              verified
                  ? 'Cancel verification (${current.votes})'
                  : 'Still exists (${current.votes})',
            ),
          ),
        ],
      ),
    );
  }
}
