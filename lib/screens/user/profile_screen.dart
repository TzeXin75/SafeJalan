import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import '../entry_screen.dart';
import 'report_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF253B80), navy],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24101828),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFFE7ECFF),
                    backgroundImage:
                        app.profileImagePath != null &&
                            File(app.profileImagePath!).existsSync()
                        ? FileImage(File(app.profileImagePath!))
                        : null,
                    child:
                        app.profileImagePath == null ||
                            !File(app.profileImagePath!).existsSync()
                        ? const Icon(Icons.person, color: primary, size: 52)
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  app.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.email,
                  style: const TextStyle(color: Color(0xFFB8C3DC)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                ),
              ],
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
          const SizedBox(height: 18),
          const PageTitle('Earned Badges', 'Your community milestones'),
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
          const PageTitle('Report History', 'Your latest submissions'),
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
          const SizedBox(height: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: const TextStyle(color: mutedText, fontSize: 12)),
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
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: primary.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(icon, color: primary, size: 28),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
