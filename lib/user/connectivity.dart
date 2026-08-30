import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/widgets/common.dart';

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  final _key = GlobalKey<FormState>();
  final _carrier = TextEditingController();
  final _notes = TextEditingController();
  String _type = 'Poor Signal';
  bool _saving = false;

  @override
  void dispose() {
    _carrier.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    await context.read<AppProvider>().addConnectivityReport(
      issueType: _type,
      carrier: _carrier.text.trim(),
      notes: _notes.text.trim(),
      area: 'Current Location, KL',
    );
    if (!mounted) return;
    _carrier.clear();
    _notes.clear();
    setState(() => _saving = false);
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
              report.reporterEmail.toLowerCase() == app.email.toLowerCase() &&
              report.status.toLowerCase() != 'resolved',
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
                    controller: _notes,
                    maxLines: 3,
                    maxLength: 250,
                    decoration: safeInput('Additional notes'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a short note'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(_saving ? 'Saving...' : 'Report Gap'),
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
                        leading: const CircleAvatar(
                          child: Icon(Icons.wifi_off),
                        ),
                        title: Text(item.area),
                        subtitle: Text(
                          '${item.carrier} · ${item.issueType}\n${item.notes}',
                        ),
                        isThreeLine: true,
                        trailing: LabelBadge(
                          item.status,
                          statusColor(item.status),
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
