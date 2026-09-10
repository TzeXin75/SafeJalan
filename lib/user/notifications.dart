import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/models/safety_announcement.dart';
import 'package:safejalan/models/user_notification.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/user/announcement_detail.dart';
import 'package:safejalan/user/report_detail.dart';
import 'package:safejalan/widgets/common.dart';

class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    initialIndex: initialTab,
    child: Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications'),
            Text(
              'Updates for your reports',
              style: TextStyle(color: mutedText, fontSize: 11),
            ),
          ],
        ),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Your notifications'),
            Tab(text: 'Announcements'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [_PersonalNotifications(), _AnnouncementNotifications()],
      ),
    ),
  );
}

class _PersonalNotifications extends StatelessWidget {
  const _PersonalNotifications();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final items = app.userNotifications;
    return RefreshIndicator(
      onRefresh: context.read<AppProvider>().syncUserNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          PageTitle(
            'Report Updates',
            '${app.unreadUserNotifications.length} unread · Updates about your reports',
            trailing: app.unreadUserNotifications.isEmpty
                ? null
                : TextButton.icon(
                    onPressed: app.markAllUserNotificationsRead,
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Read all'),
                  ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 44),
                    SizedBox(height: 10),
                    Text('No report updates yet.'),
                  ],
                ),
              ),
            ),
          ...items.map((item) => _PersonalNotificationCard(item: item)),
        ],
      ),
    );
  }
}

class _PersonalNotificationCard extends StatelessWidget {
  const _PersonalNotificationCard({required this.item});

  final UserNotificationItem item;

  IconData get _icon => switch (item.type) {
    'in_progress' => Icons.build_circle_outlined,
    'resolved' => Icons.check_circle_outline_rounded,
    'rejected' => Icons.cancel_outlined,
    _ => Icons.description_outlined,
  };

  Color get _color => switch (item.type) {
    'in_progress' => primary,
    'resolved' => safeTeal,
    'rejected' => Colors.red,
    _ => safeOrange,
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    color: item.isRead ? Colors.white : _color.withValues(alpha: .055),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final app = context.read<AppProvider>();
        await app.markUserNotificationRead(item);
        final matching = app.reports.where(
          (report) => report.remoteId == item.reportRemoteId,
        );
        if (!context.mounted || matching.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(report: matching.first),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _color.withValues(alpha: .12),
              foregroundColor: _color,
              child: Icon(_icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: _color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(item.message),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(color: mutedText, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: mutedText),
          ],
        ),
      ),
    ),
  );

  String _formatDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    return date == null
        ? value
        : DateFormat('d MMM yyyy · h:mm a').format(date);
  }
}

class _AnnouncementNotifications extends StatelessWidget {
  const _AnnouncementNotifications();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final provider = context.read<AppProvider>();
    final unreadNonEmergency = app.unreadAnnouncements.where(
      (item) => item.priority.toLowerCase() != 'emergency',
    );
    return RefreshIndicator(
      onRefresh: () async {
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
            trailing: unreadNonEmergency.isEmpty
                ? null
                : TextButton.icon(
                    onPressed: app.markAllNonEmergencyAnnouncementsRead,
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Read all'),
                  ),
          ),
          const SizedBox(height: 10),
          if (app.activeAnnouncements.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('No active announcements.')),
              ),
            ),
          ...app.activeAnnouncements.map(
            (item) => _AnnouncementCard(
              item: item,
              isRead: app.isAnnouncementRead(item),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item, required this.isRead});

  final SafetyAnnouncement item;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.priority) {
      'Emergency' => Colors.red,
      'Important' => safeOrange,
      _ => primary,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(Icons.campaign_outlined, color: color),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          item.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnnouncementDetailScreen(announcement: item),
          ),
        ),
      ),
    );
  }
}
