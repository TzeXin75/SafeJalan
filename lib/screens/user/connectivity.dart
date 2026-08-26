import 'package:flutter/material.dart';
import '../../widgets/common.dart';

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});
  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  final _key = GlobalKey<FormState>();
  final _carrier = TextEditingController(), _notes = TextEditingController();
  String _type = 'Poor Signal';
  final List<Map<String, String>> _items = [];
  @override
  void dispose() {
    _carrier.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
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
                'Help map network dead zones',
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
                        (v) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ChoiceChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(v, textAlign: TextAlign.center),
                              ),
                              selected: _type == v,
                              onSelected: (_) => setState(() => _type = v),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _carrier,
                  decoration: safeInput(
                    'Network carrier',
                    icon: Icons.sim_card_outlined,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter the carrier'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: safeInput('Additional notes'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter a short note'
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (!_key.currentState!.validate()) return;
                    setState(
                      () => _items.insert(0, {
                        'area': 'Current Location, KL',
                        'type': _type,
                        'carrier': _carrier.text.trim(),
                        'time': 'Just now',
                      }),
                    );
                    _carrier.clear();
                    _notes.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connectivity report added.'),
                      ),
                    );
                  },
                  child: const Text('Report Gap'),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Recent Connectivity Reports',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._items.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.wifi_off)),
                      title: Text(item['area']!),
                      subtitle: Text('${item['carrier']} · ${item['type']}'),
                      trailing: Text(
                        item['time']!,
                        style: const TextStyle(fontSize: 11),
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
