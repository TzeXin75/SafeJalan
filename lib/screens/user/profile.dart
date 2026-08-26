import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import '../entry.dart';
import 'report_detail.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final reportCount = app.myReports.length;
    const badges = [
      _BadgeInfo(Icons.flag_rounded, 'First Step', 1, Color(0xFF4361EE)),
      _BadgeInfo(Icons.explore_rounded, 'Road Scout', 3, Color(0xFF0EA5E9)),
      _BadgeInfo(
        Icons.volunteer_activism_rounded,
        'Community Helper',
        5,
        Color(0xFF12B886),
      ),
      _BadgeInfo(
        Icons.shield_rounded,
        'Safety Champion',
        10,
        Color(0xFFFF9F1C),
      ),
      _BadgeInfo(
        Icons.workspace_premium_rounded,
        'SafeJalan Hero',
        20,
        Color(0xFF8B5CF6),
      ),
    ];
    final lockedBadges = badges.where(
      (badge) => reportCount < badge.requiredReports,
    );
    final nextBadge = lockedBadges.isEmpty ? null : lockedBadges.first;
    final badgeProgress = nextBadge == null
        ? 1.0
        : (reportCount / nextBadge.requiredReports).clamp(0.0, 1.0);
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
          const PageTitle('Badge Progress', 'Your community milestones'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            (nextBadge?.color ?? const Color(0xFF12B886))
                                .withValues(alpha: .12),
                        child: Icon(
                          nextBadge?.icon ?? Icons.verified_rounded,
                          color: nextBadge?.color ?? const Color(0xFF12B886),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextBadge == null
                                  ? 'All badges unlocked!'
                                  : 'Next: ${nextBadge.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              nextBadge == null
                                  ? '$reportCount reports completed'
                                  : '$reportCount / ${nextBadge.requiredReports} reports',
                              style: const TextStyle(
                                color: mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(badgeProgress * 100).round()}%',
                        style: TextStyle(
                          color: nextBadge?.color ?? const Color(0xFF12B886),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: badgeProgress,
                      minHeight: 9,
                      backgroundColor: const Color(0xFFE8ECF4),
                      color: nextBadge?.color ?? const Color(0xFF12B886),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final badgeWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: badges
                    .map(
                      (badge) => SizedBox(
                        width: badgeWidth,
                        child: _Badge(
                          badge: badge,
                          earned: reportCount >= badge.requiredReports,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          const PageTitle('Report History', 'Your latest submissions'),
          const SizedBox(height: 8),
          ...app.myVisibleReports
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

class _BadgeInfo {
  final IconData icon;
  final String name;
  final int requiredReports;
  final Color color;

  const _BadgeInfo(this.icon, this.name, this.requiredReports, this.color);
}

class _Badge extends StatelessWidget {
  final _BadgeInfo badge;
  final bool earned;

  const _Badge({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: earned
          ? badge.color.withValues(alpha: .08)
          : const Color(0xFFF3F5F9),
      border: Border.all(
        color: earned
            ? badge.color.withValues(alpha: .24)
            : const Color(0xFFE4E7EC),
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: earned
              ? badge.color.withValues(alpha: .14)
              : const Color(0xFFE4E7EC),
          child: Icon(
            earned ? badge.icon : Icons.lock_outline_rounded,
            color: earned ? badge.color : mutedText,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: earned ? navy : mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                earned ? 'Unlocked' : '${badge.requiredReports} reports',
                style: TextStyle(
                  color: earned ? badge.color : mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
