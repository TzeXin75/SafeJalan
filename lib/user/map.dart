import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/user/notifications.dart';
import 'package:safejalan/user/report_detail.dart';
import 'package:safejalan/user/connectivity_detail.dart';

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
  bool _showConnectivity = false;

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
    final app = context.watch<AppProvider>();
    final reports = app.userVisibleReports;
    final connectivityReports = app.connectivityReports
        .where(
          (report) =>
      !report.isDeleted &&
          const {'pending', 'reviewed'}.contains(
            report.status.toLowerCase(),
          ) &&
          report.latitude.abs() <= 90 &&
          report.longitude.abs() <= 180 &&
          (report.latitude != 0 || report.longitude != 0),
    )
        .toList();
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
            height: 390,
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
                        if (!_showConnectivity)
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
                        if (_showConnectivity)
                          ...connectivityReports.map(
                                (report) => Marker(
                              point: LatLng(
                                report.latitude,
                                report.longitude,
                              ),
                              width: 46,
                              height: 46,
                              child: GestureDetector(
                                onTap: () =>
                                    _openConnectivity(context, report),
                                child: Icon(
                                  Icons.location_on,
                                  color: _connectivityColor(report.issueType),
                                  size: 44,
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
                Positioned(
                  top: 76,
                  left: 12,
                  right: 12,
                  child: _MapModeSelector(
                    showConnectivity: _showConnectivity,
                    onChanged: (value) =>
                        setState(() => _showConnectivity = value),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _showConnectivity
                      ? const _ConnectivityLegend()
                      : const _SeverityLegend(),
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
                      Text(
                        _showConnectivity
                            ? 'Connectivity Issues'
                            : 'Active Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_showConnectivity ? connectivityReports.length : reports.length} issues',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _showConnectivity
                          ? connectivityReports.length
                          : reports.length,
                      itemBuilder: (context, index) {
                        if (_showConnectivity) {
                          final report = connectivityReports[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () =>
                                  _openConnectivity(context, report),
                              leading: CircleAvatar(
                                backgroundColor:
                                _connectivityColor(
                                  report.issueType,
                                ).withValues(alpha: .12),
                                child: Icon(
                                  Icons.wifi_off_rounded,
                                  color: _connectivityColor(report.issueType),
                                ),
                              ),
                              title: Text(report.area),
                              subtitle: Text(
                                '${report.carrier} · ${report.issueType}',
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                              ),
                            ),
                          );
                        }
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

  void _openConnectivity(BuildContext context, dynamic report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectivityDetailScreen(report: report),
      ),
    );
  }
}

Color _connectivityColor(String issueType) =>
    issueType.toLowerCase() == 'no wi-fi'
        ? const Color(0xFF0EA5E9)
        : const Color(0xFF8B5CF6);

class _MapModeSelector extends StatelessWidget {
  const _MapModeSelector({
    required this.showConnectivity,
    required this.onChanged,
  });

  final bool showConnectivity;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .96),
    elevation: 4,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _MapModeButton(
              icon: Icons.add_road_rounded,
              label: 'Road Reports',
              selected: !showConnectivity,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _MapModeButton(
              icon: Icons.wifi_off_rounded,
              label: 'Connectivity',
              selected: showConnectivity,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MapModeButton extends StatelessWidget {
  const _MapModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : navy,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : navy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ),
  );
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

class _ConnectivityLegend extends StatelessWidget {
  const _ConnectivityLegend();

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
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Connectivity issue',
          style: TextStyle(
            color: navy,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConnectivityLegendItem('Poor Signal'),
            SizedBox(width: 10),
            _ConnectivityLegendItem('No Wi-Fi'),
          ],
        ),
      ],
    ),
  );
}

class _ConnectivityLegendItem extends StatelessWidget {
  const _ConnectivityLegendItem(this.issueType);

  final String issueType;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: _connectivityColor(issueType),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        issueType,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
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
