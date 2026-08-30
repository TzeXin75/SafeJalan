import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/safety_announcement.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = context.watch<AppProvider>().activeAnnouncements;
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Announcements')),
      body: RefreshIndicator(
        onRefresh: context.read<AppProvider>().syncSafetyAnnouncements,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageTitle(
              'Community Alerts',
              'Official road safety updates from SafeJalan',
            ),
            const SizedBox(height: 14),
            if (announcements.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No active announcements.')),
                ),
              ),
            ...announcements.map(_AnnouncementCard.new),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard(this.announcement);

  final SafetyAnnouncement announcement;

  @override
  Widget build(BuildContext context) {
    final color = switch (announcement.priority) {
      'Emergency' => Colors.red,
      'Important' => safeOrange,
      _ => primary,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_rounded, color: color),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                LabelBadge(announcement.priority, color),
              ],
            ),
            const SizedBox(height: 10),
            Text(announcement.message),
            const SizedBox(height: 10),
            Text(
              announcement.createdAt.split('T').first,
              style: const TextStyle(color: mutedText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
