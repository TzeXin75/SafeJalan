import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().adminVisibleReports;
    final categories = <String, int>{};
    final severity = <String, int>{};
    for (final report in reports) {
      categories[report.category] = (categories[report.category] ?? 0) + 1;
      severity[report.severity] = (severity[report.severity] ?? 0) + 1;
    }
    final resolved = reports
        .where((report) => report.status == 'Resolved')
        .length;
    final completion = reports.isEmpty
        ? 0
        : (resolved / reports.length * 100).round();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Live analytics overview',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat('$completion%', 'Completion Rate', Colors.green),
              ),
              const SizedBox(width: 10),
              const Expanded(child: _Stat('—', 'Avg Resolution', primary)),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Reports by Category',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: categories.entries
                    .map(
                      (entry) =>
                          _Bar(entry.key, entry.value, reports.length, primary),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Reports by Severity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: severity.entries
                    .map(
                      (entry) => _Bar(
                        entry.key,
                        entry.value,
                        reports.length,
                        severityColor(entry.key),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
          ),
        ],
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  final String label;
  final int value, total;
  final Color color;
  const _Bar(this.label, this.value, this.total, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$value'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total == 0 ? 0 : value / total,
          color: color,
          minHeight: 9,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    ),
  );
}
