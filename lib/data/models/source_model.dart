import 'dart:convert';

import '../../domain/entities/source.dart';

class SourceModel extends SourceConnection {
  SourceModel({
    required super.id,
    required super.userId,
    required super.kind,
    required super.label,
    super.metadata,
    super.status,
    super.lastSyncedAt,
  });

  factory SourceModel.fromMap(Map<String, dynamic> map) {
    return SourceModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      kind: SourceKind.values.firstWhere((element) => element.name == (map['kind'] as String).toLowerCase()),
      label: map['label'] as String,
      metadata: map['metadata'] != null ? jsonDecode(map['metadata'] as String) as Map<String, dynamic> : null,
      status: map['status'] as String? ?? 'idle',
      lastSyncedAt:
          map['last_synced_at'] != null ? DateTime.parse(map['last_synced_at'] as String).toUtc() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'kind': kind.name,
        'label': label,
        'metadata': jsonEncode(metadata ?? {}),
        'status': status,
        'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
      };
}
