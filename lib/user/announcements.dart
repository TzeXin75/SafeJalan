import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/safety_announcement.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/user/announcement_detail.dart';
import 'package:safejalan_native/widgets/common.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final announcements = app.activeAnnouncements;
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Announcements')),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<AppProvider>();
          await provider.syncSafetyAnnouncements();
          await provider.syncAnnouncementReads();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            PageTitle(
              'Community Alerts',
              '${app.unreadAnnouncements.length} unread · Official SafeJalan updates',
              trailing: app.unreadAnnouncements.isEmpty
                  ? null
                  : TextButton.icon(
                      onPressed: app.markAllNonEmergencyAnnouncementsRead,
                      icon: const Icon(Icons.done_all_rounded),
                      label: const Text('Read all'),
                    ),
            ),
            const SizedBox(height: 14),
            if (announcements.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No active announcements.')),
                ),
              ),
            ...announcements.map(
              (announcement) => _AnnouncementCard(
                announcement,
                isRead: app.isAnnouncementRead(announcement),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard(this.announcement, {required this.isRead});

  final SafetyAnnouncement announcement;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final color = announcementPriorityColor(announcement.priority);
    final emergency = announcement.priority.toLowerCase() == 'emergency';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? Colors.white : color.withValues(alpha: .055),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AnnouncementDetailScreen(announcement: announcement),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      emergency
                          ? Icons.warning_amber_rounded
                          : Icons.campaign_rounded,
                      color: color,
                    ),
                  ),
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
                  if (!isRead)
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  LabelBadge(announcement.priority, color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                announcement.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    announcement.createdAt.split('T').first,
                    style: const TextStyle(color: mutedText, fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    'Details',
                    style: TextStyle(
                      color: isRead ? mutedText : color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color announcementPriorityColor(String priority) => switch (priority) {
  'Emergency' => const Color(0xFFDC2626),
  'Important' => safeOrange,
  _ => primary,
};
