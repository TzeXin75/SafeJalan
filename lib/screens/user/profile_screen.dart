import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import '../entry_screen.dart';
import 'report_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFDDE4FF),
              child: Icon(Icons.person, color: primary, size: 56),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              app.userName,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              app.email,
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Metric('Total Points', '${app.points}', primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  'Reports',
                  '${app.myReports.length}',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(
                app.isRemoteConfigured ? Icons.cloud_done : Icons.storage,
                color: app.lastSyncError == null ? primary : Colors.orange,
              ),
              title: Text(
                app.isRemoteConfigured
                    ? 'SQLite + Supabase'
                    : 'SQLite local database',
              ),
              subtitle: Text(
                !app.isRemoteConfigured
                    ? 'Remote database is not configured.'
                    : app.lastSyncError == null
                    ? 'Local and remote reports are synchronized.'
                    : 'Saved locally. Remote sync will retry.',
              ),
              trailing: app.isSyncing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      tooltip: 'Sync now',
                      onPressed: app.syncReports,
                      icon: const Icon(Icons.sync),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Earned Badges',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          if (app.myReports.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No badges earned yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            )
          else
            Row(
              children: [
                const Expanded(child: _Badge(Icons.rocket_launch, 'Pioneer')),
                if (app.myReports.length >= 5)
                  const Expanded(child: _Badge(Icons.verified, 'Verified')),
                if (app.myReports.length >= 10)
                  const Expanded(
                    child: _Badge(Icons.emoji_events, 'Contributor'),
                  ),
              ],
            ),
          const SizedBox(height: 18),
          const Text(
            'Report History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          ...app.myReports
              .take(3)
              .map(
                (r) => ReportTile(
                  report: r,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailScreen(report: r),
                    ),
                  ),
                ),
              ),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AppProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const EntryScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Metric(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: primary, size: 30),
      Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
