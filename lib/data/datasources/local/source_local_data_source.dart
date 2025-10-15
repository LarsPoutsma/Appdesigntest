import 'dart:async';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../models/source_model.dart';
import 'local_database.dart';

class SourceLocalDataSource {
  SourceLocalDataSource(this._database) : _controller = StreamController<List<SourceModel>>.broadcast();

  final LocalDatabase _database;
  final StreamController<List<SourceModel>> _controller;

  Stream<List<SourceModel>> watchSources() async* {
    _controller.add(await fetchSources());
    yield* _controller.stream;
  }

  Future<List<SourceModel>> fetchSources() async {
    final db = _database.database;
    final rows = await db.query('sources');
    return rows.map(SourceModel.fromMap).toList();
  }

  Future<void> upsertSource(SourceModel source) async {
    final db = _database.database;
    await db.insert('sources', source.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _controller.add(await fetchSources());
  }

  Future<void> deleteSource(String id) async {
    final db = _database.database;
    await db.delete('sources', where: 'id = ?', whereArgs: [id]);
    _controller.add(await fetchSources());
  }
}
