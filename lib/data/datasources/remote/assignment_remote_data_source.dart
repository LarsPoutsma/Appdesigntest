import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/assignment_model.dart';

class AssignmentRemoteDataSource {
  AssignmentRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<AssignmentModel>> fetchAssignments(String userId) async {
    final response = await _client.from('assignments').select().eq('user_id', userId);
    return (response as List<dynamic>)
        .map((json) => AssignmentModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertAssignments(List<AssignmentModel> assignments) async {
    final payload = assignments.map((e) => e.toMap()).toList();
    await _client.from('assignments').upsert(payload);
  }

  Future<void> deleteAssignments(Iterable<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await _client.from('assignments').delete().in_('id', ids.toList());
  }
}
