import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'providers/app_provider.dart';
import 'screens/entry_screen.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialise();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..initialise(),
      child: const SafeJalanApp(),
    ),
  );
}

class SafeJalanApp extends StatelessWidget {
  const SafeJalanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SafeJalan',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: safeBg,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
    ),
    home: const EntryScreen(),
  );
}
