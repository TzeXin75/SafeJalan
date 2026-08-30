import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/connectivity_report.dart';
import '../models/report.dart';
import '../models/safety_announcement.dart';
import '../models/user_account.dart';

class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService instance = SupabaseService._internal();

  bool _isConfigured = false;
  String? initialisationError;

  bool get isConfigured => _isConfigured;

  void setInitialisationResult({
    required bool isConfigured,
    String? error,
  }) {
    _isConfigured = isConfigured;
    initialisationError = error;
  }

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

  Future<List<Map<String, dynamic>>> getVerifications() async {
    final rows = await _client
        .from('report_verifications')
        .select('report_id, user_email, created_at');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<List<ConnectivityReport>> getConnectivityReports() async {
    final rows = await _client
        .from('connectivity_reports')
        .select()
        .order('created_at', ascending: false);
    return rows.map(ConnectivityReport.fromRemoteMap).toList();
  }

  Future<void> upsertConnectivityReport(ConnectivityReport report) async {
    await _client
        .from('connectivity_reports')
        .upsert(report.toRemoteMap(), onConflict: 'id');
  }

  Future<void> deleteConnectivityReport(String remoteId) async {
    await _client.from('connectivity_reports').delete().eq('id', remoteId);
  }

  Future<List<SafetyAnnouncement>> getSafetyAnnouncements() async {
    final rows = await _client
        .from('safety_announcements')
        .select()
        .order('created_at', ascending: false);
    return rows.map(SafetyAnnouncement.fromRemoteMap).toList();
  }

  Future<void> upsertSafetyAnnouncement(SafetyAnnouncement announcement) async {
    await _client
        .from('safety_announcements')
        .upsert(announcement.toRemoteMap(), onConflict: 'id');
  }

  Future<void> deleteSafetyAnnouncement(String remoteId) async {
    await _client.from('safety_announcements').delete().eq('id', remoteId);
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
