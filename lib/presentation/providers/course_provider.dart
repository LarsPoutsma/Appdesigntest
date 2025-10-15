import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/course.dart';
import 'session_provider.dart';

class CourseProvider extends ChangeNotifier {
  CourseProvider(this._session) {
    _session.addListener(_handleSessionChange);
    if (!_session.isLoading) {
      _handleSessionChange();
    }
  }

  final SessionProvider _session;
  final _uuid = const Uuid();
  StreamSubscription<List<Course>>? _subscription;
  List<Course> courses = [];

  Future<void> _handleSessionChange() async {
    final container = _session.container;
    if (container == null) {
      return;
    }
    await _subscription?.cancel();
    _subscription = container.courseRepository.watchCourses().listen((event) {
      courses = event;
      notifyListeners();
    });
  }

  Future<void> addCourse(String name) async {
    final container = _session.container;
    if (container == null) {
      return;
    }
    final course = Course(
      id: _uuid.v4(),
      userId: container.userId,
      name: name,
      color: null,
      externalId: null,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await container.courseRepository.upsertCourse(course);
  }

  Future<void> removeCourse(String id) async {
    await _session.container?.courseRepository.deleteCourse(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _session.removeListener(_handleSessionChange);
    super.dispose();
  }
}
