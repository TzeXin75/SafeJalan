import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

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
  String _category = 'Pothole', _severity = 'High';
  File? _image;
  double _lat = 3.1585, _lng = 101.7123;
  bool _locating = false;
  @override
  void dispose() {
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
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    final location = Location();
    bool enabled =
        await location.serviceEnabled() || await location.requestService();
    if (!enabled) {
      setState(() => _locating = false);
      return;
    }
    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission == PermissionStatus.granted) {
      final data = await location.getLocation();
      _lat = data.latitude ?? _lat;
      _lng = data.longitude ?? _lng;
    }
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
    if (!_key.currentState!.validate()) return;
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
    await context.read<AppProvider>().addReport(report);
    _key.currentState!.reset();
    _title.clear();
    _description.clear();
    setState(() => _image = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Road report saved to SQLite.')),
      );
    }
    widget.onSaved();
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
            'Report Road Damage',
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _title,
                  decoration: safeInput('Report title', icon: Icons.title),
                  validator: (v) => v == null || v.trim().length < 5
                      ? 'Enter at least 5 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: safeInput('Category'),
                  items:
                      [
                            'Pothole',
                            'Road Damage',
                            'Traffic Signals',
                            'Infrastructure',
                            'Flooding',
                            'Road Markings',
                          ]
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _category = v!),
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
                TextButton.icon(
                  onPressed: _locating ? null : _getLocation,
                  icon: _locating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    '${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}',
                  ),
                ),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: safeInput('Description'),
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Describe the problem in at least 10 characters'
                      : null,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _submit,
                  child: const Padding(
                    padding: EdgeInsets.all(13),
                    child: Text('Submit Report'),
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
