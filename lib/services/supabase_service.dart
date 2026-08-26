import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/report.dart';
import '../models/user_account.dart';

class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService instance = SupabaseService._internal();

  bool get isConfigured => SupabaseConfig.isConfigured;

  SupabaseClient get _client {
    if (!isConfigured) {
      throw StateError('Supabase is not configured.');
    }
    return Supabase.instance.client;
  }

  Future<List<RoadReport>> getReports() async {
    final rows = await _client
        .from('road_reports')
        .select()
        .order('created_on', ascending: false);
    return rows.map(RoadReport.fromRemoteMap).toList();
  }

  Future<void> upsertReport(RoadReport report) async {
    await _client
        .from('road_reports')
        .upsert(report.toRemoteMap(), onConflict: 'id');
  }

  Future<void> deleteReport(String remoteId) async {
    await _client.from('road_reports').delete().eq('id', remoteId);
  }

  Future<void> upsertVerification(String reportId, String userEmail) async {
    await _client.from('report_verifications').upsert({
      'report_id': reportId,
      'user_email': userEmail.toLowerCase(),
    }, onConflict: 'report_id,user_email');
  }

  Future<void> deleteVerification(String reportId, String userEmail) async {
    await _client
        .from('report_verifications')
        .delete()
        .eq('report_id', reportId)
        .eq('user_email', userEmail.toLowerCase());
  }

  Future<void> upsertUserProfile(
    UserAccount user, {
    String? previousEmail,
  }) async {
    if (previousEmail != null &&
        previousEmail.toLowerCase() != user.email.toLowerCase()) {
      await deleteUserProfile(previousEmail);
    }
    await _client
        .from('user_profiles')
        .upsert(user.toRemoteMap(), onConflict: 'email');
  }

  Future<List<Map<String, dynamic>>> getUserProfiles() async {
    final rows = await _client
        .from('user_profiles')
        .select('email, full_name, is_admin')
        .order('full_name');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> deleteUserProfile(String email) async {
    await _client
        .from('user_profiles')
        .delete()
        .eq('email', email.toLowerCase());
  }
}
