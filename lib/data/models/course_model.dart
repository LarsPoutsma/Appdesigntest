import '../../domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({
    required super.id,
    required super.userId,
    required super.name,
    super.color,
    super.externalId,
    super.createdAt,
    super.updatedAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      color: map['color'] as int?,
      externalId: map['external_id'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String).toUtc() : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String).toUtc() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'color': color,
        'external_id': externalId,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'updated_at': updatedAt?.toUtc().toIso8601String(),
      };
}
