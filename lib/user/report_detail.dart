import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safejalan_native/models/report.dart';
import 'package:safejalan_native/models/report_categories.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';
import 'package:safejalan_native/widgets/stored_image.dart';

final _reportLetterOrNumberPattern = RegExp(
  r'[A-Za-z0-9\u00C0-\u024F\u4E00-\u9FFF]',
);

bool _containsReportEmoji(String text) => text.runes.any(
  (codePoint) =>
      (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF) ||
      (codePoint >= 0x1F300 && codePoint <= 0x1FAFF) ||
      (codePoint >= 0x2600 && codePoint <= 0x27BF) ||
      codePoint == 0xFE0F,
);

class ReportDetailScreen extends StatelessWidget {
  final RoadReport report;
  const ReportDetailScreen({super.key, required this.report});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final current = app.latestVersionOf(report);
    final isResolved = current.status.toLowerCase() == 'resolved';
    final isOwnReport =
        current.reporterEmail.toLowerCase() == app.email.toLowerCase();
    final verified = app.hasVerified(current);
    final updating = app.isUpdatingVerification(current);
    final canModify = app.canModifyOwnReport(current);
    final canVerify = !const {
      'resolved',
      'rejected',
      'archived',
    }.contains(current.status.toLowerCase());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isResolved
              ? 'Repair Result'
              : isOwnReport
              ? 'Report Progress'
              : 'Report Detail',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isResolved) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: safeTeal.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: safeTeal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Repair completed${current.responsibleAgency.isEmpty ? '' : ' by ${current.responsibleAgency}'}',
                      style: const TextStyle(
                        color: safeTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (isResolved && current.afterImagePath?.isNotEmpty == true)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EvidencePhoto(
                    label: 'Before',
                    path: current.imagePath,
                    report: current,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _EvidencePhoto(
                    label: 'After',
                    path: current.afterImagePath,
                    report: current,
                  ),
                ),
              ],
            )
          else
            ZoomableStoredImage(
              path: current.imagePath,
              fallback: _imageFallback(current),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              LabelBadge(current.severity, severityColor(current.severity)),
              LabelBadge(
                current.status,
                current.status == 'Resolved' ? Colors.green : primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            current.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            current.locationName,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const Divider(height: 32),
          Text(
            current.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Reported on ${current.createdOn}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          if (isOwnReport &&
              !const {
                'rejected',
                'archived',
              }.contains(current.status.toLowerCase())) ...[
            const SizedBox(height: 18),
            _ReportProgressCard(report: current),
          ],
          if (current.responsibleAgency.isNotEmpty ||
              current.scheduledRepairDate.isNotEmpty ||
              current.adminNote.isNotEmpty ||
              current.completionNote.isNotEmpty) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.status.toLowerCase() == 'resolved'
                          ? 'Completion details'
                          : 'Maintenance details',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (current.responsibleAgency.isNotEmpty)
                      _MaintenanceRow(
                        Icons.apartment_outlined,
                        'Responsible agency',
                        current.responsibleAgency,
                      ),
                    if (current.scheduledRepairDate.isNotEmpty)
                      _MaintenanceRow(
                        Icons.calendar_today_outlined,
                        'Scheduled date',
                        current.scheduledRepairDate,
                      ),
                    if (current.adminNote.isNotEmpty)
                      _MaintenanceRow(
                        Icons.notes_outlined,
                        'Admin note',
                        current.adminNote,
                      ),
                    if (current.completionNote.isNotEmpty)
                      _MaintenanceRow(
                        Icons.fact_check_outlined,
                        'Completion note',
                        current.completionNote,
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (canModify) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _edit(context, current),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit report'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => _cancel(context, current),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel report'),
                  ),
                ),
              ],
            ),
            const Text(
              'Available during the first 24 hours while the report is Pending.',
              style: TextStyle(color: mutedText, fontSize: 11),
            ),
          ],
          const SizedBox(height: 24),
          if (canVerify)
            (verified ? OutlinedButton.icon : FilledButton.icon)(
              onPressed: updating
                  ? null
                  : () async {
                      final nowVerified = await context
                          .read<AppProvider>()
                          .toggleVerification(current);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              nowVerified
                                  ? 'Verification recorded.'
                                  : 'Verification cancelled.',
                            ),
                          ),
                        );
                      }
                    },
              icon: Icon(verified ? Icons.undo : Icons.thumb_up),
              label: Text(
                verified
                    ? 'Cancel verification (${current.votes})'
                    : 'Still exists (${current.votes})',
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor(current.status).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                current.status.toLowerCase() == 'resolved'
                    ? 'This report has been resolved and is kept in your history.'
                    : 'This report is no longer active.',
                style: TextStyle(
                  color: statusColor(current.status),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, RoadReport current) async {
    final input = await showDialog<_ReportInput>(
      context: context,
      builder: (_) => _ReportEditDialog(report: current),
    );
    if (input == null || !context.mounted) return;
    final error = await context.read<AppProvider>().updateOwnReport(
      current,
      title: input.title,
      category: input.category,
      severity: input.severity,
      description: input.description,
      locationName: input.locationName,
    );
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _cancel(BuildContext context, RoadReport current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel road report?'),
        content: const Text(
          'The report will be removed from SQLite and Supabase after synchronization.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep report'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel report'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<AppProvider>().cancelOwnReport(current);
    if (!context.mounted) return;
    if (error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

Widget _imageFallback(RoadReport report) => ColoredBox(
  color: severityColor(report.severity).withValues(alpha: .1),
  child: Center(
    child: Icon(
      Icons.add_road,
      size: 76,
      color: severityColor(report.severity),
    ),
  ),
);

class _ReportProgressCard extends StatelessWidget {
  const _ReportProgressCard({required this.report});

  final RoadReport report;

  int get _stage => switch (report.status.toLowerCase()) {
    'reviewed' => 1,
    'in progress' => 2,
    'resolved' => 3,
    _ => 0,
  };

  String _date(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return value;
    return value.contains('T')
        ? DateFormat('d MMM yyyy · h:mm a').format(parsed)
        : DateFormat('d MMM yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final updated = report.updatedAt.isEmpty ? '' : _date(report.updatedAt);
    final agency = report.responsibleAgency;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status history',
              style: TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _ProgressStep(
              title: 'Report submitted',
              detail: _date(report.createdOn),
              completed: true,
            ),
            _ProgressStep(
              title: 'Reviewed by admin',
              detail: _stage >= 1
                  ? (_stage == 1 && updated.isNotEmpty ? updated : 'Completed')
                  : 'Waiting for review',
              completed: _stage > 1,
              current: _stage == 1,
            ),
            _ProgressStep(
              title: 'Repair in progress',
              detail: _stage >= 2
                  ? [
                      if (agency.isNotEmpty) '$agency assigned',
                      if (_stage == 2 && updated.isNotEmpty) updated,
                      if (agency.isEmpty && (_stage != 2 || updated.isEmpty))
                        'Completed',
                    ].join(' · ')
                  : 'Waiting for repair',
              completed: _stage > 2,
              current: _stage == 2,
            ),
            _ProgressStep(
              title: 'Repair completed',
              detail: _stage == 3
                  ? (updated.isEmpty ? 'Completed' : updated)
                  : 'Waiting for completion',
              completed: _stage == 3,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.title,
    required this.detail,
    this.completed = false,
    this.current = false,
    this.isLast = false,
  });

  final String title;
  final String detail;
  final bool completed;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? safeTeal
        : current
        ? safeOrange
        : const Color(0xFFCBD5E1);
    return SizedBox(
      height: isLast ? 62 : 82,
      child: Stack(
        children: [
          if (!isLast)
            Positioned(
              left: 17,
              top: 34,
              bottom: 0,
              child: Container(
                width: 3,
                color: completed ? safeTeal : const Color(0xFFD8E0E8),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  completed ? Icons.check_rounded : Icons.circle_outlined,
                  color: Colors.white,
                  size: completed ? 23 : 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidencePhoto extends StatelessWidget {
  const _EvidencePhoto({
    required this.label,
    required this.path,
    required this.report,
  });

  final String label;
  final String? path;
  final RoadReport report;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LabelBadge(label, label == 'After' ? primary : mutedText),
      const SizedBox(height: 7),
      ZoomableStoredImage(
        path: path,
        height: 180,
        fallback: _imageFallback(report),
      ),
    ],
  );
}

class _MaintenanceRow extends StatelessWidget {
  const _MaintenanceRow(this.icon, this.label, this.value);

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: mutedText, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReportInput {
  const _ReportInput({
    required this.title,
    required this.category,
    required this.severity,
    required this.description,
    required this.locationName,
  });

  final String title;
  final String category;
  final String severity;
  final String description;
  final String locationName;
}

class _ReportEditDialog extends StatefulWidget {
  const _ReportEditDialog({required this.report});

  final RoadReport report;

  @override
  State<_ReportEditDialog> createState() => _ReportEditDialogState();
}

class _ReportEditDialogState extends State<_ReportEditDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late String _category;
  late String _severity;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.report.title);
    _description = TextEditingController(text: widget.report.description);
    _location = TextEditingController(text: widget.report.locationName);
    _category = widget.report.category;
    _severity = widget.report.severity;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit road report'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              maxLength: 80,
              decoration: safeInput('Title'),
              validator: (value) =>
                  _validateReportText(value, minimum: 5, fieldName: 'Title'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: safeInput('Category'),
              items: reportCategoryOptions(_category)
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _severity,
              decoration: safeInput('Severity'),
              items: const ['Low', 'Medium', 'High', 'Critical']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _severity = value!),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _location,
              decoration: safeInput('Location'),
              validator: _required,
            ),
            const SizedBox(height: 10),
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
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_key.currentState!.validate()) return;
          Navigator.pop(
            context,
            _ReportInput(
              title: _title.text.trim(),
              category: _category,
              severity: _severity,
              description: _description.text.trim(),
              locationName: _location.text.trim(),
            ),
          );
        },
        child: const Text('Save changes'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _validateReportText(
    String? value, {
    required int minimum,
    required String fieldName,
  }) {
    final text = value?.trim() ?? '';
    if (text.length < minimum) return '$fieldName needs $minimum characters';
    if (_containsReportEmoji(text)) {
      return '$fieldName cannot contain emoji';
    }
    if (!_reportLetterOrNumberPattern.hasMatch(text)) {
      return '$fieldName must contain letters or numbers';
    }
    return null;
  }
}
