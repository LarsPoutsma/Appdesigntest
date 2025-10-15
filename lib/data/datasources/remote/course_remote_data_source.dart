import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/course_model.dart';

class CourseRemoteDataSource {
  CourseRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<CourseModel>> fetchCourses(String userId) async {
    final response = await _client.from('courses').select().eq('user_id', userId);
    return (response as List<dynamic>)
        .map((json) => CourseModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertCourses(List<CourseModel> courses) async {
    final payload = courses.map((e) => e.toMap()).toList();
    await _client.from('courses').upsert(payload);
  }
}
