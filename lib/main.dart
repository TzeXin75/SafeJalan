import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safejalan_native/providers/app_provider.dart';
import 'package:safejalan_native/entry.dart';
import 'package:safejalan_native/services/supabase_service.dart';
import 'package:safejalan_native/widgets/common.dart';
import 'package:safejalan_native/admin/admin_home.dart';
import 'package:safejalan_native/user/user_home.dart';

const String supabaseUrl = 'https://ubcunymjqlxqznyuvmey.supabase.co';

// Classroom prototype: follows the lecture example by passing the Supabase
// secret key through anonKey. Do not reuse this setup for a production app.
const String supabaseKey = '';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const SafeJalanApp(),
    ),
  );
  unawaited(_bootstrap(appProvider));
}

Future<void> _bootstrap(AppProvider appProvider) async {
  final localInitialisation = appProvider.initialise();
  if (supabaseUrl.trim().isNotEmpty && supabaseKey.trim().isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseKey,
      ).timeout(const Duration(seconds: 8));
      SupabaseService.instance.setInitialisationResult(isConfigured: true);
    } catch (error) {
      SupabaseService.instance.setInitialisationResult(
        isConfigured: false,
        error: error.toString(),
      );
    }
  }
  await localInitialisation;
  if (SupabaseService.instance.isConfigured) {
    await appProvider.syncReports();
    await appProvider.syncConnectivityReports();
    await appProvider.syncSafetyAnnouncements();
    await appProvider.syncAnnouncementReads();
    await appProvider.syncUsers();
  }
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: safeOrange,
        tertiary: safeTeal,
        surface: Colors.white,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: navy,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
        ),
        headlineSmall: TextStyle(
          color: navy,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
        titleLarge: TextStyle(color: navy, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(color: Color(0xFF344054), height: 1.35),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x160C2745),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: softBorder),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: navy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          side: const BorderSide(color: softBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shadowColor: const Color(0x240C2745),
        indicatorColor: primary.withValues(alpha: .12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? primary : mutedText,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: softBorder),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    home: const _SessionGate(),
  );
}

class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    if (app.isLoading) {
      return const Scaffold(
        backgroundColor: navy,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeroBrandMark(size: 112),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }
    if (!app.isLoggedIn) return const EntryScreen();
    return app.isAdmin ? const AdminHome() : const UserHome();
  }
}
