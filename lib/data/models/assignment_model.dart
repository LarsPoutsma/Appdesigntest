import 'dart:convert';

import '../../domain/entities/assignment.dart';

class AssignmentModel extends Assignment {
  AssignmentModel({
    required super.id,
    required super.userId,
    required super.courseId,
    required super.sourceId,
    required super.title,
    super.description,
    required super.dueAt,
    super.allDay,
    super.url,
    super.location,
    super.tags,
    super.status,
    super.priority,
    required super.fingerprint,
    super.raw,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      courseId: map['course_id'] as String,
      sourceId: map['source_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueAt: DateTime.parse(map['due_at'] as String).toUtc(),
      allDay: (map['all_day'] as int? ?? 0) == 1,
      url: map['url'] as String?,
      location: map['location'] as String?,
      tags: map['tags'] != null
          ? (jsonDecode(map['tags'] as String) as List<dynamic>).map((e) => e.toString()).toList()
          : <String>[],
      status: AssignmentStatus.values.firstWhere((element) => element.name == (map['status'] as String)),
      priority: map['priority'] as int? ?? 0,
      fingerprint: map['fingerprint'] as String,
      raw: map['raw'] != null ? (jsonDecode(map['raw'] as String) as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'course_id': courseId,
        'source_id': sourceId,
        'title': title,
        'description': description,
        'due_at': dueAt.toUtc().toIso8601String(),
        'all_day': allDay ? 1 : 0,
        'url': url,
        'location': location,
        'tags': jsonEncode(tags),
        'status': status.name,
        'priority': priority,
        'fingerprint': fingerprint,
        'raw': jsonEncode(raw ?? {}),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };
}
