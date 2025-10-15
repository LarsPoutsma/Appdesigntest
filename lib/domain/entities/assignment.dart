import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';

class Assignment {
  const Assignment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.sourceId,
    required this.title,
    this.description,
    required this.dueAt,
    this.allDay = false,
    this.url,
    this.location,
    this.tags = const [],
    this.status = AssignmentStatus.pending,
    this.priority = 0,
    required this.fingerprint,
    this.raw,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String courseId;
  final String sourceId;
  final String title;
  final String? description;
  final DateTime dueAt;
  final bool allDay;
  final String? url;
  final String? location;
  final List<String> tags;
  final AssignmentStatus status;
  final int priority;
  final String fingerprint;
  final Map<String, dynamic>? raw;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? sourceId,
    String? title,
    String? description,
    DateTime? dueAt,
    bool? allDay,
    String? url,
    String? location,
    List<String>? tags,
    AssignmentStatus? status,
    int? priority,
    String? fingerprint,
    Map<String, dynamic>? raw,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      allDay: allDay ?? this.allDay,
      url: url ?? this.url,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      fingerprint: fingerprint ?? this.fingerprint,
      raw: raw ?? this.raw,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'courseId': courseId,
        'sourceId': sourceId,
        'title': title,
        'description': description,
        'dueAt': dueAt.toUtc().toIso8601String(),
        'allDay': allDay,
        'url': url,
        'location': location,
        'tags': tags,
        'status': status.name,
        'priority': priority,
        'fingerprint': fingerprint,
        'raw': raw,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      sourceId: json['sourceId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueAt: DateTime.parse(json['dueAt'] as String).toUtc(),
      allDay: json['allDay'] as bool? ?? false,
      url: json['url'] as String?,
      location: json['location'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      status: AssignmentStatus.values.firstWhere((element) => element.name == (json['status'] as String)),
      priority: json['priority'] as int? ?? 0,
      fingerprint: json['fingerprint'] as String,
      raw: (json['raw'] as Map<String, dynamic>?)?.cast<String, dynamic>(),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    );
  }

  static String computeFingerprint({
    required String title,
    required DateTime dueAtUtc,
    required String courseName,
    String? url,
  }) {
    final normalized = [title.toLowerCase().trim(), dueAtUtc.toIso8601String(), courseName.toLowerCase().trim(), url?.trim() ?? ''];
    final digest = sha1.convert(utf8.encode(normalized.join('|')));
    return digest.toString();
  }

  static Assignment merge(Assignment local, Assignment remote) {
    final changedFields = <String, dynamic>{};
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      changedFields.addAll(local.toJson());
    } else {
      changedFields.addAll(remote.toJson());
    }
    return Assignment.fromJson(changedFields);
  }

  @override
  bool operator ==(Object other) {
    return other is Assignment && other.fingerprint == fingerprint;
  }

  @override
  int get hashCode => fingerprint.hashCode;
}

enum AssignmentStatus { pending, done, snoozed }

typedef AssignmentMap = Map<String, Assignment>;

extension AssignmentListExtension on Iterable<Assignment> {
  AssignmentMap get keyedById => {for (final assignment in this) assignment.id: assignment};

  List<Assignment> sortedByDueDate() => toList()
    ..sort((a, b) {
      final dueComparison = a.dueAt.compareTo(b.dueAt);
      if (dueComparison != 0) {
        return dueComparison;
      }
      return a.priority.compareTo(b.priority);
    });

  List<Assignment> whereStatus(AssignmentStatus status) => where((a) => a.status == status).toList();

  List<Assignment> dedupe() {
    final grouped = groupBy(toList(), (Assignment e) => e.fingerprint);
    return grouped.values
        .map((entries) => entries.reduce((value, element) =>
            value.updatedAt.isAfter(element.updatedAt) ? value : element))
        .toList();
  }
}
