import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/report.dart';
import '../models/user_account.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    return openDatabase(
      '${directory.path}/safejalan.db',
      version: 4,
      onCreate: (db, version) async {
        await _createReportsTable(db);
        await _createUserTables(db);
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
      },
    );
  }

  Future<void> _createUserTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        passwordHash TEXT NOT NULL,
        imagePath TEXT,
        isAdmin INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AppSettings(
        settingKey TEXT PRIMARY KEY,
        settingValue TEXT
      )
    ''');
    await db.insert('Users', {
      'name': 'SafeJalan Administrator',
      'email': 'admin@safejalan.my',
      // SHA-256 of Admin123. The demo account can be changed later.
      'passwordHash':
          '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2',
      'isAdmin': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
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

  Future<List<UserAccount>> getUsers() async {
    final rows = await (await database).query(
      'Users',
      where: 'isAdmin = 0',
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(UserAccount.fromMap).toList();
  }

  Future<int> insertUser(UserAccount user) async =>
      (await database).insert('Users', user.toMap());

  Future<void> updateUserProfile(
    int id,
    String name,
    String email,
    String? imagePath,
  ) async {
    await (await database).update(
      'Users',
      {'name': name, 'email': email.toLowerCase(), 'imagePath': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePassword(int id, String passwordHash) async {
    await (await database).update(
      'Users',
      {'passwordHash': passwordHash},
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
}
