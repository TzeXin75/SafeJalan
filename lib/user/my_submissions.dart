import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/models/connectivity_report.dart';
import 'package:safejalan/models/report.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/user/connectivity_detail.dart';
import 'package:safejalan/user/report_detail.dart';
import 'package:safejalan/widgets/common.dart';

class MySubmissionsScreen extends StatefulWidget {
  const MySubmissionsScreen({super.key, required this.initialTab});

  final int initialTab;

  @override
  State<MySubmissionsScreen> createState() => _MySubmissionsScreenState();
}

class _MySubmissionsScreenState extends State<MySubmissionsScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final roadReports = app.myProfileReports;
    final connectivityReports = app.connectivityReports
        .where(
          (report) =>
      report.reporterEmail.toLowerCase() == app.email.toLowerCase(),
    )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.add_road_rounded),
                  label: Text('Road Reports'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.wifi_off_rounded),
                  label: Text('Connectivity'),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (selection) =>
                  setState(() => _selectedTab = selection.first),
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _RoadReportList(reports: roadReports)
                : _ConnectivityReportList(reports: connectivityReports),
          ),
        ],
      ),
    );
  }
}

class _RoadReportList extends StatelessWidget {
  const _RoadReportList({required this.reports});

  final List<RoadReport> reports;

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const _EmptyReports(
        icon: Icons.add_road_rounded,
        message: 'No road reports yet.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportTile(
          report: report,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDetailScreen(report: report),
            ),
          ),
        );
      },
    );
  }
}

class _ConnectivityReportList extends StatelessWidget {
  const _ConnectivityReportList({required this.reports});

  final List<ConnectivityReport> reports;

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const _EmptyReports(
        icon: Icons.wifi_off_rounded,
        message: 'No connectivity reports yet.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConnectivityDetailScreen(report: report),
              ),
            ),
            leading: const CircleAvatar(
              child: Icon(Icons.wifi_off_rounded),
            ),
            title: Text(report.area),
            subtitle: Text('${report.carrier} · ${report.issueType}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LabelBadge(report.status, statusColor(report.status)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 52, color: mutedText),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: mutedText)),
      ],
    ),
  );
}
