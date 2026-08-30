import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static bool _initialised = false;
  static String? initialisationError;

  static bool get hasCredentials =>
      url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;
  static bool get isConfigured => _initialised;

  static Future<void> initialise() async {
    if (!hasCredentials) return;
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: publishableKey,
      ).timeout(const Duration(seconds: 8));
      _initialised = true;
      initialisationError = null;
    } catch (error) {
      _initialised = false;
      initialisationError = error.toString();
    }
  }
}
