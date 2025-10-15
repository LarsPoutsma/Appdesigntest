import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../entities/assignment.dart';

class NormalizedAssignment {
  NormalizedAssignment({
    required this.tempId,
    required this.title,
    this.description,
    required this.dueAt,
    this.allDay = false,
    this.courseName,
    this.url,
    this.location,
    this.tags = const [],
    this.raw,
  });

  final String tempId;
  final String title;
  final String? description;
  final DateTime dueAt;
  final bool allDay;
  final String? courseName;
  final String? url;
  final String? location;
  final List<String> tags;
  final Map<String, dynamic>? raw;

  Assignment toAssignment({
    required String userId,
    required String courseId,
    required String sourceId,
  }) {
    return Assignment(
      id: tempId,
      userId: userId,
      courseId: courseId,
      sourceId: sourceId,
      title: title,
      description: description,
      dueAt: dueAt.toUtc(),
      allDay: allDay,
      url: url,
      location: location,
      tags: tags,
      status: AssignmentStatus.pending,
      priority: 0,
      fingerprint: Assignment.computeFingerprint(
        title: title,
        dueAtUtc: dueAt.toUtc(),
        courseName: courseName ?? 'General',
        url: url,
      ),
      raw: raw,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
  }
}

class NormalizationUtils {
  static final _uuid = const Uuid();

  static NormalizedAssignment fromMap(Map<String, dynamic> map, {String timezone = 'America/Denver'}) {
    final due = _parseDueDate(map['dueAt']?.toString(), timezone: timezone);
    return NormalizedAssignment(
      tempId: map['tempId'] as String? ?? _uuid.v4(),
      title: map['title'] as String? ?? 'Untitled Assignment',
      description: map['description'] as String?,
      dueAt: due ?? DateTime.now().toUtc(),
      allDay: map['allDay'] as bool? ?? false,
      courseName: map['courseName'] as String?,
      url: map['url'] as String?,
      location: map['location'] as String?,
      tags: (map['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      raw: map['raw'] as Map<String, dynamic>?,
    );
  }

  static DateTime? _parseDueDate(String? input, {required String timezone}) {
    if (input == null || input.isEmpty) {
      return null;
    }
    final formats = [
      DateFormat('yyyy-MM-ddTHH:mm:ssZ'),
      DateFormat('yyyy-MM-dd HH:mm'),
      DateFormat('MM/dd/yyyy HH:mm'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];
    for (final format in formats) {
      try {
        final dt = format.parseUtc(input);
        return dt.toUtc();
      } catch (_) {
        continue;
      }
    }
    return DateTime.tryParse(input)?.toUtc();
  }
}
