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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Report Detail')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (report.imagePath != null && File(report.imagePath!).existsSync())
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(report.imagePath!),
              height: 220,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: severityColor(report.severity).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.add_road,
              size: 76,
              color: severityColor(report.severity),
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            LabelBadge(report.severity, severityColor(report.severity)),
            LabelBadge(
              report.status,
              report.status == 'Resolved' ? Colors.green : primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          report.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          report.locationName,
          style: const TextStyle(color: Colors.blueGrey),
        ),
        const Divider(height: 32),
        Text(
          report.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          'Reported on ${report.createdOn}',
          style: const TextStyle(color: Colors.blueGrey),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            await context.read<AppProvider>().vote(report);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification recorded.')),
              );
            }
          },
          icon: const Icon(Icons.thumb_up),
          label: Text('Still exists (${report.votes})'),
        ),
      ],
    ),
  );
}
