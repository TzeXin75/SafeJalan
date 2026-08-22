import 'package:uuid/uuid.dart';

import '../models/report.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';

class SyncResult {
  final bool remoteEnabled;
  final String? error;

  const SyncResult({required this.remoteEnabled, this.error});

  bool get succeeded => remoteEnabled && error == null;
}

class ReportRepository {
  ReportRepository({DatabaseService? local, SupabaseService? remote})
    : _local = local ?? DatabaseService.instance,
      _remote = remote ?? SupabaseService.instance;

  final DatabaseService _local;
  final SupabaseService _remote;
  static const _uuid = Uuid();

  bool get isRemoteConfigured => _remote.isConfigured;

  Future<List<RoadReport>> getLocalReports() => _local.getReports();

  Future<RoadReport> addReport(RoadReport report) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final pending = report.copyWith(
      remoteId: report.remoteId ?? _uuid.v4(),
      updatedAt: now,
      syncStatus: 'pending',
    );
    final saved = await _local.insertReport(pending);
    await _tryUpload(saved);
    return saved;
  }

  Future<void> updateReport(RoadReport report) async {
    final pending = report.copyWith(
      remoteId: report.remoteId ?? _uuid.v4(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
      syncStatus: 'pending',
    );
    await _local.updateReport(pending);
    await _tryUpload(pending);
  }

  Future<void> deleteReport(RoadReport report) async {
    if (report.id == null) return;
    await _local.markDeleted(report);

    if (!_remote.isConfigured || report.remoteId == null) return;
    try {
      await _remote.deleteReport(report.remoteId!);
      await _local.deleteReport(report.id!);
    } catch (_) {
      // Keep the local tombstone so the delete can be retried later.
    }
  }

  Future<SyncResult> sync() async {
    if (!_remote.isConfigured) {
      return const SyncResult(remoteEnabled: false);
    }

    try {
      final pendingReports = await _local.getPendingReports();
      for (final original in pendingReports) {
        var report = original;
        if (report.remoteId == null || report.updatedAt.isEmpty) {
          report = report.copyWith(
            remoteId: report.remoteId ?? _uuid.v4(),
            updatedAt: report.updatedAt.isEmpty
                ? DateTime.now().toUtc().toIso8601String()
                : report.updatedAt,
          );
          await _local.updateReport(report);
        }
        if (report.id == null) continue;
        if (report.isDeleted) {
          if (report.remoteId != null) {
            await _remote.deleteReport(report.remoteId!);
          }
          await _local.deleteReport(report.id!);
        } else {
          await _remote.upsertReport(report);
          await _local.markSynced(report.id!);
        }
      }

      final remoteReports = await _remote.getReports();
      final remoteIds = <String>{};
      for (final report in remoteReports) {
        remoteIds.add(report.remoteId!);
        await _local.upsertRemoteReport(report);
      }
      await _local.deleteSyncedReportsMissingFromRemote(remoteIds);
      return const SyncResult(remoteEnabled: true);
    } catch (error) {
      return SyncResult(remoteEnabled: true, error: error.toString());
    }
  }

  Future<void> _tryUpload(RoadReport report) async {
    if (!_remote.isConfigured || report.id == null) return;
    try {
      await _remote.upsertReport(report);
      await _local.markSynced(report.id!);
    } catch (_) {
      // SQLite remains the source while offline; the next sync retries it.
    }
  }
}
