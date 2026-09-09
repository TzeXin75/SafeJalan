import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:safejalan_native/models/connectivity_report.dart';
import 'package:safejalan_native/models/report.dart';
import 'package:safejalan_native/models/safety_announcement.dart';
import 'package:safejalan_native/models/user_account.dart';
import 'package:safejalan_native/models/user_notification.dart';

class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService instance = SupabaseService._internal();

  bool _isConfigured = false;
  bool _storageReady = false;
  static const String _imageBucket = 'safejalan-images';
  String? initialisationError;

  bool get isConfigured => _isConfigured;

  void setInitialisationResult({required bool isConfigured, String? error}) {
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
    final values = report.toRemoteMap();
    final imageUrl = await _uploadLocalImage(
      localPath: report.imagePath,
      folder: 'reports',
      fileName: report.remoteId ?? report.id?.toString() ?? 'report',
    );
    if (imageUrl != null) values['image_url'] = imageUrl;
    final afterImageUrl = await _uploadLocalImage(
      localPath: report.afterImagePath,
      folder: 'report-results',
      fileName: report.remoteId ?? report.id?.toString() ?? 'report-result',
    );
    if (afterImageUrl != null) values['after_image_url'] = afterImageUrl;
    try {
      await _client.from('road_reports').upsert(values, onConflict: 'id');
    } on PostgrestException {
      final compatibleValues = Map<String, dynamic>.from(values)
        ..remove('after_image_url')
        ..remove('responsible_agency')
        ..remove('scheduled_repair_date')
        ..remove('admin_note')
        ..remove('completion_note')
        ..remove('resolved_by');
      await _client
          .from('road_reports')
          .upsert(compatibleValues, onConflict: 'id');
    }
  }

  Future<void> deleteReport(String remoteId) async {
    await _client.from('road_reports').delete().eq('id', remoteId);
  }

  Future<void> syncReportImage(RoadReport report) async {
    if (report.remoteId == null) return;
    final imageUrl = await _uploadLocalImage(
      localPath: report.imagePath,
      folder: 'reports',
      fileName: report.remoteId!,
    );
    if (imageUrl == null) return;
    await _client
        .from('road_reports')
        .update({'image_url': imageUrl})
        .eq('id', report.remoteId!);
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

  Future<void> upsertAnnouncementRead({
    required String announcementId,
    required String userEmail,
    required String readAt,
  }) async {
    await _client.from('announcement_reads').upsert({
      'announcement_id': announcementId,
      'user_email': userEmail.toLowerCase(),
      'read_at': readAt,
    }, onConflict: 'announcement_id,user_email');
  }

  Future<List<Map<String, dynamic>>> getAnnouncementReads(
    String userEmail,
  ) async {
    final rows = await _client
        .from('announcement_reads')
        .select('announcement_id, user_email, read_at')
        .eq('user_email', userEmail.toLowerCase());
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> upsertUserNotification(UserNotificationItem notification) async {
    await _client
        .from('user_notifications')
        .upsert(notification.toRemoteMap(), onConflict: 'id');
  }

  Future<List<UserNotificationItem>> getUserNotifications(
    String userEmail,
  ) async {
    final rows = await _client
        .from('user_notifications')
        .select()
        .eq('user_email', userEmail.toLowerCase())
        .order('created_at', ascending: false);
    return rows.map(UserNotificationItem.fromRemoteMap).toList();
  }

  Future<void> upsertUserProfile(
    UserAccount user, {
    String? previousEmail,
  }) async {
    if (previousEmail != null &&
        previousEmail.toLowerCase() != user.email.toLowerCase()) {
      await deleteUserProfile(previousEmail);
    }
    final values = user.toRemoteMap();
    final avatarUrl = await _uploadLocalImage(
      localPath: user.imagePath,
      folder: 'avatars',
      fileName: user.email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
    );
    if (avatarUrl != null) values['avatar_url'] = avatarUrl;
    await _client.from('user_profiles').upsert(values, onConflict: 'email');
  }

  Future<String?> _uploadLocalImage({
    required String? localPath,
    required String folder,
    required String fileName,
  }) async {
    if (localPath == null || localPath.trim().isEmpty) return null;
    if (localPath.startsWith('http')) return localPath;

    final file = File(localPath);
    if (!await file.exists()) return null;
    await _ensureImageBucket();

    final lowerPath = localPath.toLowerCase();
    final extension = lowerPath.endsWith('.png') ? 'png' : 'jpg';
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
    final objectPath = '$folder/$fileName.$extension';
    await _client.storage
        .from(_imageBucket)
        .uploadBinary(
          objectPath,
          await file.readAsBytes(),
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
            cacheControl: '3600',
          ),
        );
    return _client.storage.from(_imageBucket).getPublicUrl(objectPath);
  }

  Future<void> _ensureImageBucket() async {
    if (_storageReady) return;
    final buckets = await _client.storage.listBuckets();
    if (!buckets.any((bucket) => bucket.id == _imageBucket)) {
      await _client.storage.createBucket(
        _imageBucket,
        const BucketOptions(public: true),
      );
    }
    _storageReady = true;
  }

  Future<UserAccount?> getUserByEmail(String email) async {
    final row = await _client
        .from('user_profiles')
        .select(
          'email, full_name, password_hash, is_admin, is_active, avatar_url, updated_at',
        )
        .eq('email', email.trim().toLowerCase())
        .maybeSingle();
    return row == null ? null : UserAccount.fromRemoteMap(row);
  }

  Future<void> syncUserAvatar(UserAccount user) async {
    final avatarUrl = await _uploadLocalImage(
      localPath: user.imagePath,
      folder: 'avatars',
      fileName: user.email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
    );
    if (avatarUrl == null) return;
    await _client
        .from('user_profiles')
        .update({'avatar_url': avatarUrl})
        .eq('email', user.email.toLowerCase());
  }

  Future<List<Map<String, dynamic>>> getUserProfiles() async {
    final rows = await _client
        .from('user_profiles')
        .select(
          'email, full_name, password_hash, is_admin, is_active, avatar_url, updated_at',
        )
        .order('full_name');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> deleteUserProfile(String email) async {
    await _client
        .from('user_profiles')
        .delete()
        .eq('email', email.toLowerCase());
  }

  Future<void> deactivateUserProfile(String email) async {
    await _client
        .from('user_profiles')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('email', email.toLowerCase());
  }
}
