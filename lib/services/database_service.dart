import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:safejalan_native/models/connectivity_report.dart';
import 'package:safejalan_native/models/report.dart';
import 'package:safejalan_native/models/safety_announcement.dart';
import 'package:safejalan_native/models/user_account.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;
  static const _legacyAdminEmail = 'admin@safejalan.my';
  static const _defaultAdmins = [
    (
      name: 'Rouyu',
      email: 'rouyu@safejalan.com',
      passwordHash:
          'dfdb0bb0f0df5a02e37e4d44f8641c6979d16015ecbde05dafdb48837a9bb8e6',
    ),
    (
      name: 'Xintong',
      email: 'xintong@safejalan.com',
      passwordHash:
          '90c929a76949ba3fb1c30b76d3fba1b08dca4547bf64ff1218dd13b267aa7375',
    ),
    (
      name: 'Yueshan',
      email: 'yueshan@safejalan.com',
      passwordHash:
          'e88e96f222a162487a916b85eb439308c44d8155355d07507a74903824778d72',
    ),
    (
      name: 'TzeXin',
      email: 'tzexin@safejalan.com',
      passwordHash:
          '47429213bac3e0238cb5bb5b569bd8d669cf8d27175565b045583d6e614ac77c',
    ),
  ];

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    return openDatabase(
      '${directory.path}/safejalan.db',
      version: 9,
      onCreate: (db, version) async {
        await _createReportsTable(db);
        await _createUserTables(db);
        await _createVerificationTable(db);
        await _createConnectivityReportsTable(db);
        await _createSafetyAnnouncementsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE Reports ADD COLUMN remoteId TEXT');
          await db.execute(
            "ALTER TABLE Reports ADD COLUMN updatedAt TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE Reports ADD COLUMN syncStatus TEXT NOT NULL DEFAULT 'pending'",
          );
          await db.execute(
            'ALTER TABLE Reports ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_reports_remote_id ON Reports(remoteId)',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE Reports ADD COLUMN reporterEmail TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 4) await _createUserTables(db);
        if (oldVersion < 5) await _createVerificationTable(db);
        if (oldVersion < 6) {
          await _createConnectivityReportsTable(db);
          await _createSafetyAnnouncementsTable(db);
        }
        if (oldVersion < 8) await _migrateUsersForOfflineSync(db);
        if (oldVersion < 9) await _replaceDefaultAdmins(db);
      },
    );
  }

  Future<void> _createVerificationTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ReportVerifications(
        reportRemoteId TEXT NOT NULL,
        userEmail TEXT NOT NULL COLLATE NOCASE,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        syncStatus TEXT NOT NULL DEFAULT 'pending',
        updatedAt TEXT NOT NULL,
        PRIMARY KEY(reportRemoteId, userEmail)
      )
    ''');
  }

  Future<void> _createConnectivityReportsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ConnectivityReports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT NOT NULL UNIQUE,
        issueType TEXT NOT NULL,
        carrier TEXT NOT NULL,
        notes TEXT NOT NULL,
        area TEXT NOT NULL,
        reporterEmail TEXT NOT NULL COLLATE NOCASE,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createSafetyAnnouncementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS SafetyAnnouncements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        priority TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<Set<String>> getVerifiedReportIds(String userEmail) async {
    if (userEmail.isEmpty) return <String>{};
    final rows = await (await database).query(
      'ReportVerifications',
      columns: ['reportRemoteId'],
      where: 'userEmail = ? COLLATE NOCASE AND isDeleted = 0',
      whereArgs: [userEmail],
    );
    return rows.map((row) => row['reportRemoteId'] as String).toSet();
  }

  Future<bool> toggleReportVerification(
    String reportRemoteId,
    String userEmail,
  ) async {
    final db = await database;
    final rows = await db.query(
      'ReportVerifications',
      where: 'reportRemoteId = ? AND userEmail = ? COLLATE NOCASE',
      whereArgs: [reportRemoteId, userEmail],
      limit: 1,
    );
    final currentlyVerified =
        rows.isNotEmpty && (rows.first['isDeleted'] as int? ?? 0) == 0;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('ReportVerifications', {
      'reportRemoteId': reportRemoteId,
      'userEmail': userEmail.toLowerCase(),
      'isDeleted': currentlyVerified ? 1 : 0,
      'syncStatus': 'pending',
      'updatedAt': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return !currentlyVerified;
  }

  Future<List<Map<String, Object?>>> getPendingVerifications() async =>
      (await database).query(
        'ReportVerifications',
        where: "syncStatus = 'pending'",
      );

  Future<void> markVerificationSynced(
    String reportRemoteId,
    String userEmail,
    bool isDeleted,
  ) async {
    final db = await database;
    if (isDeleted) {
      await db.delete(
        'ReportVerifications',
        where: 'reportRemoteId = ? AND userEmail = ? COLLATE NOCASE',
        whereArgs: [reportRemoteId, userEmail],
      );
      return;
    }
    await db.update(
      'ReportVerifications',
      {'syncStatus': 'synced'},
      where: 'reportRemoteId = ? AND userEmail = ? COLLATE NOCASE',
      whereArgs: [reportRemoteId, userEmail],
    );
  }

  Future<void> mergeRemoteVerifications(
    List<Map<String, dynamic>> remoteRows,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      final localRows = await txn.query('ReportVerifications');
      final pendingKeys = localRows
          .where((row) => row['syncStatus'] == 'pending')
          .map(
            (row) =>
                '${row['reportRemoteId']}|${(row['userEmail'] as String).toLowerCase()}',
          )
          .toSet();
      final remoteKeys = remoteRows
          .map(
            (row) =>
                '${row['report_id']}|${(row['user_email'] as String).toLowerCase()}',
          )
          .toSet();

      for (final row in localRows) {
        final key =
            '${row['reportRemoteId']}|${(row['userEmail'] as String).toLowerCase()}';
        if (row['syncStatus'] == 'synced' && !remoteKeys.contains(key)) {
          await txn.delete(
            'ReportVerifications',
            where: 'reportRemoteId = ? AND userEmail = ? COLLATE NOCASE',
            whereArgs: [row['reportRemoteId'], row['userEmail']],
          );
        }
      }

      for (final row in remoteRows) {
        final email = (row['user_email'] as String).toLowerCase();
        final key = '${row['report_id']}|$email';
        if (pendingKeys.contains(key)) continue;
        await txn.insert('ReportVerifications', {
          'reportRemoteId': row['report_id'],
          'userEmail': email,
          'isDeleted': 0,
          'syncStatus': 'synced',
          'updatedAt':
              row['created_at'] as String? ??
              DateTime.now().toUtc().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> _createUserTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        passwordHash TEXT NOT NULL,
        imagePath TEXT,
        isAdmin INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        syncStatus TEXT NOT NULL DEFAULT 'pending',
        updatedAt TEXT NOT NULL,
        previousEmail TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AppSettings(
        settingKey TEXT PRIMARY KEY,
        settingValue TEXT
      )
    ''');
    await _seedDefaultAdmins(db);
  }

  Future<void> _migrateUsersForOfflineSync(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'Users'",
    );
    if (tables.isEmpty) {
      await _createUserTables(db);
      return;
    }
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AppSettings(
        settingKey TEXT PRIMARY KEY,
        settingValue TEXT
      )
    ''');
    final columns = (await db.rawQuery(
      'PRAGMA table_info(Users)',
    )).map((row) => row['name'] as String).toSet();
    if (!columns.contains('passwordHash')) {
      await db.execute(
        "ALTER TABLE Users ADD COLUMN passwordHash TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!columns.contains('isActive')) {
      await db.execute(
        'ALTER TABLE Users ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!columns.contains('syncStatus')) {
      await db.execute(
        "ALTER TABLE Users ADD COLUMN syncStatus TEXT NOT NULL DEFAULT 'pending'",
      );
    }
    if (!columns.contains('updatedAt')) {
      await db.execute(
        "ALTER TABLE Users ADD COLUMN updatedAt TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!columns.contains('previousEmail')) {
      await db.execute('ALTER TABLE Users ADD COLUMN previousEmail TEXT');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update('Users', {
      'updatedAt': now,
      'syncStatus': 'pending',
    }, where: "updatedAt = ''");
    await _seedDefaultAdmins(db);
  }

  Future<void> _replaceDefaultAdmins(Database db) async {
    await db.delete(
      'Users',
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [_legacyAdminEmail],
    );
    await _seedDefaultAdmins(db);
  }

  Future<void> _seedDefaultAdmins(Database db) async {
    final now = DateTime.now().toUtc().toIso8601String();
    for (final admin in _defaultAdmins) {
      await db.insert('Users', {
        'name': admin.name,
        'email': admin.email,
        'passwordHash': admin.passwordHash,
        'isAdmin': 1,
        'isActive': 1,
        'syncStatus': 'pending',
        'updatedAt': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await db.update(
        'Users',
        {
          'name': admin.name,
          'passwordHash': admin.passwordHash,
          'isAdmin': 1,
          'isActive': 1,
          'syncStatus': 'pending',
          'updatedAt': now,
          'previousEmail': null,
        },
        where: 'email = ? COLLATE NOCASE',
        whereArgs: [admin.email],
      );
    }
  }

  Future<UserAccount?> findUserByEmail(String email) async {
    final rows = await (await database).query(
      'Users',
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [email.trim()],
      limit: 1,
    );
    return rows.isEmpty ? null : UserAccount.fromMap(rows.first);
  }

  Future<UserAccount?> findUserById(int id) async {
    final rows = await (await database).query(
      'Users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : UserAccount.fromMap(rows.first);
  }

  Future<List<UserAccount>> getUsers({bool includeInactive = false}) async {
    final rows = await (await database).query(
      'Users',
      where: includeInactive ? null : 'isActive = 1',
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(UserAccount.fromMap).toList();
  }

  Future<int> getRegularUserCount() async {
    final result = await (await database).rawQuery(
      'SELECT COUNT(*) AS total FROM Users WHERE isAdmin = 0 AND isActive = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> insertUser(UserAccount user) async =>
      (await database).insert('Users', user.toMap()..remove('id'));

  Future<void> upsertRemoteUser(UserAccount remoteUser) async {
    final db = await database;
    final local = await findUserByEmail(remoteUser.email);
    if (local != null && local.syncStatus == 'pending') return;
    final values = remoteUser.toMap()
      ..remove('id')
      ..['syncStatus'] = 'synced'
      ..['previousEmail'] = null;
    if (local == null) {
      await db.insert(
        'Users',
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.update('Users', values, where: 'id = ?', whereArgs: [local.id]);
    }
  }

  Future<void> markUserSynced(int id) async {
    await (await database).update(
      'Users',
      {'syncStatus': 'synced', 'previousEmail': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUserProfile(
    int id,
    String name,
    String email,
    String? imagePath,
  ) async {
    final current = await findUserById(id);
    final normalizedEmail = email.toLowerCase();
    await (await database).update(
      'Users',
      {
        'name': name,
        'email': normalizedEmail,
        'imagePath': imagePath,
        'syncStatus': 'pending',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'previousEmail': normalizedEmail == current?.email.toLowerCase()
            ? null
            : current?.email.toLowerCase(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePassword(int id, String passwordHash) async {
    await (await database).update(
      'Users',
      {
        'passwordHash': passwordHash,
        'syncStatus': 'pending',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateManagedUser(
    int id,
    String name,
    String email,
    bool isAdmin,
  ) async {
    final user = await findUserById(id);
    if (user == null) return;
    await (await database).update(
      'Users',
      {
        'name': name,
        'email': email.toLowerCase(),
        'isAdmin': isAdmin ? 1 : 0,
        'syncStatus': 'pending',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'previousEmail': user.email.toLowerCase() == email.toLowerCase()
            ? null
            : user.email.toLowerCase(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    if (user.email.toLowerCase() != email.toLowerCase()) {
      await changeReportOwner(user.email, email);
    }
  }

  Future<void> deactivateUser(int id) async {
    await (await database).update(
      'Users',
      {
        'isActive': 0,
        'syncStatus': 'pending',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> changeReportOwner(String oldEmail, String newEmail) async {
    await (await database).update(
      'Reports',
      {
        'reporterEmail': newEmail.toLowerCase(),
        'syncStatus': 'pending',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'reporterEmail = ? COLLATE NOCASE',
      whereArgs: [oldEmail],
    );
  }

  Future<void> saveSignedInUser(int? userId) async {
    final db = await database;
    if (userId == null) {
      await db.delete(
        'AppSettings',
        where: 'settingKey = ?',
        whereArgs: ['signedInUserId'],
      );
    } else {
      await db.insert('AppSettings', {
        'settingKey': 'signedInUserId',
        'settingValue': '$userId',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<UserAccount?> getSignedInUser() async {
    final rows = await (await database).query(
      'AppSettings',
      where: 'settingKey = ?',
      whereArgs: ['signedInUserId'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final id = int.tryParse(rows.first['settingValue'] as String? ?? '');
    return id == null ? null : findUserById(id);
  }

  Future<void> _createReportsTable(Database db) async {
    await db.execute('''
      CREATE TABLE Reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT UNIQUE,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        severity TEXT NOT NULL,
        description TEXT NOT NULL,
        locationName TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        status TEXT NOT NULL,
        imagePath TEXT,
        votes INTEGER NOT NULL,
        createdOn TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        reporterEmail TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<List<RoadReport>> getReports() async {
    final rows = await (await database).query(
      'Reports',
      where: 'isDeleted = 0',
      orderBy: 'id DESC',
    );
    return rows.map(RoadReport.fromLocalMap).toList();
  }

  Future<List<RoadReport>> getPendingReports() async {
    final rows = await (await database).query(
      'Reports',
      where: "syncStatus = 'pending'",
    );
    return rows.map(RoadReport.fromLocalMap).toList();
  }

  Future<RoadReport> insertReport(RoadReport report) async {
    final id = await (await database).insert('Reports', report.toLocalMap());
    return report.copyWith(id: id);
  }

  Future<void> updateReport(RoadReport report) async {
    await (await database).update(
      'Reports',
      report.toLocalMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<void> markSynced(int id) async {
    await (await database).update(
      'Reports',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertRemoteReport(RoadReport report) async {
    final db = await database;
    final existingRows = await db.query(
      'Reports',
      where: 'remoteId = ?',
      whereArgs: [report.remoteId],
      limit: 1,
    );

    if (existingRows.isEmpty) {
      await db.insert('Reports', report.toLocalMap());
      return;
    }

    final existing = RoadReport.fromLocalMap(existingRows.first);
    final merged = report.copyWith(
      id: existing.id,
      imagePath: report.imagePath ?? existing.imagePath,
      syncStatus: 'synced',
    );
    await updateReport(merged);
  }

  Future<void> deleteSyncedReportsMissingFromRemote(
    Set<String> remoteIds,
  ) async {
    final db = await database;
    if (remoteIds.isEmpty) {
      await db.delete('Reports', where: "syncStatus = 'synced'");
      return;
    }

    final placeholders = List.filled(remoteIds.length, '?').join(',');
    await db.delete(
      'Reports',
      where: "syncStatus = 'synced' AND remoteId NOT IN ($placeholders)",
      whereArgs: remoteIds.toList(),
    );
  }

  Future<void> deleteReport(int id) async {
    await (await database).delete('Reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markDeleted(RoadReport report) async {
    await updateReport(
      report.copyWith(
        isDeleted: true,
        syncStatus: 'pending',
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<void> clearReports() async {
    await (await database).delete('Reports');
  }

  Future<List<ConnectivityReport>> getConnectivityReports() async {
    final rows = await (await database).query(
      'ConnectivityReports',
      where: 'isDeleted = 0',
      orderBy: 'createdAt DESC',
    );
    return rows.map(ConnectivityReport.fromLocalMap).toList();
  }

  Future<List<ConnectivityReport>> getPendingConnectivityReports() async {
    final rows = await (await database).query(
      'ConnectivityReports',
      where: "syncStatus = 'pending'",
    );
    return rows.map(ConnectivityReport.fromLocalMap).toList();
  }

  Future<ConnectivityReport> insertConnectivityReport(
    ConnectivityReport report,
  ) async {
    final id = await (await database).insert(
      'ConnectivityReports',
      report.toLocalMap(),
    );
    return report.copyWith(id: id);
  }

  Future<void> updateConnectivityReport(ConnectivityReport report) async {
    await (await database).update(
      'ConnectivityReports',
      report.toLocalMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<void> markConnectivityReportSynced(int id) async {
    await (await database).update(
      'ConnectivityReports',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markConnectivityReportDeleted(ConnectivityReport report) async {
    await updateConnectivityReport(
      report.copyWith(
        isDeleted: true,
        syncStatus: 'pending',
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<void> deleteConnectivityReport(int id) async {
    await (await database).delete(
      'ConnectivityReports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertRemoteConnectivityReport(ConnectivityReport report) async {
    final db = await database;
    final rows = await db.query(
      'ConnectivityReports',
      where: 'remoteId = ?',
      whereArgs: [report.remoteId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await db.insert('ConnectivityReports', report.toLocalMap());
      return;
    }
    final existing = ConnectivityReport.fromLocalMap(rows.first);
    if (existing.syncStatus == 'pending') return;
    await updateConnectivityReport(
      report.copyWith(id: existing.id, syncStatus: 'synced'),
    );
  }

  Future<void> deleteSyncedConnectivityMissingFromRemote(
    Set<String> remoteIds,
  ) async {
    final db = await database;
    if (remoteIds.isEmpty) {
      await db.delete('ConnectivityReports', where: "syncStatus = 'synced'");
      return;
    }
    final placeholders = List.filled(remoteIds.length, '?').join(',');
    await db.delete(
      'ConnectivityReports',
      where: "syncStatus = 'synced' AND remoteId NOT IN ($placeholders)",
      whereArgs: remoteIds.toList(),
    );
  }

  Future<List<SafetyAnnouncement>> getSafetyAnnouncements() async {
    final rows = await (await database).query(
      'SafetyAnnouncements',
      where: 'isDeleted = 0',
      orderBy: 'createdAt DESC',
    );
    return rows.map(SafetyAnnouncement.fromLocalMap).toList();
  }

  Future<List<SafetyAnnouncement>> getPendingSafetyAnnouncements() async {
    final rows = await (await database).query(
      'SafetyAnnouncements',
      where: "syncStatus = 'pending'",
    );
    return rows.map(SafetyAnnouncement.fromLocalMap).toList();
  }

  Future<SafetyAnnouncement> insertSafetyAnnouncement(
    SafetyAnnouncement announcement,
  ) async {
    final id = await (await database).insert(
      'SafetyAnnouncements',
      announcement.toLocalMap(),
    );
    return announcement.copyWith(id: id);
  }

  Future<void> updateSafetyAnnouncement(SafetyAnnouncement announcement) async {
    await (await database).update(
      'SafetyAnnouncements',
      announcement.toLocalMap(),
      where: 'id = ?',
      whereArgs: [announcement.id],
    );
  }

  Future<void> markSafetyAnnouncementSynced(int id) async {
    await (await database).update(
      'SafetyAnnouncements',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSafetyAnnouncementDeleted(
    SafetyAnnouncement announcement,
  ) async {
    await updateSafetyAnnouncement(
      announcement.copyWith(
        isDeleted: true,
        syncStatus: 'pending',
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<void> deleteSafetyAnnouncement(int id) async {
    await (await database).delete(
      'SafetyAnnouncements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertRemoteSafetyAnnouncement(
    SafetyAnnouncement announcement,
  ) async {
    final db = await database;
    final rows = await db.query(
      'SafetyAnnouncements',
      where: 'remoteId = ?',
      whereArgs: [announcement.remoteId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await db.insert('SafetyAnnouncements', announcement.toLocalMap());
      return;
    }
    final existing = SafetyAnnouncement.fromLocalMap(rows.first);
    if (existing.syncStatus == 'pending') return;
    await updateSafetyAnnouncement(
      announcement.copyWith(id: existing.id, syncStatus: 'synced'),
    );
  }

  Future<void> deleteSyncedAnnouncementsMissingFromRemote(
    Set<String> remoteIds,
  ) async {
    final db = await database;
    if (remoteIds.isEmpty) {
      await db.delete('SafetyAnnouncements', where: "syncStatus = 'synced'");
      return;
    }
    final placeholders = List.filled(remoteIds.length, '?').join(',');
    await db.delete(
      'SafetyAnnouncements',
      where: "syncStatus = 'synced' AND remoteId NOT IN ($placeholders)",
      whereArgs: remoteIds.toList(),
    );
  }
}
