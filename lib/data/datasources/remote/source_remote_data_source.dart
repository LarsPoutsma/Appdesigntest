import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/source_model.dart';

class SourceRemoteDataSource {
  SourceRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<SourceModel>> fetchSources(String userId) async {
    final response = await _client.from('sources').select().eq('user_id', userId);
    return (response as List<dynamic>)
        .map((json) => SourceModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertSources(List<SourceModel> sources) async {
    final payload = sources.map((e) => e.toMap()).toList();
    await _client.from('sources').upsert(payload);
  }
}
