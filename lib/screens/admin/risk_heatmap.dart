import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

class RiskHeatmapScreen extends StatelessWidget {
  const RiskHeatmapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().adminVisibleReports;
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Risk Heatmap',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(3.139, 101.6869),
                initialZoom: 11,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safejalan.flutter',
                ),
                CircleLayer(
                  circles: reports
                      .map(
                        (r) => CircleMarker(
                          point: LatLng(r.latitude, r.longitude),
                          radius: r.severity == 'Critical' ? 55 : 38,
                          color: severityColor(
                            r.severity,
                          ).withValues(alpha: .32),
                          borderColor: severityColor(r.severity),
                          borderStrokeWidth: 2,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              children: [
                'Critical',
                'High',
                'Medium',
                'Low',
              ].map((v) => LabelBadge(v, severityColor(v))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
