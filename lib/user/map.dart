import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';
import 'package:safejalan_native/user/announcements.dart';
import 'package:safejalan_native/user/report_detail.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().userVisibleReports;
    final announcementCount = context
        .watch<AppProvider>()
        .activeAnnouncements
        .length;
    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navy, Color(0xFF174A76)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                const SafeMark(size: 42),
                const SizedBox(width: 11),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SafeJalan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Live road safety map',
                      style: TextStyle(color: Color(0xFFB8CBE0), fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Safety announcements',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0x1FFFFFFF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    if (announcementCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.red,
                          child: Text(
                            announcementCount > 9 ? '9+' : '$announcementCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 360,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(3.139, 101.6869),
                initialZoom: 11.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safejalan.flutter',
                ),
                MarkerLayer(
                  markers: reports
                      .map(
                        (report) => Marker(
                          point: LatLng(report.latitude, report.longitude),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => _openReport(context, report),
                            child: Icon(
                              Icons.location_on,
                              color: severityColor(report.severity),
                              size: 42,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Nearby Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${reports.length} issues',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return ReportTile(
                          report: report,
                          onTap: () => _openReport(context, report),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openReport(BuildContext context, dynamic report) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
    );
  }
}
