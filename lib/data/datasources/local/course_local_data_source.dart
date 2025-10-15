import 'dart:async';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../models/course_model.dart';
import 'local_database.dart';

class CourseLocalDataSource {
  CourseLocalDataSource(this._database) : _controller = StreamController<List<CourseModel>>.broadcast();

  final LocalDatabase _database;
  final StreamController<List<CourseModel>> _controller;

  Stream<List<CourseModel>> watchCourses() async* {
    _controller.add(await fetchCourses());
    yield* _controller.stream;
  }

  Future<List<CourseModel>> fetchCourses() async {
    final db = _database.database;
    final rows = await db.query('courses');
    return rows.map(CourseModel.fromMap).toList();
  }

  Future<void> upsertCourse(CourseModel course) async {
    final db = _database.database;
    await db.insert('courses', course.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _controller.add(await fetchCourses());
  }

  Future<void> deleteCourse(String id) async {
    final db = _database.database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    _controller.add(await fetchCourses());
  }
}
