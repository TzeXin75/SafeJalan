import 'package:flutter/material.dart';

import '../widgets/common.dart';
import 'auth/login_screen.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), navy, Color(0xFF070B16)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              right: -60,
              child: _Glow(size: 260, color: Color(0x334361EE)),
            ),
            const Positioned(
              bottom: 120,
              left: -100,
              child: _Glow(size: 230, color: Color(0x2412B886)),
            ),
            Positioned(
              top: 12,
              right: 16,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: .08),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: const Text('Admin'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(admin: true),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 72, 24, 28),
                child: Column(
                  children: [
                    const SafeLogo(size: 82, dark: true),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: safeTeal.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: safeTeal.withValues(alpha: .25),
                        ),
                      ),
                      child: const Text(
                        'SMARTER ROADS · SAFER COMMUNITIES',
                        style: TextStyle(
                          color: Color(0xFF6EE7C4),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SafeJalan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 330,
                      child: Text(
                        'Report road hazards in seconds and help make every journey safer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB8C3DC),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Row(
                      children: [
                        Expanded(child: _Stat('0', 'Citizens')),
                        _VerticalLine(),
                        Expanded(child: _Stat('0', 'Reports')),
                        _VerticalLine(),
                        Expanded(child: _Stat('0', 'Resolved')),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .07),
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          const _Feature(
                            Icons.add_a_photo_outlined,
                            'Photo & GPS reporting',
                          ),
                          const _Feature(
                            Icons.map_outlined,
                            'Live incident map',
                          ),
                          const _Feature(
                            Icons.workspace_premium_outlined,
                            'Community points & ranking',
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                minimumSize: const Size.fromHeight(56),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Get Started'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Feature(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFAEC0FF), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        const Icon(Icons.check_circle, color: safeTeal, size: 19),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF8491AA), fontSize: 11),
      ),
    ],
  );
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: Colors.white12);
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
