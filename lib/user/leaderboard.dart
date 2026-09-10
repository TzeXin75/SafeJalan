import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/models/leaderboard_entry.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';

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
    await app.syncConnectivityReports();
    if (!mounted) return;
    final refreshed = app.loadLeaderboard();
    setState(() => _entries = refreshed);
    await refreshed;
  }

  int _signatureOf(AppProvider app) => Object.hash(
    app.leaderboardRevision,
    Object.hashAll(
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
    ),
    Object.hashAll(
      app.connectivityReports.map(
            (report) => Object.hash(
          report.id,
          report.remoteId,
          report.reporterEmail,
          report.updatedAt,
          report.isDeleted,
        ),
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
                final rawEntries = snapshot.data ?? [];
                final rankedEntries = rawEntries
                    .where((entry) => entry.points >= 1)
                    .toList();
                final topEntries = rankedEntries.take(10).toList();

                LeaderboardEntry? myEntry;
                for (final entry in rawEntries) {
                  if (entry.email == currentEmail) {
                    myEntry = entry;
                    break;
                  }
                }

                final currentRankIndex = rankedEntries.indexWhere(
                      (entry) => entry.email == currentEmail,
                );
                final currentRank = currentRankIndex < 0
                    ? null
                    : currentRankIndex + 1;
                final currentIsInTopTen =
                    currentRank != null && currentRank <= 10;

                if (rawEntries.isEmpty) {
                  return _LeaderboardMessage(
                    icon: Icons.leaderboard_outlined,
                    title: 'No registered users yet',
                    message: 'Registered users will appear here automatically.',
                    onRetry: _refresh,
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: topEntries.isEmpty
                          ? _LeaderboardMessage(
                        icon: Icons.leaderboard_outlined,
                        title: 'No ranked reporters yet',
                        message:
                        'Submit a road or connectivity report to enter the leaderboard.',
                        onRetry: _refresh,
                      )
                          : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: topEntries.length,
                          separatorBuilder: (_, _) =>
                          const SizedBox(height: 9),
                          itemBuilder: (context, index) {
                            final entry = topEntries[index];
                            final isCurrent = entry.email == currentEmail;
                            return Card(
                              color: isCurrent
                                  ? primary.withValues(alpha: .07)
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _rankColor(index),
                                    foregroundColor: index < 3
                                        ? navy
                                        : Colors.white,
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
                                      if (isCurrent) ...[
                                        const SizedBox(width: 7),
                                        const Chip(
                                          visualDensity:
                                          VisualDensity.compact,
                                          label: Text('You'),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${entry.reportCount} road reports · '
                                        '${entry.connectivityCount} connectivity · '
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
                      ),
                    ),
                    if (myEntry != null && !currentIsInTopTen)
                      _MyStandingCard(entry: myEntry, rank: currentRank),
                  ],
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

class _MyStandingCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int? rank;

  const _MyStandingCard({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey.shade300)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .06),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rank == null ? 'Your standing · Unranked' : 'Your standing · #$rank',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: primary.withValues(alpha: .06),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.person, size: 20),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('You'),
                  ),
                ],
              ),
              subtitle: Text(
                '${entry.reportCount} road reports · '
                    '${entry.connectivityCount} connectivity · '
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
        ),
      ],
    ),
  );
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