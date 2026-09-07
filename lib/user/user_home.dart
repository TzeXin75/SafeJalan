import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan_native/entry.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/user/map.dart';
import 'package:safejalan_native/user/report_form.dart';
import 'package:safejalan_native/user/connectivity.dart';
import 'package:safejalan_native/user/leaderboard.dart';
import 'package:safejalan_native/user/profile.dart';
import 'package:safejalan_native/user/announcements.dart';
import 'package:safejalan_native/widgets/common.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key, this.showWelcome = false});

  final bool showWelcome;
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _index = 0;
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      const MapScreen(),
      ReportFormScreen(onSaved: () => setState(() => _index = 0)),
      const ConnectivityScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];
    if (widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcome());
    }
  }

  Future<void> _showWelcome() async {
    if (!mounted) return;
    final app = context.read<AppProvider>();
    final count = app.unreadAnnouncements.length;
    final openAnnouncements = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.waving_hand_rounded,
          color: safeOrange,
          size: 36,
        ),
        title: Text('Welcome, ${app.userName}!'),
        content: Text(
          count == 0
              ? 'Welcome back to SafeJalan. Stay alert and travel safely.'
              : 'Welcome back! You have $count active safety ${count == 1 ? 'announcement' : 'announcements'} to read.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue'),
          ),
          if (count > 0)
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('View announcements'),
            ),
        ],
      ),
    );
    if (openAnnouncements == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AppProvider>().isLoggedIn) {
      return const EntryScreen();
    }
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A0C2745),
              blurRadius: 24,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          indicatorColor: safeOrange.withValues(alpha: .18),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.report_outlined),
              selectedIcon: Icon(Icons.report),
              label: 'Report',
            ),
            NavigationDestination(icon: Icon(Icons.wifi), label: 'Network'),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events),
              label: 'Rank',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
