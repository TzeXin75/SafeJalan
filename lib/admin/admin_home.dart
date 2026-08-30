import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';
import 'package:safejalan_native/entry.dart';
import 'package:safejalan_native/admin/dashboard.dart';
import 'package:safejalan_native/admin/admin_tools.dart';
import 'package:safejalan_native/admin/manage_connectivity.dart';
import 'package:safejalan_native/admin/manage_reports.dart';
import 'package:safejalan_native/admin/manage_users.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;
  final _pages = const [
    DashboardScreen(),
    ManageUsersScreen(),
    ManageReportsScreen(),
    ManageConnectivityScreen(),
    AdminToolsScreen(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 68,
      titleSpacing: 16,
      title: const Row(
        children: [
          SafeMark(size: 42),
          SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SafeJalan Admin'),
              Text(
                'Operations centre',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<AppProvider>().logout();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const EntryScreen()),
              (_) => false,
            );
          },
        ),
      ],
    ),
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_off_outlined),
            selectedIcon: Icon(Icons.wifi_off_rounded),
            label: 'Network',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    ),
  );
}
