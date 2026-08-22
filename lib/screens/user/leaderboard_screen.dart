import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    // The local prototype has one account. A user enters the leaderboard
    // automatically after submitting the first report.
    final users = app.myReports.isEmpty
        ? <(String, int, int)>[]
        : [(app.userName, app.points, app.myReports.length)];
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: navy,
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            child: const Column(
              children: [
                Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 54),
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Top reporters this month',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.leaderboard_outlined,
                            size: 58,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No ranking yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Submit your first road report to join the leaderboard.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFD700),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.$1,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${user.$3} reports'),
                          trailing: Text(
                            '${user.$2}\npoints',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
