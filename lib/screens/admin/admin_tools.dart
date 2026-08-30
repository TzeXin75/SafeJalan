import 'package:flutter/material.dart';
import '../../widgets/common.dart';
import 'manage_announcements.dart';
import 'risk_heatmap.dart';
import 'statistics.dart';

class AdminToolsScreen extends StatelessWidget {
  const AdminToolsScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageTitle('Admin Tools', 'Maps, analytics and communication'),
        const SizedBox(height: 16),
        _ToolCard(
          icon: Icons.campaign_rounded,
          title: 'Safety Announcements',
          subtitle: 'Create, edit, publish and delete user notices',
          color: safeOrange,
          page: const ManageAnnouncementsScreen(),
        ),
        _ToolCard(
          icon: Icons.location_on_rounded,
          title: 'Risk Heatmap',
          subtitle: 'Review the geographic distribution of road hazards',
          color: Colors.red,
          page: const _ToolPage(
            title: 'Risk Heatmap',
            child: RiskHeatmapScreen(),
          ),
        ),
        _ToolCard(
          icon: Icons.insights_rounded,
          title: 'Statistics',
          subtitle: 'Analyse report categories and completion rates',
          color: primary,
          page: const _ToolPage(title: 'Statistics', child: StatisticsScreen()),
        ),
      ],
    ),
  );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.page,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .12),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    ),
  );
}

class _ToolPage extends StatelessWidget {
  const _ToolPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}
