import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  static const int _currentDataVersion = 2;
  final DatabaseService _database = DatabaseService.instance;
  final ReportRepository _reportsRepository = ReportRepository();
  List<RoadReport> reports = [];
  String userName = 'New User';
  String email = '';
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
    final prefs = await SharedPreferences.getInstance();

    // Version 2 starts the prototype with no sample or previously cached data.
    if ((prefs.getInt('dataVersion') ?? 0) < _currentDataVersion) {
      await _database.clearReports();
      await prefs.clear();
      await prefs.setInt('dataVersion', _currentDataVersion);
    }

    userName = prefs.getString('name') ?? userName;
    email = prefs.getString('email') ?? email;
    isLoggedIn = prefs.getBool('loggedIn') ?? false;
    reports = await _reportsRepository.getLocalReports();
    isLoading = false;
    notifyListeners();
    await syncReports();
  }

  Future<void> login(String value, {bool admin = false}) async {
    final prefs = await SharedPreferences.getInstance();
    email = value;
    isLoggedIn = true;
    isAdmin = admin;
    await prefs.setString('email', value);
    await prefs.setBool('loggedIn', true);
    notifyListeners();
  }

  Future<void> register(String name, String value) async {
    userName = name;
    email = value;
    await saveProfile(name, value);
    isLoggedIn = true;
    notifyListeners();
  }

  Future<void> saveProfile(String name, String value) async {
    final prefs = await SharedPreferences.getInstance();
    userName = name;
    email = value;
    await prefs.setString('name', name);
    await prefs.setString('email', value);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
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
