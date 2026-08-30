import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/connectivity_report.dart';
import '../models/leaderboard_entry.dart';
import '../models/user_account.dart';
import '../models/report.dart';
import '../models/safety_announcement.dart';
import '../repositories/report_repository.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _database = DatabaseService.instance;
  final ReportRepository _reportsRepository = ReportRepository();
  final SupabaseService _supabase = SupabaseService.instance;
  static const _uuid = Uuid();
  List<RoadReport> reports = [];
  List<ConnectivityReport> connectivityReports = [];
  List<SafetyAnnouncement> announcements = [];
  String userName = 'New User';
  String email = '';
  String? profileImagePath;
  int? currentUserId;
  bool isLoggedIn = false, isAdmin = false, isLoading = true;
  bool isSyncing = false;
  String? lastSyncError;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hadNetwork = false;
  final Set<String> _verifiedReportIds = <String>{};
  final Set<String> _updatingVerificationIds = <String>{};

  bool get isRemoteConfigured => _reportsRepository.isRemoteConfigured;
  List<RoadReport> get adminVisibleReports => reports
      .where((report) => report.status.toLowerCase() != 'archived')
      .toList();
  List<RoadReport> get userVisibleReports => reports.where((report) {
    final status = report.status.toLowerCase();
    return status != 'resolved' && status != 'archived';
  }).toList();
  List<RoadReport> get myReports => reports
      .where(
        (report) =>
            report.reporterEmail.isEmpty || report.reporterEmail == email,
      )
      .toList();
  List<RoadReport> get myVisibleReports => myReports.where((report) {
    final status = report.status.toLowerCase();
    return status != 'resolved' && status != 'archived';
  }).toList();
  List<SafetyAnnouncement> get activeAnnouncements =>
      announcements.where((announcement) => announcement.isActive).toList();

  bool hasVerified(RoadReport report) =>
      report.remoteId != null && _verifiedReportIds.contains(report.remoteId);

  bool isUpdatingVerification(RoadReport report) =>
      report.remoteId != null &&
      _updatingVerificationIds.contains(report.remoteId);

  RoadReport latestVersionOf(RoadReport report) => reports.firstWhere(
    (item) => report.remoteId != null
        ? item.remoteId == report.remoteId
        : item.id == report.id,
    orElse: () => report,
  );

  Future<void> initialise() async {
    final signedInUser = await _database.getSignedInUser();
    if (signedInUser != null) {
      _applyUser(signedInUser);
      await _loadVerifications();
    }
    reports = await _reportsRepository.getLocalReports();
    connectivityReports = await _database.getConnectivityReports();
    announcements = await _database.getSafetyAnnouncements();
    await _startConnectivityListener();
    isLoading = false;
    notifyListeners();
    await syncReports();
    await syncConnectivityReports();
    await syncSafetyAnnouncements();
    await _syncAllUsers();
  }

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  void _applyUser(UserAccount user) {
    currentUserId = user.id;
    userName = user.name;
    email = user.email;
    profileImagePath = user.imagePath;
    isAdmin = user.isAdmin;
    isLoggedIn = true;
  }

  Future<String?> login(
    String value,
    String password, {
    bool admin = false,
  }) async {
    UserAccount? user;
    if (_supabase.isConfigured && _hadNetwork) {
      try {
        await _syncAllUsers();
        final remoteUser = await _supabase.getUserByEmail(value);
        if (remoteUser == null ||
            remoteUser.passwordHash != _hashPassword(password)) {
          return 'Incorrect email or password';
        }
        await _database.upsertRemoteUser(remoteUser);
        user = await _database.findUserByEmail(value);
      } catch (_) {
        // A Wi-Fi/mobile connection can exist without internet. In that case,
        // use the last synchronized SQLite account.
        user = await _database.findUserByEmail(value);
      }
    } else {
      user = await _database.findUserByEmail(value);
    }
    if (user == null || user.passwordHash != _hashPassword(password)) {
      return 'Incorrect email or password';
    }
    if (!user.isActive) return 'This account has been deactivated';
    if (user.isAdmin != admin) {
      return admin
          ? 'This is not an administrator account'
          : 'Use Admin Login for this account';
    }
    _applyUser(user);
    await _database.saveSignedInUser(user.id);
    await _loadVerifications();
    await _trySyncUser(user);
    notifyListeners();
    return null;
  }

  Future<String?> register(String name, String value, String password) async {
    if (await _database.findUserByEmail(value) != null) {
      return 'This email is already registered';
    }
    if (_supabase.isConfigured && _hadNetwork) {
      try {
        if (await _supabase.getUserByEmail(value) != null) {
          return 'This email is already registered';
        }
      } catch (_) {
        // Continue offline: SQLite saves the account as pending.
      }
    }
    try {
      final id = await _database.insertUser(
        UserAccount(
          name: name,
          email: value,
          passwordHash: _hashPassword(password),
        ),
      );
      final user = await _database.findUserById(id);
      if (user != null) await _trySyncUser(user);
      return null;
    } on DatabaseException {
      return 'This email is already registered';
    }
  }

  Future<String?> saveProfile(
    String name,
    String value, {
    String? imagePath,
  }) async {
    if (currentUserId == null) return 'Please log in again';
    final existing = await _database.findUserByEmail(value);
    if (existing != null && existing.id != currentUserId) {
      return 'This email is already registered';
    }
    final oldEmail = email;
    await _database.updateUserProfile(
      currentUserId!,
      name,
      value,
      imagePath ?? profileImagePath,
    );
    userName = name;
    email = value;
    profileImagePath = imagePath ?? profileImagePath;
    if (oldEmail.toLowerCase() != value.toLowerCase()) {
      await _database.changeReportOwner(oldEmail, value);
      reports = await _reportsRepository.getLocalReports();
    }
    notifyListeners();
    final updatedUser = await _database.findUserById(currentUserId!);
    if (updatedUser != null) {
      await _trySyncUser(updatedUser, previousEmail: oldEmail);
    }
    if (oldEmail.toLowerCase() != value.toLowerCase()) {
      await syncReports();
    }
    return null;
  }

  Future<String?> resetPassword(String value, String newPassword) async {
    final user = await _database.findUserByEmail(value);
    if (user == null || user.isAdmin) {
      return 'No user account found for this email';
    }
    if (user.passwordHash == _hashPassword(newPassword)) {
      return 'New password cannot be the same as your current password';
    }
    await _database.updatePassword(user.id!, _hashPassword(newPassword));
    final updated = await _database.findUserById(user.id!);
    if (updated != null) await _trySyncUser(updated);
    return null;
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (currentUserId == null) return 'Please log in again';
    final user = await _database.findUserById(currentUserId!);
    if (user == null || user.passwordHash != _hashPassword(currentPassword)) {
      return 'Current password is incorrect';
    }
    if (user.passwordHash == _hashPassword(newPassword)) {
      return 'New password cannot be the same as your current password';
    }
    await _database.updatePassword(user.id!, _hashPassword(newPassword));
    final updated = await _database.findUserById(user.id!);
    if (updated != null) await _trySyncUser(updated);
    return null;
  }

  Future<void> logout() async {
    await _database.saveSignedInUser(null);
    currentUserId = null;
    userName = 'New User';
    email = '';
    profileImagePath = null;
    isLoggedIn = false;
    isAdmin = false;
    _verifiedReportIds.clear();
    notifyListeners();
  }

  Future<void> addReport(RoadReport report) async {
    await _reportsRepository.addReport(report.copyWith(reporterEmail: email));
    reports = await _reportsRepository.getLocalReports();
    notifyListeners();
    await syncReports();
  }

  Future<void> updateStatus(RoadReport report, String status) async {
    await _reportsRepository.updateReport(report.copyWith(status: status));
    reports = await _reportsRepository.getLocalReports();
    notifyListeners();
    await syncReports();
  }

  Future<bool> toggleVerification(RoadReport report) async {
    final current = latestVersionOf(report);
    final reportId = current.remoteId;
    if (email.isEmpty || reportId == null) return false;
    if (_updatingVerificationIds.contains(reportId)) {
      return hasVerified(current);
    }

    _updatingVerificationIds.add(reportId);
    notifyListeners();
    try {
      final nowVerified = await _database.toggleReportVerification(
        reportId,
        email,
      );
      if (nowVerified) {
        _verifiedReportIds.add(reportId);
      } else {
        _verifiedReportIds.remove(reportId);
      }

      final nextVotes = nowVerified
          ? current.votes + 1
          : (current.votes > 0 ? current.votes - 1 : 0);
      await _reportsRepository.updateReport(current.copyWith(votes: nextVotes));
      reports = await _reportsRepository.getLocalReports();
      notifyListeners();
      await syncReports();
      return nowVerified;
    } finally {
      _updatingVerificationIds.remove(reportId);
      notifyListeners();
    }
  }

  Future<void> deleteReport(RoadReport report) async {
    await _reportsRepository.deleteReport(report);
    reports = await _reportsRepository.getLocalReports();
    notifyListeners();
    await syncReports();
  }

  Future<void> archiveExpiredResolvedReports() async {
    final now = DateTime.now().toUtc();
    final expiredReports = reports.where((report) {
      if (report.status.toLowerCase() != 'resolved') return false;
      final resolvedOn =
          DateTime.tryParse(report.updatedAt) ??
          DateTime.tryParse(report.createdOn);
      if (resolvedOn == null) return false;
      final deleteOn = DateTime.utc(
        resolvedOn.year,
        resolvedOn.month + 3,
        resolvedOn.day,
        resolvedOn.hour,
        resolvedOn.minute,
        resolvedOn.second,
      );
      return !now.isBefore(deleteOn);
    }).toList();

    if (expiredReports.isEmpty) return;
    for (final report in expiredReports) {
      await _reportsRepository.updateReport(
        report.copyWith(status: 'Archived'),
      );
    }
    reports = await _reportsRepository.getLocalReports();
    notifyListeners();
  }

  Future<void> syncReports() async {
    if (isSyncing) return;
    isSyncing = true;
    notifyListeners();
    final result = await _reportsRepository.sync();
    await _syncPendingVerifications();
    lastSyncError = result.error;
    reports = await _reportsRepository.getLocalReports();
    await archiveExpiredResolvedReports();
    isSyncing = false;
    notifyListeners();
  }

  Future<void> _syncAllUsers() async {
    if (!_supabase.isConfigured) return;
    final users = await _database.getUsers(includeInactive: true);
    for (final user in users) {
      await _trySyncUser(user);
    }
    try {
      final profiles = await _supabase.getUserProfiles();
      for (final profile in profiles) {
        await _database.upsertRemoteUser(UserAccount.fromRemoteMap(profile));
      }
    } catch (error) {
      lastSyncError = 'User download failed: $error';
      debugPrint('[SafeJalan sync] $lastSyncError');
      notifyListeners();
    }
  }

  Future<void> syncUsers() => _syncAllUsers();

  Future<void> _loadVerifications() async {
    _verifiedReportIds
      ..clear()
      ..addAll(await _database.getVerifiedReportIds(email));
  }

  Future<void> _syncPendingVerifications() async {
    if (!_supabase.isConfigured) return;
    final pending = await _database.getPendingVerifications();
    for (final row in pending) {
      final reportId = row['reportRemoteId'] as String;
      final userEmail = row['userEmail'] as String;
      final isDeleted = (row['isDeleted'] as int? ?? 0) == 1;
      try {
        if (isDeleted) {
          await _supabase.deleteVerification(reportId, userEmail);
        } else {
          await _supabase.upsertVerification(reportId, userEmail);
        }
        await _database.markVerificationSynced(reportId, userEmail, isDeleted);
      } catch (_) {
        // Leave this row pending so the next reconnect can retry it.
      }
    }
    try {
      final remoteRows = await _supabase.getVerifications();
      await _database.mergeRemoteVerifications(remoteRows);
      if (email.isNotEmpty) await _loadVerifications();
    } catch (_) {
      // Keep local verification state if the remote table is unavailable.
    }
  }

  Future<void> _startConnectivityListener() async {
    final connectivity = Connectivity();
    final initial = await connectivity.checkConnectivity();
    _hadNetwork = initial.any((item) => item != ConnectivityResult.none);
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final hasNetwork = results.any((item) => item != ConnectivityResult.none);
      if (hasNetwork && !_hadNetwork) unawaited(_retryPendingData());
      _hadNetwork = hasNetwork;
    });
  }

  Future<void> _retryPendingData() async {
    await syncReports();
    await syncConnectivityReports();
    await syncSafetyAnnouncements();
    await _syncAllUsers();
  }

  Future<void> addConnectivityReport({
    required String issueType,
    required String carrier,
    required String notes,
    required String area,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insertConnectivityReport(
      ConnectivityReport(
        remoteId: _uuid.v4(),
        issueType: issueType,
        carrier: carrier,
        notes: notes,
        area: area,
        reporterEmail: email,
        createdAt: now,
        updatedAt: now,
      ),
    );
    connectivityReports = await _database.getConnectivityReports();
    notifyListeners();
    await syncConnectivityReports();
  }

  Future<void> updateConnectivityStatus(
    ConnectivityReport report,
    String status,
  ) async {
    await _database.updateConnectivityReport(
      report.copyWith(
        status: status,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        syncStatus: 'pending',
      ),
    );
    connectivityReports = await _database.getConnectivityReports();
    notifyListeners();
    await syncConnectivityReports();
  }

  Future<void> deleteConnectivityReport(ConnectivityReport report) async {
    if (report.id == null) return;
    await _database.markConnectivityReportDeleted(report);
    connectivityReports = await _database.getConnectivityReports();
    notifyListeners();
    await syncConnectivityReports();
  }

  Future<void> syncConnectivityReports() async {
    if (!_supabase.isConfigured) return;
    try {
      final pending = await _database.getPendingConnectivityReports();
      for (final report in pending) {
        if (report.id == null) continue;
        if (report.isDeleted) {
          await _supabase.deleteConnectivityReport(report.remoteId);
          await _database.deleteConnectivityReport(report.id!);
        } else {
          await _supabase.upsertConnectivityReport(report);
          await _database.markConnectivityReportSynced(report.id!);
        }
      }
      final remoteReports = await _supabase.getConnectivityReports();
      final remoteIds = <String>{};
      for (final report in remoteReports) {
        remoteIds.add(report.remoteId);
        await _database.upsertRemoteConnectivityReport(report);
      }
      await _database.deleteSyncedConnectivityMissingFromRemote(remoteIds);
      connectivityReports = await _database.getConnectivityReports();
      notifyListeners();
    } catch (_) {
      // SQLite remains available; pending changes retry after reconnect.
    }
  }

  Future<void> addSafetyAnnouncement({
    required String title,
    required String message,
    required String priority,
    required bool isActive,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insertSafetyAnnouncement(
      SafetyAnnouncement(
        remoteId: _uuid.v4(),
        title: title,
        message: message,
        priority: priority,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ),
    );
    announcements = await _database.getSafetyAnnouncements();
    notifyListeners();
    await syncSafetyAnnouncements();
  }

  Future<void> updateSafetyAnnouncement(
    SafetyAnnouncement announcement, {
    required String title,
    required String message,
    required String priority,
    required bool isActive,
  }) async {
    await _database.updateSafetyAnnouncement(
      announcement.copyWith(
        title: title,
        message: message,
        priority: priority,
        isActive: isActive,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
        syncStatus: 'pending',
      ),
    );
    announcements = await _database.getSafetyAnnouncements();
    notifyListeners();
    await syncSafetyAnnouncements();
  }

  Future<void> deleteSafetyAnnouncement(SafetyAnnouncement announcement) async {
    if (announcement.id == null) return;
    await _database.markSafetyAnnouncementDeleted(announcement);
    announcements = await _database.getSafetyAnnouncements();
    notifyListeners();
    await syncSafetyAnnouncements();
  }

  Future<void> syncSafetyAnnouncements() async {
    if (!_supabase.isConfigured) return;
    try {
      final pending = await _database.getPendingSafetyAnnouncements();
      for (final announcement in pending) {
        if (announcement.id == null) continue;
        if (announcement.isDeleted) {
          await _supabase.deleteSafetyAnnouncement(announcement.remoteId);
          await _database.deleteSafetyAnnouncement(announcement.id!);
        } else {
          await _supabase.upsertSafetyAnnouncement(announcement);
          await _database.markSafetyAnnouncementSynced(announcement.id!);
        }
      }
      final remoteAnnouncements = await _supabase.getSafetyAnnouncements();
      final remoteIds = <String>{};
      for (final announcement in remoteAnnouncements) {
        remoteIds.add(announcement.remoteId);
        await _database.upsertRemoteSafetyAnnouncement(announcement);
      }
      await _database.deleteSyncedAnnouncementsMissingFromRemote(remoteIds);
      announcements = await _database.getSafetyAnnouncements();
      notifyListeners();
    } catch (_) {
      // SQLite remains available; pending changes retry after reconnect.
    }
  }

  Future<void> _trySyncUser(UserAccount user, {String? previousEmail}) async {
    if (!_supabase.isConfigured || user.syncStatus != 'pending') return;
    try {
      await _supabase.upsertUserProfile(
        user,
        previousEmail: previousEmail ?? user.previousEmail,
      );
      if (user.id != null) await _database.markUserSynced(user.id!);
      lastSyncError = null;
    } catch (error) {
      lastSyncError = 'User upload failed (${user.email}): $error';
      debugPrint('[SafeJalan sync] $lastSyncError');
      notifyListeners();
      // The local SQLite account remains available if the device is offline.
    }
  }

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final names = <String, String>{};
    final adminEmails = <String>{};

    if (_supabase.isConfigured) {
      try {
        final profiles = await _supabase.getUserProfiles();
        for (final profile in profiles) {
          final email = (profile['email'] as String? ?? '')
              .trim()
              .toLowerCase();
          if (email.isEmpty) continue;
          names[email] = (profile['full_name'] as String? ?? '').trim();
          if (profile['is_admin'] as bool? ?? false) adminEmails.add(email);
        }
      } catch (_) {
        // Continue with SQLite users and locally available reports offline.
      }
    }

    final localUsers = await _database.getUsers();
    for (final user in localUsers) {
      final email = user.email.trim().toLowerCase();
      names[email] = user.name;
      if (user.isAdmin) adminEmails.add(email);
    }

    final reportCounts = <String, int>{};
    final verificationCounts = <String, int>{};
    for (final report in reports) {
      final email = report.reporterEmail.trim().toLowerCase();
      if (email.isEmpty || adminEmails.contains(email)) continue;
      reportCounts[email] = (reportCounts[email] ?? 0) + 1;
      verificationCounts[email] =
          (verificationCounts[email] ?? 0) + report.votes;
      names.putIfAbsent(email, () => email.split('@').first);
    }

    final entries = names.entries
        .where((profile) => !adminEmails.contains(profile.key))
        .map(
          (profile) => LeaderboardEntry(
            name: profile.value.isEmpty
                ? profile.key.split('@').first
                : profile.value,
            email: profile.key,
            reportCount: reportCounts[profile.key] ?? 0,
            verificationCount: verificationCounts[profile.key] ?? 0,
          ),
        )
        .toList();

    entries.sort((first, second) {
      final byPoints = second.points.compareTo(first.points);
      if (byPoints != 0) return byPoints;
      final byReports = second.reportCount.compareTo(first.reportCount);
      if (byReports != 0) return byReports;
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });
    return entries;
  }

  int get points =>
      myReports.length * 80 +
      myReports.fold(0, (sum, item) => sum + item.votes * 5);

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
