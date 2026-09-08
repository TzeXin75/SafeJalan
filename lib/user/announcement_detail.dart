import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/safety_announcement.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final SafetyAnnouncement announcement;

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppProvider>().markAnnouncementRead(widget.announcement);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
    final color = _priorityColor(announcement.priority);
    final explanation = switch (announcement.priority) {
      'Emergency' =>
        'Immediate attention required. Open and follow the safety instructions now.',
      'Important' =>
        'Important community information that may affect your journey.',
      _ => 'General SafeJalan community information and safety updates.',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: .25)),
            ),
            child: Row(
              children: [
                Icon(
                  announcement.priority == 'Emergency'
                      ? Icons.warning_amber_rounded
                      : Icons.campaign_rounded,
                  color: color,
                  size: 36,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelBadge(announcement.priority, color),
                      const SizedBox(height: 7),
                      Text(
                        explanation,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            announcement.title,
            style: const TextStyle(
              color: navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Published ${_formatDateTime(announcement.createdAt)}',
            style: const TextStyle(color: mutedText, fontSize: 12),
          ),
          const Divider(height: 32),
          Text(
            announcement.message,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.done_all_rounded, color: safeTeal),
              const SizedBox(width: 8),
              Text(
                'Marked as read for ${context.watch<AppProvider>().userName}',
                style: const TextStyle(
                  color: safeTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) => switch (priority) {
    'Emergency' => const Color(0xFFDC2626),
    'Important' => safeOrange,
    _ => primary,
  };

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return value;
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
        '${two(parsed.hour)}:${two(parsed.minute)}';
  }
}
