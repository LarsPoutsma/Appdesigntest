enum SourceKind { ics, csv, html, api, email }

class SourceConnection {
  const SourceConnection({
    required this.id,
    required this.userId,
    required this.kind,
    required this.label,
    this.metadata,
    this.status = 'idle',
    this.lastSyncedAt,
  });

  final String id;
  final String userId;
  final SourceKind kind;
  final String label;
  final Map<String, dynamic>? metadata;
  final String status;
  final DateTime? lastSyncedAt;

  SourceConnection copyWith({
    String? id,
    String? userId,
    SourceKind? kind,
    String? label,
    Map<String, dynamic>? metadata,
    String? status,
    DateTime? lastSyncedAt,
  }) {
    return SourceConnection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'kind': kind.name,
        'label': label,
        'metadata': metadata,
        'status': status,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };

  factory SourceConnection.fromJson(Map<String, dynamic> json) {
    return SourceConnection(
      id: json['id'] as String,
      userId: json['userId'] as String,
      kind: SourceKind.values.firstWhere((element) => element.name == (json['kind'] as String).toLowerCase()),
      label: json['label'] as String,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.cast<String, dynamic>(),
      status: json['status'] as String? ?? 'idle',
      lastSyncedAt:
          json['lastSyncedAt'] != null ? DateTime.parse(json['lastSyncedAt'] as String).toUtc() : null,
    );
  }
}
