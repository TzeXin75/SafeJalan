import 'package:flutter/material.dart';
import 'package:safejalan_native/user/map.dart';
import 'package:safejalan_native/user/report_form.dart';
import 'package:safejalan_native/user/connectivity.dart';
import 'package:safejalan_native/user/leaderboard.dart';
import 'package:safejalan_native/user/profile.dart';
import 'package:safejalan_native/widgets/common.dart';

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
