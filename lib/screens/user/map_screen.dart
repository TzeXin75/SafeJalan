import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import 'report_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().reports;
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
            child: const Row(
              children: [
                SafeMark(size: 42),
                SizedBox(width: 11),
                Column(
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
                Spacer(),
                CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0x1FFFFFFF),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
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
