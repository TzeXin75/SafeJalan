import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                child: _Stat('${reports.length}', 'Total Reports', primary),
              ),
              const SizedBox(width: 8),
              Expanded(child: _Stat('$resolved', 'Resolved', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _Stat('$completion%', 'Completion', safeOrange)),
            ],
          ),
          const SizedBox(height: 18),
          _GovernmentDataSection(
            safeJalanCompletion: completion,
            safeJalanTotal: reports.length,
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
                children: categories.isEmpty
                    ? const [
                        Text(
                          'No SafeJalan report data yet.',
                          style: TextStyle(color: mutedText),
                        ),
                      ]
                    : categories.entries
                          .map(
                            (entry) => _Bar(
                              entry.key,
                              entry.value,
                              reports.length,
                              primary,
                            ),
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
                children: severity.isEmpty
                    ? const [
                        Text(
                          'No SafeJalan report data yet.',
                          style: TextStyle(color: mutedText),
                        ),
                      ]
                    : severity.entries
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
          ),
        ],
      ),
    ),
  );
}

class _GovernmentDataSection extends StatelessWidget {
  final int safeJalanCompletion;
  final int safeJalanTotal;

  const _GovernmentDataSection({
    required this.safeJalanCompletion,
    required this.safeJalanTotal,
  });

  Future<Map<String, dynamic>> _loadData() async {
    final json = await rootBundle.loadString(
      'assets/data/kkr_myjalan_statistics.json',
    );
    return jsonDecode(json) as Map<String, dynamic>;
  }

  String _number(Object? value) {
    final digits = value.toString();
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _loadData(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Government statistics could not be loaded.'),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final data = snapshot.data!;
      final kkrRate = (data['kkrResolutionRate'] as num).toDouble();
      final difference = safeJalanCompletion - kkrRate;
      final differenceText =
          '${difference >= 0 ? '+' : ''}'
          '${difference.toStringAsFixed(1)}%';
      final categoryData =
          (data['categoryBreakdown'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList()
            ..sort(
              (first, second) =>
                  (second['count'] as int).compareTo(first['count'] as int),
            );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_outlined,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Official MYJalan Data',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Static government data · ${data['dataAsOf']}',
                              style: const TextStyle(
                                color: mutedText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const LabelBadge('KKR', primary),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _number(data['totalComplaints']),
                    style: const TextStyle(
                      color: navy,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total complaints received by MYJalan',
                    style: TextStyle(color: mutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallMetric(
                          value: _number(data['kkrComplaints']),
                          label: 'Under KKR',
                          color: safeOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallMetric(
                          value: _number(data['kkrResolved']),
                          label: 'Resolved',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallMetric(
                          value: _number(data['kkrInProgress']),
                          label: 'In progress',
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KKR resolution rate',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${kkrRate.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: kkrRate / 100,
                    minHeight: 10,
                    color: Colors.green,
                    backgroundColor: Colors.green.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: safeJalanTotal == 0
                        ? const Text(
                            'SafeJalan has no report data for comparison yet.',
                            style: TextStyle(fontSize: 12, color: navy),
                          )
                        : Text(
                            'SafeJalan: $safeJalanCompletion%  ·  '
                            'Difference from KKR: $differenceText',
                            style: const TextStyle(
                              fontSize: 12,
                              color: navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 14),
                  const Text(
                    'KKR Complaints by Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Breakdown of 21,448 complaints under KKR',
                    style: TextStyle(fontSize: 11, color: mutedText),
                  ),
                  const SizedBox(height: 16),
                  ...categoryData.asMap().entries.map(
                    (entry) => _GovernmentCategoryBar(
                      name: entry.value['name'] as String,
                      englishName: entry.value['englishName'] as String,
                      count: entry.value['count'] as int,
                      total: data['kkrComplaints'] as int,
                      color:
                          _categoryColors[entry.key % _categoryColors.length],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Period: ${data['periodStart']} – ${data['dataAsOf']}',
                    style: const TextStyle(fontSize: 11, color: mutedText),
                  ),
                  Text(
                    'Source: ${data['sourceOrganisation']}',
                    style: const TextStyle(fontSize: 11, color: mutedText),
                  ),
                  SelectableText(
                    data['sourceUrl'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

const _categoryColors = [
  Color(0xFF3B5BDB),
  Color(0xFFFF9F1C),
  Color(0xFF12B886),
  Color(0xFF845EF7),
  Color(0xFF339AF0),
];

class _SmallMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SmallMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: mutedText),
        ),
      ],
    ),
  );
}

class _GovernmentCategoryBar extends StatelessWidget {
  final String name;
  final String englishName;
  final int count;
  final int total;
  final Color color;

  const _GovernmentCategoryBar({
    required this.name,
    required this.englishName,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: name,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '  $englishName',
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              count.toString().replaceAllMapped(
                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (match) => ',',
              ),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: total == 0 ? 0 : count / total,
          color: color,
          backgroundColor: color.withValues(alpha: .1),
          minHeight: 9,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
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
