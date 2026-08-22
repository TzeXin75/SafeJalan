import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().reports;
    final resolved = reports.where((r) => r.status == 'Resolved').length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text('Live overview', style: TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              const _Kpi(Icons.people, '0', 'Total Users', primary),
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
          const Text(
            'Report completion',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
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
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Reports',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
