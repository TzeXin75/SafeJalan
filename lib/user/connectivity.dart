import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:provider/provider.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/user/connectivity_detail.dart';

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  final _key = GlobalKey<FormState>();
  final _carrier = TextEditingController();
  final _area = TextEditingController();
  final _notes = TextEditingController();
  String _type = 'Poor Signal';
  bool _saving = false;
  bool _locating = false;
  bool _checkingArea = false;
  bool _locationConfirmed = false;
  bool _permissionGranted = false;
  bool _gpsEnabled = false;
  String? _locationMessage;
  double? _latitude;
  double? _longitude;
  int _locationRun = 0;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationRun++;
    _carrier.dispose();
    _area.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<bool> _isPermissionGranted() async {
    return handler.Permission.locationWhenInUse.isGranted;
  }

  Future<bool> _isGpsEnabled() async {
    return handler.Permission.location.serviceStatus.isEnabled;
  }

  Future<void> _checkLocationStatus() async {
    final permissionGranted = await _isPermissionGranted();
    final gpsEnabled = await _isGpsEnabled();
    if (!mounted) return;
    setState(() {
      _permissionGranted = permissionGranted;
      _gpsEnabled = gpsEnabled;
    });
  }

  Future<bool> _requestEnableGps() async {
    if (_gpsEnabled || await _isGpsEnabled()) {
      if (mounted) setState(() => _gpsEnabled = true);
      return true;
    }

    final gpsEnabled = await _location.requestService();
    if (mounted) setState(() => _gpsEnabled = gpsEnabled);
    return gpsEnabled;
  }

  Future<bool> _requestLocationPermission() async {
    final status = await handler.Permission.locationWhenInUse.request();
    final permissionGranted = status == handler.PermissionStatus.granted;
    if (mounted) {
      setState(() => _permissionGranted = permissionGranted);
    }
    return permissionGranted;
  }

  Future<void> _detectLocation() async {
    if (_locating) {
      setState(() {
        _locationRun++;
        _locating = false;
        _locationMessage =
        'GPS detection cancelled. You can enter the area manually.';
      });
      return;
    }

    final locationRun = ++_locationRun;
    setState(() {
      _locating = true;
      _locationMessage = 'Detecting your current location...';
    });

    try {
      if (!_gpsEnabled &&
          !(await _isGpsEnabled()) &&
          !(await _requestEnableGps())) {
        if (mounted && locationRun == _locationRun) {
          setState(() => _locationMessage = 'GPS service was not enabled.');
        }
        return;
      }

      if (!_permissionGranted &&
          !(await _isPermissionGranted()) &&
          !(await _requestLocationPermission())) {
        if (mounted && locationRun == _locationRun) {
          setState(
                () => _locationMessage = 'Location permission was not granted.',
          );
        }
        return;
      }

      if (!mounted || locationRun != _locationRun) return;

      final data = await _location.getLocation().timeout(
        const Duration(seconds: 15),
      );
      if (!mounted || locationRun != _locationRun) return;

      _latitude = data.latitude;
      _longitude = data.longitude;

      if (_latitude == null || _longitude == null) {
        setState(() => _locationMessage = 'GPS did not return coordinates.');
        return;
      }

      await _updateAreaName(_latitude!, _longitude!);
      if (mounted && locationRun == _locationRun) {
        setState(() {
          _locationConfirmed = true;
          _locationMessage = 'Current location detected and confirmed.';
        });
      }
    } on TimeoutException {
      if (mounted && locationRun == _locationRun) {
        setState(
              () => _locationMessage =
          'GPS timed out. Move near an open area and try again.',
        );
      }
    } catch (_) {
      if (mounted && locationRun == _locationRun) {
        setState(
              () => _locationMessage =
          'Unable to detect GPS. Retry or enter the area manually.',
        );
      }
    } finally {
      if (mounted && locationRun == _locationRun) {
        setState(() => _locating = false);
      }
    }
  }

  Future<void> _updateAreaName(double latitude, double longitude) async {
    try {
      final places = await geo.placemarkFromCoordinates(latitude, longitude);
      if (!mounted) return;
      if (places.isEmpty) {
        _area.text =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
        return;
      }

      final place = places.first;
      final parts =
      <String?>[
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
      ]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .toSet()
          .toList();

      if (parts.isNotEmpty) {
        _area.text = parts.join(', ');
      } else {
        _area.text =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
      }
    } catch (_) {
      if (!mounted) return;
      _area.text =
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }
  }

  Future<void> _chooseLocationOnMap() async {
    var selected = LatLng(_latitude ?? 3.139, _longitude ?? 101.6869);

    final result = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust connectivity location',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Tap anywhere on the map to move the pin',
                            style: TextStyle(color: mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: selected,
                    initialZoom: 16,
                    onTap: (_, point) {
                      setSheetState(() => selected = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.safejalan.flutter',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selected,
                          width: 54,
                          height: 54,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, selected),
                    icon: const Icon(Icons.check),
                    label: const Text('Use this location'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _locating = true;
      _locationMessage = 'Converting the selected location to an address...';
    });

    await _updateAreaName(result.latitude, result.longitude);
    if (!mounted) return;
    setState(() {
      _locating = false;
      _locationConfirmed = true;
      _locationMessage = 'Map location selected.';
    });
  }

  String _readableAddress(geo.Placemark place) {
    final parts =
    <String?>[
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toSet()
        .toList();
    return parts.join(', ');
  }

  Future<bool> _confirmTypedArea() async {
    final typedArea = _area.text.trim();
    if (typedArea.isEmpty) {
      setState(() => _locationMessage = 'Enter an affected area first.');
      return false;
    }
    setState(() {
      _checkingArea = true;
      _locationMessage = 'Checking the entered address...';
    });

    try {
      final query = typedArea.toLowerCase().contains('malaysia')
          ? typedArea
          : '$typedArea, Malaysia';
      final locations = await geo.locationFromAddress(query);
      if (!mounted) return false;
      if (locations.isEmpty) {
        setState(() {
          _locationMessage =
          'Address not found. Enter a more specific place or use the map.';
        });
        return false;
      }

      final location = locations.first;
      final places = await geo.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (!mounted) return false;
      final matchedAddress = places.isEmpty
          ? typedArea
          : _readableAddress(places.first);
      final displayAddress = matchedAddress.isEmpty
          ? typedArea
          : matchedAddress;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.location_on_rounded, color: primary, size: 34),
          title: const Text('Confirm affected area'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('We found this address:'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayAddress,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Is this the correct affected area?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Edit address'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) {
        setState(() => _locationMessage = 'Please edit or adjust the area.');
        return false;
      }

      setState(() {
        _area.text = displayAddress;
        _latitude = location.latitude;
        _longitude = location.longitude;
        _locationConfirmed = true;
        _locationMessage = 'Address confirmed.';
      });
      return true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationMessage =
          'Unable to check this address. Check the internet or use the map.';
        });
      }
      return false;
    } finally {
      if (mounted) setState(() => _checkingArea = false);
    }
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate() || _saving) return;
    if (!_locationConfirmed && !await _confirmTypedArea()) return;
    if (!mounted) return;
    setState(() => _saving = true);
    await context.read<AppProvider>().addConnectivityReport(
      issueType: _type,
      carrier: _carrier.text.trim(),
      notes: _notes.text.trim(),
      area: _area.text.trim(),
    );
    if (!mounted) return;
    _carrier.clear();
    _area.clear();
    _notes.clear();
    setState(() {
      _saving = false;
      _latitude = null;
      _longitude = null;
      _locationConfirmed = false;
      _locationMessage = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Connectivity report saved.')));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final items = app.connectivityReports
        .where(
          (report) =>
      report.reporterEmail.toLowerCase() == app.email.toLowerCase(),
    )
        .toList();
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: navy,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connectivity Issues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Saved to SQLite and synced when online',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _key,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: ['Poor Signal', 'No Wi-Fi']
                        .map(
                          (value) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ChoiceChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            selected: _type == value,
                            onSelected: (_) =>
                                setState(() => _type = value),
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _carrier,
                    maxLength: 50,
                    decoration: safeInput(
                      'Network carrier',
                      icon: Icons.sim_card_outlined,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the carrier'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _area,
                    maxLength: 150,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                    safeInput(
                      'Affected area',
                      icon: Icons.location_on_outlined,
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: 'Search and confirm address',
                        onPressed: _checkingArea
                            ? null
                            : () => _confirmTypedArea(),
                        icon: _checkingArea
                            ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                            : const Icon(Icons.search_rounded),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the affected area'
                        : null,
                    onChanged: (_) {
                      if (_locationConfirmed ||
                          _latitude != null ||
                          _longitude != null) {
                        setState(() {
                          _locationConfirmed = false;
                          _latitude = null;
                          _longitude = null;
                          _locationMessage =
                          'Address changed. It will be checked before submission.';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _detectLocation,
                          icon: _locating
                              ? const Icon(Icons.close, size: 19)
                              : const Icon(Icons.my_location, size: 19),
                          label: Text(_locating ? 'Cancel GPS' : 'Detect GPS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _locating ? null : _chooseLocationOnMap,
                          icon: const Icon(Icons.map_outlined, size: 19),
                          label: const Text('Adjust Map'),
                        ),
                      ),
                    ],
                  ),
                  if (_locationMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        _locationMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: mutedText, fontSize: 11),
                      ),
                    ),
                  if (_latitude != null && _longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        '${_latitude!.toStringAsFixed(5)}, '
                            '${_longitude!.toStringAsFixed(5)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: mutedText, fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: safeInput('Additional notes'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a short note'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving || _checkingArea ? null : _submit,
                    child: Text(
                      _checkingArea
                          ? 'Checking address...'
                          : _saving
                          ? 'Saving...'
                          : 'Report Gap',
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'My Connectivity Reports',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('No connectivity reports yet.'),
                      ),
                    ),
                  ...items.map(
                        (item) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConnectivityDetailScreen(report: item),
                          ),
                        ),
                        leading: const CircleAvatar(
                          child: Icon(Icons.wifi_off),
                        ),
                        title: Text(item.area),
                        subtitle: Text(
                          '${item.carrier} · ${item.issueType}\n${item.notes}',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            LabelBadge(item.status, statusColor(item.status)),
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
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
}
