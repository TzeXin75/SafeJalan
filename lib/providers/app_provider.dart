import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_account.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _database = DatabaseService.instance;
  final ReportRepository _reportsRepository = ReportRepository();
  List<RoadReport> reports = [];
  String userName = 'New User';
  String email = '';
  String? profileImagePath;
  int? currentUserId;
  bool isLoggedIn = false, isAdmin = false, isLoading = true;
  bool isSyncing = false;
  String? lastSyncError;

  bool get isRemoteConfigured => _reportsRepository.isRemoteConfigured;
  List<RoadReport> get myReports => reports
      .where(
        (report) =>
            report.reporterEmail.isEmpty || report.reporterEmail == email,
      )
      .toList();

  Future<void> initialise() async {
    final signedInUser = await _database.getSignedInUser();
    if (signedInUser != null) _applyUser(signedInUser);
    reports = await _reportsRepository.getLocalReports();
    isLoading = false;
    notifyListeners();
    await syncReports();
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
    final user = await _database.findUserByEmail(value);
    if (user == null || user.passwordHash != _hashPassword(password)) {
      return 'Incorrect email or password';
    }
    if (user.isAdmin != admin) {
      return admin
          ? 'This is not an administrator account'
          : 'Use Admin Login for this account';
    }
    _applyUser(user);
    await _database.saveSignedInUser(user.id);
    notifyListeners();
    return null;
  }

  Future<String?> register(String name, String value, String password) async {
    if (await _database.findUserByEmail(value) != null) {
      return 'This email is already registered';
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
      if (user == null) return 'Unable to create account';
      _applyUser(user);
      await _database.saveSignedInUser(id);
      notifyListeners();
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
    await _database.updatePassword(user.id!, _hashPassword(newPassword));
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

  Future<void> vote(RoadReport report) async {
    await _reportsRepository.updateReport(
      report.copyWith(votes: report.votes + 1),
    );
    reports = await _reportsRepository.getLocalReports();
    notifyListeners();
    await syncReports();
  }

  Future<void> deleteReport(RoadReport report) async {
    await _reportsRepository.deleteReport(report);
    reports = await _reportsRepository.getLocalReports();
    notifyListeners();
    await syncReports();
  }

  Future<void> syncReports() async {
    if (isSyncing) return;
    isSyncing = true;
    notifyListeners();
    final result = await _reportsRepository.sync();
    lastSyncError = result.error;
    reports = await _reportsRepository.getLocalReports();
    isSyncing = false;
    notifyListeners();
  }

  int get points =>
      myReports.length * 80 +
      myReports.fold(0, (sum, item) => sum + item.votes * 5);
}
