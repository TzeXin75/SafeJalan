import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:provider/provider.dart';
import 'package:safejalan/models/report.dart';
import 'package:safejalan/models/report_categories.dart';
import 'package:safejalan/providers/app_provider.dart';
import 'package:safejalan/widgets/common.dart';
import 'package:safejalan/user/report_detail.dart';

enum _DuplicateAction { viewExisting, submitAnyway }

class ReportFormScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const ReportFormScreen({super.key, required this.onSaved});
  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _description = TextEditingController(),
      _locationName = TextEditingController(text: 'Jalan Ampang, KL');
  String _category = '', _severity = 'High';
  File? _image;
  double _lat = 3.1585, _lng = 101.7123;
  bool _locating = false;
  bool _analysingImage = false;
  bool _permissionGranted = false;
  bool _gpsEnabled = false;
  bool _checkingDuplicates = false;
  String? _aiSuggestion;
  List<ReportCategorySuggestion> _aiCandidates = const [];
  List<ReportImageLabel> _detectedImageLabels = const [];
  Timer? _textAnalysisDebounce;
  bool _categoryWasManuallySelected = false;
  String? _imageError;
  String? _locationMessage;
  int _analysisRun = 0;
  int _locationRun = 0;
  final Location _location = Location();

  static final _letterOrNumberPattern = RegExp(
    r'[A-Za-z0-9\u00C0-\u024F\u4E00-\u9FFF]',
  );

  static bool _containsEmoji(String text) => text.runes.any(
    (codePoint) =>
        (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF) ||
        (codePoint >= 0x1F300 && codePoint <= 0x1FAFF) ||
        (codePoint >= 0x2600 && codePoint <= 0x27BF) ||
        codePoint == 0xFE0F,
  );

  @override
  void initState() {
    super.initState();
    _title.addListener(_scheduleTextAwareCategoryAnalysis);
    _description.addListener(_scheduleTextAwareCategoryAnalysis);
    checkStatus();
  }

  @override
  void dispose() {
    _analysisRun++;
    _locationRun++;
    _textAnalysisDebounce?.cancel();
    _title.dispose();
    _description.dispose();
    _locationName.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      if (!_categoryWasManuallySelected) _category = '';
      _imageError = null;
      _analysingImage = true;
      _aiSuggestion = null;
      _aiCandidates = const [];
      _detectedImageLabels = const [];
    });
    await _detectCategory(picked.path);
  }

  Future<void> _detectCategory(String imagePath) async {
    final analysisRun = ++_analysisRun;
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: .45),
    );
    Future<void>.delayed(const Duration(seconds: 15), () {
      if (!mounted || analysisRun != _analysisRun || !_analysingImage) return;
      setState(() {
        _analysisRun++;
        _analysingImage = false;
        _aiCandidates = const [];
        _detectedImageLabels = const [];
        _aiSuggestion =
            'AI is taking too long. Detection stopped; select a category manually.';
      });
    });
    try {
      final labels = await labeler.processImage(
        InputImage.fromFilePath(imagePath),
      );
      if (!mounted || analysisRun != _analysisRun) return;
      setState(() {
        _analysingImage = false;
        _detectedImageLabels = labels
            .map((label) => (text: label.label, confidence: label.confidence))
            .toList(growable: false);
      });
      _updateCategorySuggestion();
    } catch (_) {
      if (mounted && analysisRun == _analysisRun) {
        setState(() {
          _analysingImage = false;
          _aiCandidates = const [];
          _detectedImageLabels = const [];
          _aiSuggestion = 'AI analysis unavailable. Select manually.';
        });
      }
    } finally {
      await labeler.close();
    }
  }

  void _scheduleTextAwareCategoryAnalysis() {
    if (_image == null || _analysingImage) return;
    _textAnalysisDebounce?.cancel();
    _textAnalysisDebounce = Timer(
      const Duration(milliseconds: 350),
      _updateCategorySuggestion,
    );
  }

  void _updateCategorySuggestion() {
    if (!mounted || _image == null || _analysingImage) return;
    final titleText = _title.text.trim();
    final descriptionText = _description.text.trim();
    final hasTextContext = titleText.isNotEmpty || descriptionText.isNotEmpty;
    final analysis = analyseReportCategories(
      _detectedImageLabels,
      titleText: titleText,
      descriptionText: descriptionText,
    );
    setState(() {
      if (_categoryWasManuallySelected) {
        _aiCandidates = const [];
        if (analysis.suggestions.isNotEmpty &&
            analysis.suggestions.first.category != _category) {
          _aiSuggestion =
              'AI suggests ${analysis.suggestions.first.category}; your selected category remains $_category';
        }
        return;
      }

      _aiCandidates = analysis.suggestions;
      if (analysis.suggestions.isEmpty) {
        _aiSuggestion = !hasTextContext
            ? 'Photo analysed — add a short title for a more accurate category suggestion'
            : 'Add more issue details or select a category manually';
        return;
      }

      // The photo produces the initial candidates. Final automatic selection
      // waits for at least one piece of text so the title or description can
      // confirm or correct the visual result.
      if (hasTextContext && analysis.canAutoSelect) {
        final suggestion = analysis.suggestions.first;
        _category = suggestion.category;
        _aiCandidates = const [];
        _aiSuggestion =
            'AI suggested ${suggestion.category} · ${(suggestion.confidence * 100).round()}%';
        return;
      }

      _aiSuggestion = !hasTextContext
          ? 'Photo suggests possible categories — add a title or choose below'
          : 'Choose the closest suggested category below';
    });
  }

  void _cancelImageAnalysis() {
    if (!_analysingImage) return;
    setState(() {
      _analysisRun++;
      _analysingImage = false;
      _aiCandidates = const [];
      _detectedImageLabels = const [];
      _aiSuggestion = 'AI detection cancelled. Select a category manually.';
    });
  }

  Future<bool> isPermissionGranted() async {
    return await handler.Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isGpsEnabled() async {
    return await handler.Permission.location.serviceStatus.isEnabled;
  }

  void checkStatus() async {
    final permissionGranted = await isPermissionGranted();
    final gpsEnabled = await isGpsEnabled();
    if (!mounted) return;
    setState(() {
      _permissionGranted = permissionGranted;
      _gpsEnabled = gpsEnabled;
    });
  }

  Future<bool> requestEnableGps() async {
    if (_gpsEnabled || await isGpsEnabled()) {
      if (mounted) setState(() => _gpsEnabled = true);
      return true;
    }
    final isGpsActive = await _location.requestService();
    if (mounted) setState(() => _gpsEnabled = isGpsActive);
    return isGpsActive;
  }

  Future<bool> requestLocationPermission() async {
    final permissionStatus = await handler.Permission.locationWhenInUse
        .request();
    final permissionGranted =
        permissionStatus == handler.PermissionStatus.granted;
    if (mounted) setState(() => _permissionGranted = permissionGranted);
    return permissionGranted;
  }

  Future<void> _getLocation() async {
    if (_locating) {
      setState(() {
        _locationRun++;
        _locating = false;
        _locationMessage =
            'GPS detection cancelled. You can retry or adjust the map.';
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
          !(await isGpsEnabled()) &&
          !(await requestEnableGps())) {
        if (mounted && locationRun == _locationRun) {
          setState(() => _locationMessage = 'GPS service was not enabled.');
        }
        return;
      }
      if (!_permissionGranted &&
          !(await isPermissionGranted()) &&
          !(await requestLocationPermission())) {
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
      _lat = data.latitude ?? _lat;
      _lng = data.longitude ?? _lng;
      await _updateLocationName();
      if (mounted && locationRun == _locationRun) {
        setState(() => _locationMessage = 'Current location detected.');
      }
    } on TimeoutException {
      if (mounted && locationRun == _locationRun) {
        setState(
          () => _locationMessage =
              'GPS timed out. Move near an open area, retry, or adjust the map.',
        );
      }
    } catch (_) {
      if (mounted && locationRun == _locationRun) {
        setState(
          () => _locationMessage =
              'Unable to detect GPS. Retry or choose the location on the map.',
        );
      }
    } finally {
      if (mounted && locationRun == _locationRun) {
        setState(() => _locating = false);
      }
    }
  }

  Future<void> _updateLocationName() async {
    try {
      final places = await geo.placemarkFromCoordinates(_lat, _lng);
      if (places.isEmpty) return;
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
      if (parts.isNotEmpty) _locationName.text = parts.join(', ');
    } catch (_) {}
  }

  Future<void> _chooseLocationOnMap() async {
    var selected = LatLng(_lat, _lng);
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
                            'Adjust report location',
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
      _lat = result.latitude;
      _lng = result.longitude;
      _locating = true;
    });
    await _updateLocationName();
    if (mounted) setState(() => _locating = false);
  }

  Future<String?> _saveImage() async {
    if (_image == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _image!.copy(path);
    return path;
  }

  Future<void> _submit() async {
    String? imageError;
    if (_image == null) {
      imageError = 'Please add a report photo';
    } else if (!await _image!.exists() || await _image!.length() == 0) {
      imageError = 'The selected image is invalid. Please choose it again';
    } else if (await _image!.length() > 10 * 1024 * 1024) {
      imageError = 'The image must be smaller than 10 MB';
    }
    if (!mounted) return;
    setState(() => _imageError = imageError);
    final formIsValid = _key.currentState!.validate();
    if (!formIsValid || _imageError != null) return;
    setState(() => _checkingDuplicates = true);
    final app = context.read<AppProvider>();
    final duplicates = app.findDuplicateReports(
      latitude: _lat,
      longitude: _lng,
      category: _category,
    );
    if (duplicates.isNotEmpty) {
      final existing = duplicates.first;
      final distance = app.distanceToReport(
        existing,
        latitude: _lat,
        longitude: _lng,
      );
      final action = await _showDuplicateWarning(existing, distance);
      if (!mounted) return;
      if (action == _DuplicateAction.viewExisting) {
        setState(() => _checkingDuplicates = false);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(report: existing),
          ),
        );
        return;
      }
      if (action != _DuplicateAction.submitAnyway) {
        setState(() => _checkingDuplicates = false);
        return;
      }
    }
    final imagePath = await _saveImage();
    final report = RoadReport(
      title: _title.text.trim(),
      category: _category,
      severity: _severity,
      description: _description.text.trim(),
      locationName: _locationName.text.trim(),
      latitude: _lat,
      longitude: _lng,
      imagePath: imagePath,
      createdOn: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    if (!mounted) return;
    await app.addReport(report);
    _key.currentState!.reset();
    _textAnalysisDebounce?.cancel();
    _title.clear();
    _description.clear();
    setState(() {
      _image = null;
      _imageError = null;
      _aiSuggestion = null;
      _aiCandidates = const [];
      _detectedImageLabels = const [];
      _category = '';
      _categoryWasManuallySelected = false;
      _analysingImage = false;
      _checkingDuplicates = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Road report saved to SQLite.')),
      );
    }
    widget.onSaved();
  }

  Future<_DuplicateAction?> _showDuplicateWarning(
    RoadReport existing,
    double distance,
  ) => showModalBottomSheet<_DuplicateAction>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE7ECFF),
                  child: Icon(Icons.copy_all_rounded, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Similar report found',
                        style: TextStyle(
                          color: navy,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'A ${existing.category.toLowerCase()} was reported ${distance.round()} m from this location.',
                        style: const TextStyle(color: mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReportTile(report: existing, onTap: () {}),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, _DuplicateAction.viewExisting),
                    child: const Text('View existing'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, _DuplicateAction.submitAnyway),
                    child: const Text('Submit anyway'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  String? _validateReportText(
    String? value, {
    required int minimum,
    required String fieldName,
  }) {
    final text = value?.trim() ?? '';
    if (text.length < minimum) {
      return '$fieldName must contain at least $minimum characters';
    }
    if (_containsEmoji(text)) {
      return '$fieldName cannot contain emoji';
    }
    if (!_letterOrNumberPattern.hasMatch(text)) {
      return '$fieldName must include letters or numbers';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Container(
          color: navy,
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: const Text(
            'Report',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Form(
            key: _key,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _image == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: primary, size: 38),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                if (_imageError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _imageError!,
                    style: const TextStyle(
                      color: Color(0xFFD92D20),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (_analysingImage || _aiSuggestion != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primary.withValues(alpha: .12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_analysingImage)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(
                                Icons.auto_awesome,
                                color: primary,
                                size: 19,
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _analysingImage
                                    ? 'AI is analysing the photo...'
                                    : _aiSuggestion!,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_analysingImage)
                              TextButton(
                                onPressed: _cancelImageAnalysis,
                                child: const Text('Cancel'),
                              ),
                          ],
                        ),
                        if (_aiCandidates.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: _aiCandidates
                                .map(
                                  (suggestion) => ActionChip(
                                    avatar: const Icon(
                                      Icons.check_circle_outline,
                                      size: 17,
                                    ),
                                    label: Text(
                                      '${suggestion.category} ${(suggestion.confidence * 100).round()}%',
                                    ),
                                    onPressed: () => setState(() {
                                      _category = suggestion.category;
                                      _categoryWasManuallySelected = true;
                                      _aiSuggestion =
                                          'Selected ${suggestion.category} from AI suggestions';
                                      _aiCandidates = const [];
                                    }),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _title,
                  maxLength: 80,
                  decoration: safeInput('Report title', icon: Icons.title),
                  validator: (value) => _validateReportText(
                    value,
                    minimum: 5,
                    fieldName: 'Title',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_category),
                  initialValue: _category.isEmpty ? null : _category,
                  decoration: safeInput('Category'),
                  items: reportCategories
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _category = v;
                      _categoryWasManuallySelected = true;
                      _aiCandidates = const [];
                      _aiSuggestion = 'Category selected manually: $v';
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a category'
                      : null,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Severity Level',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Low', 'Medium', 'High', 'Critical']
                      .map(
                        (v) => ChoiceChip(
                          label: Text(v),
                          selected: _severity == v,
                          selectedColor: severityColor(v),
                          labelStyle: TextStyle(
                            color: _severity == v
                                ? Colors.white
                                : severityColor(v),
                          ),
                          onSelected: (_) => setState(() => _severity = v),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationName,
                  decoration: safeInput(
                    'Location name',
                    icon: Icons.location_on_outlined,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a location' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _getLocation,
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
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 8),
                  child: Text(
                    '${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: mutedText, fontSize: 11),
                  ),
                ),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: safeInput('Description'),
                  validator: (value) => _validateReportText(
                    value,
                    minimum: 10,
                    fieldName: 'Description',
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _checkingDuplicates ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Text(
                      _checkingDuplicates
                          ? 'Checking nearby reports...'
                          : 'Submit Report',
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
