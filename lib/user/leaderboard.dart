import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/leaderboard_entry.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _entries;
  late int _reportSignature;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _reportSignature = _signatureOf(app);
    _entries = app.loadLeaderboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = context.watch<AppProvider>();
    final signature = _signatureOf(app);
    if (signature == _reportSignature) return;
    _reportSignature = signature;
    _entries = app.loadLeaderboard();
  }

  Future<void> _refresh() async {
    final app = context.read<AppProvider>();
    await app.syncReports();
    if (!mounted) return;
    final refreshed = app.loadLeaderboard();
    setState(() => _entries = refreshed);
    await refreshed;
  }

  int _signatureOf(AppProvider app) => Object.hashAll(
    app.reports.map(
      (report) => Object.hash(
        report.id,
        report.remoteId,
        report.reporterEmail,
        report.votes,
        report.updatedAt,
        report.isDeleted,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final currentEmail = context.watch<AppProvider>().email.toLowerCase();
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navy, Color(0xFF253B80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 54),
                SizedBox(height: 4),
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'All reporters ranked by community contribution',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: _entries,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _LeaderboardMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'Unable to load ranking',
                    message:
                        'Pull down or tap retry when the connection returns.',
                    onRetry: _refresh,
                  );
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return _LeaderboardMessage(
                    icon: Icons.leaderboard_outlined,
                    title: 'No registered users yet',
                    message: 'Registered users will appear here automatically.',
                    onRetry: _refresh,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isCurrentUser = entry.email == currentEmail;
                      return Card(
                        color: isCurrentUser
                            ? primary.withValues(alpha: .06)
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _rankColor(index),
                              foregroundColor: index < 3 ? navy : Colors.white,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    entry.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 7),
                                  const Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text('You'),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              '${entry.reportCount} reports · '
                              '${entry.verificationCount} verifications',
                            ),
                            trailing: Text(
                              '${entry.points}\npoints',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int index) => switch (index) {
    0 => const Color(0xFFFFD54F),
    1 => const Color(0xFFCFD8DC),
    2 => const Color(0xFFD7A86E),
    _ => primary,
  };
}

class _LeaderboardMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function() onRetry;

  const _LeaderboardMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(32),
    children: [
      const SizedBox(height: 70),
      Icon(icon, size: 58, color: Colors.blueGrey),
      const SizedBox(height: 12),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.blueGrey),
      ),
      const SizedBox(height: 16),
      Center(
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ),
    ],
  );
}
