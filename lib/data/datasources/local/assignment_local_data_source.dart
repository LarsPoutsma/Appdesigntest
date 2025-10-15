import 'dart:async';
import 'dart:convert';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../models/assignment_model.dart';
import 'local_database.dart';

class AssignmentLocalDataSource {
  AssignmentLocalDataSource(this._database)
      : _controller = StreamController<List<AssignmentModel>>.broadcast();

  final LocalDatabase _database;
  final StreamController<List<AssignmentModel>> _controller;

  Future<List<AssignmentModel>> fetchAssignments() async {
    final db = _database.database;
    final rows = await db.query('assignments');
    return rows.map(AssignmentModel.fromMap).toList();
  }

  Stream<List<AssignmentModel>> watchAssignments() async* {
    _controller.add(await fetchAssignments());
    yield* _controller.stream;
  }

  Future<void> upsertAssignments(List<AssignmentModel> assignments) async {
    final db = _database.database;
    final batch = db.batch();
    for (final assignment in assignments) {
      batch.insert(
        'assignments',
        assignment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    _controller.add(await fetchAssignments());
  }

  Future<void> deleteAssignments(Iterable<String> ids) async {
    final db = _database.database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete('assignments', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
    _controller.add(await fetchAssignments());
  }

  Future<void> markStatus(String id, String status) async {
    final db = _database.database;
    await db.update('assignments', {'status': status, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
    _controller.add(await fetchAssignments());
  }

  Future<void> updateDueDate(String id, DateTime dueDate) async {
    final db = _database.database;
    await db.update('assignments', {
      'due_at': dueDate.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
    _controller.add(await fetchAssignments());
  }

  Future<void> cacheReviewPayload(List<Map<String, dynamic>> payload) async {
    final db = _database.database;
    await db.insert(
      'metadata',
      {
        'key': 'review_queue',
        'value': jsonEncode(payload),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> loadReviewPayload() async {
    final db = _database.database;
    final row = await db.query('metadata', where: 'key = ?', whereArgs: ['review_queue']);
    if (row.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(row.first['value'] as String) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
