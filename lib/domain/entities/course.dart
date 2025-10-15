class Course {
  const Course({
    required this.id,
    required this.userId,
    required this.name,
    this.color,
    this.externalId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final int? color;
  final String? externalId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Course copyWith({
    String? id,
    String? userId,
    String? name,
    int? color,
    String? externalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      externalId: externalId ?? this.externalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'color': color,
        'externalId': externalId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      color: json['color'] as int?,
      externalId: json['externalId'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}
