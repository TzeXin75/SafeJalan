import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/report.dart';

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
}
