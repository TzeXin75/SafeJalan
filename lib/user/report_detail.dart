import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safejalan_native/models/report.dart';
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
    final verified = app.hasVerified(current);
    final updating = app.isUpdatingVerification(current);
    final canModify = app.canModifyOwnReport(current);
    final canVerify = !const {
      'resolved',
      'rejected',
      'archived',
    }.contains(current.status.toLowerCase());
    return Scaffold(
      appBar: AppBar(title: const Text('Report Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ZoomableStoredImage(
            path: current.imagePath,
            fallback: ColoredBox(
              color: severityColor(current.severity).withValues(alpha: .1),
              child: Center(
                child: Icon(
                  Icons.add_road,
                  size: 76,
                  color: severityColor(current.severity),
                ),
              ),
            ),
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
              items:
                  const [
                        'Pothole',
                        'Road Damage',
                        'Traffic Signals',
                        'Infrastructure',
                        'Flooding',
                        'Road Markings',
                      ]
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
