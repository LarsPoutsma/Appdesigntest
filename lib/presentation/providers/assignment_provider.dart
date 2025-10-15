import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/assignment.dart';
import '../../domain/usecases/normalized_assignment.dart';
import '../../services/notification_service.dart';
import 'session_provider.dart';

class AssignmentProvider extends ChangeNotifier {
  AssignmentProvider(this._session) {
    _session.addListener(_handleSessionChange);
    if (!_session.isLoading) {
      _handleSessionChange();
    }
  }

  final SessionProvider _session;
  final _uuid = const Uuid();
  List<Assignment> _assignments = [];
  StreamSubscription<List<Assignment>>? _subscription;
  bool isBusy = false;

  List<Assignment> get assignments => _assignments;

  Future<void> _handleSessionChange() async {
    if (_session.container == null) {
      return;
    }
    await _subscription?.cancel();
    _subscription = _session.container!.assignmentRepository.watchAssignments().listen((event) {
      _assignments = event.sortedByDueDate();
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    await _session.container?.assignmentRepository.syncFromRemote();
  }

  Future<void> addFromNormalized(List<NormalizedAssignment> items, String courseId, String sourceId) async {
    if (_session.container == null) {
      return;
    }
    final now = DateTime.now().toUtc();
    final assignments = items
        .map((item) => item.toAssignment(
              userId: _session.container!.userId,
              courseId: courseId,
              sourceId: sourceId,
            )
            .copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now))
        .toList();
    await _session.container!.assignmentRepository.upsertAssignments(assignments);
    await _session.container!.assignmentRepository.syncToRemote();
    await _scheduleReminders(assignments);
  }

  Future<void> markDone(String id) async {
    await _session.container?.assignmentRepository.markStatus(id, AssignmentStatus.done);
    final assignment = _assignments.firstWhere((element) => element.id == id);
    await NotificationService.instance?.cancelReminder(assignment.id);
  }

  Future<void> snooze(String id, Duration duration) async {
    final assignment = _assignments.firstWhere((element) => element.id == id);
    final newDue = assignment.dueAt.add(duration);
    await _session.container?.assignmentRepository.updateDueDate(id, newDue);
    await NotificationService.instance?.scheduleReminder(assignment.copyWith(dueAt: newDue), const Duration(hours: 2));
  }

  Future<void> scheduleDefaultReminders() async {
    final service = NotificationService.instance;
    if (service == null) {
      return;
    }
    for (final assignment in _assignments) {
      await service.scheduleReminder(assignment, const Duration(hours: 24));
      await service.scheduleReminder(assignment, const Duration(hours: 2));
    }
  }

  Future<void> _scheduleReminders(List<Assignment> assignments) async {
    final service = NotificationService.instance;
    if (service == null) {
      return;
    }
    for (final assignment in assignments) {
      await service.scheduleReminder(assignment, const Duration(hours: 24));
      await service.scheduleReminder(assignment, const Duration(hours: 2));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _session.removeListener(_handleSessionChange);
    super.dispose();
  }
}
