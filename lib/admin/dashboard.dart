import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/services/database_service.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/admin/report_detail.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final void Function(int index, String? reportStatus) onNavigate;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final reports = app.adminVisibleReports;
    final resolved = reports.where((r) => r.status == 'Resolved').length;
    final pending = reports
        .where((r) => r.status.toLowerCase() == 'pending')
        .length;
    final connectivityReports = app.connectivityReports
        .where((report) => !report.isDeleted)
        .toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageTitle('Dashboard', 'Live community safety overview'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              FutureBuilder<int>(
                future: DatabaseService.instance.getRegularUserCount(),
                builder: (context, snapshot) => _Kpi(
                  Icons.people,
                  '${snapshot.data ?? 0}',
                  'Total Users',
                  primary,
                  onTap: () => onNavigate(1, null),
                ),
              ),
              _Kpi(
                Icons.report,
                '${reports.length}',
                'Total Reports',
                Colors.orange,
                onTap: () => onNavigate(2, null),
              ),
              _Kpi(
                Icons.check_circle,
                '$resolved',
                'Resolved',
                Colors.green,
                onTap: () => onNavigate(2, 'Resolved'),
              ),
              _Kpi(
                Icons.pending_actions,
                '$pending',
                'Pending',
                Colors.red,
                onTap: () => onNavigate(2, 'Pending'),
              ),
              _Kpi(
                Icons.wifi_off_rounded,
                '${connectivityReports.length}',
                'Connectivity',
                const Color(0xFF8B5CF6),
                onTap: () => onNavigate(3, null),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const PageTitle('Report completion', 'Resolution progress'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reports.isEmpty
                        ? '0%'
                        : '${(resolved / reports.length * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: safeTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: reports.isEmpty ? 0 : resolved / reports.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reports resolved by local authorities',
                    style: TextStyle(color: mutedText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const PageTitle('Recent Reports', 'Latest community submissions'),
          const SizedBox(height: 8),
          ...reports
              .take(3)
              .map(
                (r) => ReportTile(
              report: r,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminReportDetailScreen(report: r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final VoidCallback onTap;
  const _Kpi(
      this.icon,
      this.value,
      this.label,
      this.color, {
        required this.onTap,
      });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Open $label management',
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: mutedText,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: mutedText),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
