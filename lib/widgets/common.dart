import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report.dart';

const navy = Color(0xFF101828);
const primary = Color(0xFF3B5BDB);
const safeTeal = Color(0xFF12B886);
const safeOrange = Color(0xFFFF9F1C);
const safeBg = Color(0xFFF4F7FC);
const mutedText = Color(0xFF667085);
const softBorder = Color(0xFFE4E7EC);

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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: .16)),
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
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 76,
                height: 76,
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
            const SizedBox(width: 14),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: navy,
                    ),
                  ),
                  Text(
                    report.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: mutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${report.votes} verifications',
                    style: const TextStyle(color: mutedText, fontSize: 11),
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
  fillColor: const Color(0xFFFAFBFF),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: softBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: softBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: primary, width: 1.6),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Color(0xFFD92D20)),
  ),
);

class SafeLogo extends StatelessWidget {
  final double size;
  final bool dark;
  const SafeLogo({super.key, this.size = 64, this.dark = false});

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Transform.scale(
      scale: 1.22,
      child: Image.asset(
        'assets/images/safejalan_logo.png',
        fit: BoxFit.cover,
        semanticLabel: 'SafeJalan logo',
      ),
    ),
  );
}

class SafeMark extends StatelessWidget {
  final double size;
  const SafeMark({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Image.asset(
      'assets/images/safejalan_app_icon.png',
      fit: BoxFit.contain,
      semanticLabel: 'SafeJalan symbol',
    ),
  );
}

class HeroBrandMark extends StatelessWidget {
  final double size;
  const HeroBrandMark({super.key, this.size = 148});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * .12),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFEAF2FA)],
      ),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFF9F1C).withValues(alpha: .28),
          blurRadius: 34,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 20,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Image.asset(
      'assets/images/safejalan_app_icon.png',
      fit: BoxFit.contain,
      semanticLabel: 'SafeJalan symbol',
    ),
  );
}

class PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const PageTitle(this.title, this.subtitle, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: mutedText)),
          ],
        ),
      ),
      trailing ?? const SizedBox.shrink(),
    ],
  );
}

class AuthBackdrop extends StatelessWidget {
  final Widget child;
  const AuthBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEAF0FF), safeBg, safeBg],
      ),
    ),
    child: child,
  );
}

class FormCard extends StatelessWidget {
  final Widget child;
  const FormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: softBorder),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F101828),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}
