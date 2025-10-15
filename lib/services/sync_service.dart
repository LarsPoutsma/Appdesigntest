import 'dart:async';

import 'package:logging/logging.dart';
import 'package:workmanager/workmanager.dart';

import '../domain/entities/assignment.dart';
import '../domain/repositories/assignment_repository.dart';
import '../domain/repositories/course_repository.dart';
import '../domain/repositories/source_repository.dart';

class SyncService {
  SyncService({
    required AssignmentRepository assignmentRepository,
    required CourseRepository courseRepository,
    required SourceRepository sourceRepository,
  })  : _assignmentRepository = assignmentRepository,
        _courseRepository = courseRepository,
        _sourceRepository = sourceRepository;

  final AssignmentRepository _assignmentRepository;
  final CourseRepository _courseRepository;
  final SourceRepository _sourceRepository;
  final _logger = Logger('SyncService');

  Future<void> initializeBackgroundSync() async {
    try {
      await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask('sync', 'syncTask', frequency: const Duration(hours: 1));
    } catch (error, stackTrace) {
      _logger.warning('Background sync not available', error, stackTrace);
    }
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      // Background isolates cannot access repositories directly; rely on remote triggers.
      return Future.value(true);
    });
  }

  Future<void> syncNow() async {
    try {
      await _assignmentRepository.syncFromRemote();
      await _courseRepository.sync();
      await _sourceRepository.sync();
    } catch (error, stackTrace) {
      _logger.severe('Sync failed', error, stackTrace);
    }
  }

  Future<void> handleConflict(Assignment local, Assignment remote) async {
    final resolved = local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
    await _assignmentRepository.upsertAssignments([resolved]);
  }
}
