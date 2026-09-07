import 'package:flutter/material.dart';

import 'package:safejalan_native/models/report.dart';
import 'package:safejalan_native/widgets/common.dart';
import 'package:safejalan_native/widgets/stored_image.dart';

class AdminReportDetailScreen extends StatelessWidget {
  const AdminReportDetailScreen({super.key, required this.report});

  final RoadReport report;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Report Details')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ZoomableStoredImage(
          path: report.imagePath,
          fallback: _ReportImageFallback(report: report),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the photo to open it. Pinch to zoom.',
          textAlign: TextAlign.center,
          style: TextStyle(color: mutedText, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LabelBadge(report.severity, severityColor(report.severity)),
            LabelBadge(report.status, statusColor(report.status)),
            LabelBadge(report.category, primary),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          report.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        _DetailRow(Icons.location_on_outlined, 'Location', report.locationName),
        _DetailRow(
          Icons.gps_fixed,
          'GPS',
          '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}',
        ),
        _DetailRow(
          Icons.person_outline,
          'Reporter',
          report.reporterEmail.isEmpty ? 'Unknown' : report.reporterEmail,
        ),
        _DetailRow(
          Icons.calendar_today_outlined,
          'Reported on',
          report.createdOn,
        ),
        _DetailRow(Icons.verified_outlined, 'Verifications', '${report.votes}'),
        const Divider(height: 30),
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          report.description,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    ),
  );
}

class _ReportImageFallback extends StatelessWidget {
  const _ReportImageFallback({required this.report});

  final RoadReport report;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: severityColor(report.severity).withValues(alpha: .1),
    child: Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 68,
        color: severityColor(report.severity),
      ),
    ),
  );
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
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 88,
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
