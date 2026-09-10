import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/user/notifications.dart';
import 'package:safejalan/user/report_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _searchedPoint;
  bool _searching = false;

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;

    FocusScope.of(context).unfocus();
    setState(() => _searching = true);

    try {
      final searchQuery = query.toLowerCase().contains('malaysia')
          ? query
          : '$query, Malaysia';
      final results = await locationFromAddress(searchQuery);

      if (!mounted) return;
      if (results.isEmpty) {
        _showMessage('Location not found. Try a more specific address.');
        return;
      }

      final point = LatLng(results.first.latitude, results.first.longitude);
      setState(() => _searchedPoint = point);
      _mapController.move(point, 15.5);
      _showMessage('Map moved to $query');
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to find this location. Check your internet.');
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchedPoint = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppProvider>().userVisibleReports;
    final app = context.watch<AppProvider>();
    final notificationCount =
        app.unreadAnnouncements.length + app.unreadUserNotifications.length;
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
                      tooltip: 'Notifications and announcements',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0x1FFFFFFF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserNotificationsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.red,
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
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
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(3.139, 101.6869),
                    initialZoom: 11.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.safejalan.flutter',
                    ),
                    MarkerLayer(
                      markers: [
                        ...reports.map(
                              (report) => Marker(
                            point: LatLng(
                              report.latitude,
                              report.longitude,
                            ),
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
                        ),
                        if (_searchedPoint != null)
                          Marker(
                            point: _searchedPoint!,
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.place_rounded,
                              color: Colors.blue,
                              size: 46,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _LocationSearchBar(
                    controller: _searchController,
                    searching: _searching,
                    onSearch: _searchLocation,
                    onClear: _clearSearch,
                  ),
                ),
                const Positioned(
                  left: 12,
                  bottom: 12,
                  child: _SeverityLegend(),
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
                        'Active Reports',
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

class _LocationSearchBar extends StatelessWidget {
  const _LocationSearchBar({
    required this.controller,
    required this.searching,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool searching;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(14),
    child: TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: 'Search area',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: searching
            ? const Padding(
          padding: EdgeInsets.all(13),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
            : ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? IconButton(
            tooltip: 'Search',
            onPressed: onSearch,
            icon: const Icon(Icons.arrow_forward_rounded),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Clear',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
              IconButton(
                tooltip: 'Search',
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

class _SeverityLegend extends StatelessWidget {
  const _SeverityLegend();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: softBorder),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Severity',
          style: TextStyle(
            color: navy,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 5,
          children: const [
            _LegendItem('Low', 'Low'),
            _LegendItem('Medium', 'Medium'),
            _LegendItem('High', 'High'),
            _LegendItem('Critical', 'Critical'),
          ],
        ),
      ],
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.label, this.severity);

  final String label;
  final String severity;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: severityColor(severity),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
