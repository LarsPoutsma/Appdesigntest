import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/local/course_local_data_source.dart';
import '../datasources/remote/course_remote_data_source.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  CourseRepositoryImpl({
    required CourseLocalDataSource localDataSource,
    required CourseRemoteDataSource remoteDataSource,
    required String userId,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _userId = userId;

  final CourseLocalDataSource _localDataSource;
  final CourseRemoteDataSource _remoteDataSource;
  final String _userId;
  final _logger = Logger('CourseRepository');
  final _uuid = const Uuid();

  @override
  Stream<List<Course>> watchCourses() => _localDataSource.watchCourses();

  @override
  Future<List<Course>> fetchCourses() => _localDataSource.fetchCourses();

  @override
  Future<void> upsertCourse(Course course) async {
    final model = CourseModel(
      id: course.id.isEmpty ? _uuid.v4() : course.id,
      userId: course.userId.isEmpty ? _userId : course.userId,
      name: course.name,
      color: course.color,
      externalId: course.externalId,
      createdAt: course.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _localDataSource.upsertCourse(model);
  }

  @override
  Future<void> deleteCourse(String id) => _localDataSource.deleteCourse(id);

  @override
  Future<void> sync() async {
    try {
      final remote = await _remoteDataSource.fetchCourses(_userId);
      for (final course in remote) {
        await _localDataSource.upsertCourse(course);
      }
    } catch (error, stackTrace) {
      _logger.warning('Failed to sync courses', error, stackTrace);
    }
  }
}
