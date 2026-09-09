import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/models/report.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';
import 'package:safejalan_native/widgets/stored_image.dart';

class AdminReportDetailScreen extends StatefulWidget {
  const AdminReportDetailScreen({super.key, required this.report});

  final RoadReport report;

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  late final TextEditingController _agency;
  late final TextEditingController _adminNote;
  late final TextEditingController _completionNote;
  late String _status;
  DateTime? _scheduledDate;
  File? _afterImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.report.status;
    _agency = TextEditingController(text: widget.report.responsibleAgency);
    _adminNote = TextEditingController(text: widget.report.adminNote);
    _completionNote = TextEditingController(text: widget.report.completionNote);
    _scheduledDate = DateTime.tryParse(widget.report.scheduledRepairDate);
  }

  @override
  void dispose() {
    _agency.dispose();
    _adminNote.dispose();
    _completionNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<AppProvider>().latestVersionOf(widget.report);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Report'),
            Text(
              report.remoteId == null
                  ? 'Local report · Admin'
                  : '${report.remoteId!.length <= 8 ? report.remoteId! : report.remoteId!.substring(0, 8)} · Admin',
              style: const TextStyle(color: mutedText, fontSize: 11),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: StoredImage(
                        path: report.imagePath,
                        fallback: _ReportImageFallback(report: report),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report.locationName,
                          style: const TextStyle(color: mutedText),
                        ),
                        const SizedBox(height: 9),
                        LabelBadge(report.status, statusColor(report.status)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update maintenance',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _normalisedStatus(_status),
                    decoration: safeInput('Current status'),
                    items:
                        const [
                              'Pending',
                              'Reviewed',
                              'In Progress',
                              'Resolved',
                              'Rejected',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _agency,
                    decoration: safeInput(
                      'Responsible agency',
                      icon: Icons.apartment_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: safeInput(
                        'Scheduled repair date',
                        icon: Icons.calendar_today_outlined,
                      ),
                      child: Text(
                        _scheduledDate == null
                            ? 'Select a date'
                            : _scheduledDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _adminNote,
                    maxLines: 3,
                    decoration: safeInput('Admin note'),
                  ),
                  if (_status.toLowerCase() == 'resolved') ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Repair evidence',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickAfterImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: _afterImage != null
                              ? Image.file(_afterImage!, fit: BoxFit.cover)
                              : StoredImage(
                                  path: report.afterImagePath,
                                  fallback: ColoredBox(
                                    color: primary.withValues(alpha: .08),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          color: primary,
                                          size: 38,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Add repair completion photo'),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _completionNote,
                      maxLines: 3,
                      decoration: safeInput('Completion note'),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => _save(report, keepStatus: true),
                          child: const Text('Save draft'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : () => _save(report),
                          child: Text(_saving ? 'Saving...' : 'Update status'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  _DetailRow(
                    Icons.person_outline,
                    'Reporter',
                    report.reporterEmail,
                  ),
                  _DetailRow(
                    Icons.category_outlined,
                    'Category',
                    report.category,
                  ),
                  _DetailRow(
                    Icons.verified_outlined,
                    'Verifications',
                    '${report.votes}',
                  ),
                  const SizedBox(height: 12),
                  Text(report.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _normalisedStatus(String value) =>
      const [
        'Pending',
        'Reviewed',
        'In Progress',
        'Resolved',
        'Rejected',
      ].firstWhere(
        (item) => item.toLowerCase() == value.toLowerCase(),
        orElse: () => 'Pending',
      );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (selected != null && mounted) setState(() => _scheduledDate = selected);
  }

  Future<void> _pickAfterImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
    );
    if (picked != null && mounted) {
      setState(() => _afterImage = File(picked.path));
    }
  }

  Future<String?> _saveAfterImage() async {
    if (_afterImage == null) return null;
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/repair_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _afterImage!.copy(path);
    return path;
  }

  Future<void> _save(RoadReport report, {bool keepStatus = false}) async {
    final nextStatus = keepStatus ? report.status : _status;
    if (nextStatus.toLowerCase() == 'resolved' &&
        _afterImage == null &&
        (report.afterImagePath == null || report.afterImagePath!.isEmpty)) {
      _showMessage('Add an after-repair photo before resolving the report.');
      return;
    }
    if (nextStatus.toLowerCase() == 'resolved' &&
        _completionNote.text.trim().isEmpty) {
      _showMessage('Enter a completion note before resolving the report.');
      return;
    }
    setState(() => _saving = true);
    final path = await _saveAfterImage();
    if (!mounted) return;
    await context.read<AppProvider>().updateReportMaintenance(
      report,
      status: nextStatus,
      responsibleAgency: _agency.text,
      scheduledRepairDate:
          _scheduledDate?.toIso8601String().split('T').first ?? '',
      adminNote: _adminNote.text,
      completionNote: _completionNote.text,
      afterImagePath: path,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (keepStatus) {
      _showMessage('Maintenance draft saved.');
      return;
    }
    Navigator.pop(context, true);
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _ReportImageFallback extends StatelessWidget {
  const _ReportImageFallback({required this.report});

  final RoadReport report;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: severityColor(report.severity).withValues(alpha: .1),
    child: Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: severityColor(report.severity),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text(label, style: const TextStyle(color: mutedText)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
