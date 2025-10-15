import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/assignment.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../datasources/local/assignment_local_data_source.dart';
import '../datasources/remote/assignment_remote_data_source.dart';
import '../models/assignment_model.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  AssignmentRepositoryImpl({
    required AssignmentLocalDataSource localDataSource,
    required AssignmentRemoteDataSource remoteDataSource,
    required String userId,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _userId = userId;

  final AssignmentLocalDataSource _localDataSource;
  final AssignmentRemoteDataSource _remoteDataSource;
  final String _userId;
  final _logger = Logger('AssignmentRepository');
  final _uuid = const Uuid();

  @override
  Stream<List<Assignment>> watchAssignments() {
    return _localDataSource.watchAssignments();
  }

  @override
  Future<List<Assignment>> fetchAssignments() async {
    return _localDataSource.fetchAssignments();
  }

  @override
  Future<void> upsertAssignments(List<Assignment> assignments) async {
    final models = assignments.map((e) => _toModel(e)).toList();
    await _localDataSource.upsertAssignments(models);
  }

  @override
  Future<void> deleteAssignments(Iterable<String> ids) => _localDataSource.deleteAssignments(ids);

  @override
  Future<void> markStatus(String id, AssignmentStatus status) =>
      _localDataSource.markStatus(id, status.name);

  @override
  Future<void> updateDueDate(String id, DateTime newDueDate) =>
      _localDataSource.updateDueDate(id, newDueDate.toUtc());

  @override
  Future<void> syncFromRemote() async {
    try {
      final remote = await _remoteDataSource.fetchAssignments(_userId);
      await _localDataSource.upsertAssignments(remote);
    } catch (error, stackTrace) {
      _logger.warning('Failed remote sync pull', error, stackTrace);
    }
  }

  @override
  Future<void> syncToRemote() async {
    try {
      final local = await _localDataSource.fetchAssignments();
      await _remoteDataSource.upsertAssignments(local.map(_toModel).toList());
    } catch (error, stackTrace) {
      _logger.warning('Failed remote sync push', error, stackTrace);
    }
  }

  AssignmentModel _toModel(Assignment assignment) {
    final now = DateTime.now().toUtc();
    return AssignmentModel(
      id: assignment.id.isEmpty ? _uuid.v4() : assignment.id,
      userId: assignment.userId.isEmpty ? _userId : assignment.userId,
      courseId: assignment.courseId,
      sourceId: assignment.sourceId,
      title: assignment.title,
      description: assignment.description,
      dueAt: assignment.dueAt.toUtc(),
      allDay: assignment.allDay,
      url: assignment.url,
      location: assignment.location,
      tags: assignment.tags,
      status: assignment.status,
      priority: assignment.priority,
      fingerprint: assignment.fingerprint,
      raw: assignment.raw,
      createdAt: assignment.createdAt,
      updatedAt: now,
    );
  }
}
