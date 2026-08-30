import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/services/database_service.dart';
import 'package:safejalan_native/widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().adminVisibleReports;
    final resolved = reports.where((r) => r.status == 'Resolved').length;
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
                ),
              ),
              _Kpi(
                Icons.report,
                '${reports.length}',
                'Total Reports',
                Colors.orange,
              ),
              _Kpi(Icons.check_circle, '$resolved', 'Resolved', Colors.green),
              _Kpi(
                Icons.pending_actions,
                '${reports.length - resolved}',
                'Pending',
                Colors.red,
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
          ...reports.take(3).map((r) => ReportTile(report: r, onTap: () {})),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _Kpi(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: mutedText)),
        ],
      ),
    ),
  );
}
