import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report.dart';

const navy = Color(0xFF0F172A);
const primary = Color(0xFF4361EE);
const safeBg = Color(0xFFF8FAFC);

Color severityColor(String value) => switch (value) {
  'Critical' => const Color(0xFFEF4444),
  'High' => const Color(0xFFF97316),
  'Medium' => const Color(0xFFFACC15),
  _ => const Color(0xFF22C55E),
};

class LabelBadge extends StatelessWidget {
  final String label;
  final Color color;
  const LabelBadge(this.label, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

class ReportTile extends StatelessWidget {
  final RoadReport report;
  final VoidCallback onTap;
  const ReportTile({super.key, required this.report, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child:
                    report.imagePath != null &&
                        File(report.imagePath!).existsSync()
                    ? Image.file(File(report.imagePath!), fit: BoxFit.cover)
                    : ColoredBox(
                        color: severityColor(
                          report.severity,
                        ).withValues(alpha: .12),
                        child: Icon(
                          Icons.add_road,
                          color: severityColor(report.severity),
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: [
                      LabelBadge(
                        report.severity,
                        severityColor(report.severity),
                      ),
                      LabelBadge(
                        report.status,
                        report.status == 'Resolved' ? Colors.green : primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    report.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${report.votes} verifications',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

InputDecoration safeInput(String label, {IconData? icon}) => InputDecoration(
  labelText: label,
  prefixIcon: icon == null ? null : Icon(icon),
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
);
