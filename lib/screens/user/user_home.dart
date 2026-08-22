import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'report_form_screen.dart';
import 'connectivity_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import '../../widgets/common.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});
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
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      indicatorColor: primary.withValues(alpha: .15),
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
  );
}
