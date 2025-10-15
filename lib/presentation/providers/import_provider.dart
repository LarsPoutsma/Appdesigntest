import 'package:flutter/foundation.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/source.dart';
import '../../domain/usecases/normalized_assignment.dart';
import '../../services/import_service.dart';
import 'assignment_provider.dart';
import 'course_provider.dart';
import 'session_provider.dart';

class ImportProvider extends ChangeNotifier {
  ImportProvider(this._session, this._assignmentProvider, this._courseProvider);

  final SessionProvider _session;
  final AssignmentProvider _assignmentProvider;
  final CourseProvider _courseProvider;

  List<NormalizedAssignment> pending = [];
  SourceConnection? source;
  Course? _course;
  bool isProcessing = false;
  Map<String, String> csvMapping = {
    'title': 'Title',
    'dueAt': 'Due Date',
    'course': 'Course',
    'notes': 'Notes',
    'url': 'URL',
  };

  ImportService? get _service => _session.container?.importService;

  Future<void> loadIcs(String content, SourceConnection source) async {
    if (_service == null) {
      return;
    }
    isProcessing = true;
    notifyListeners();
    final payload = await _service!.fromIcs(content, source);
    pending = payload.items;
    this.source = source;
    _course = _courseProvider.courses.isNotEmpty ? _courseProvider.courses.first : null;
    isProcessing = false;
    notifyListeners();
  }

  Future<void> loadCsv(String content, SourceConnection source, Map<String, String> mapping) async {
    if (_service == null) {
      return;
    }
    isProcessing = true;
    notifyListeners();
    final payload = await _service!.fromCsv(content, source, mapping);
    pending = payload.items;
    this.source = source;
    _course = _courseProvider.courses.isNotEmpty ? _courseProvider.courses.first : null;
    isProcessing = false;
    notifyListeners();
  }

  Future<void> loadHtml(String content, SourceConnection source) async {
    if (_service == null) {
      return;
    }
    isProcessing = true;
    notifyListeners();
    final payload = await _service!.fromHtml(content, source);
    pending = payload.items;
    this.source = source;
    _course = _courseProvider.courses.isNotEmpty ? _courseProvider.courses.first : null;
    isProcessing = false;
    notifyListeners();
  }

  Future<void> commit() async {
    if (pending.isEmpty || source == null || _course == null) {
      return;
    }
    isProcessing = true;
    notifyListeners();
    await _assignmentProvider.addFromNormalized(pending, _course!.id, source!.id);
    pending = [];
    isProcessing = false;
    notifyListeners();
  }

  Course? get course => _course;

  void selectCourse(Course course) {
    _course = course;
    notifyListeners();
  }
}
