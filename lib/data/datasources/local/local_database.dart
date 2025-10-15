import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class LocalDatabase {
  LocalDatabase._(this._database);

  static const _dbName = 'homework_tracker.db';
  static const _dbVersion = 2;
  static LocalDatabase? _instance;

  final Database _database;

  static Future<LocalDatabase> instance({String passphrase = 'change-me'}) async {
    if (_instance != null) {
      return _instance!;
    }
    final documents = await getApplicationDocumentsDirectory();
    final path = join(documents.path, _dbName);
    final db = await openDatabase(
      path,
      password: passphrase,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _instance = LocalDatabase._(db);
    return _instance!;
  }

  Database get database => _database;

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT,
        color INTEGER,
        external_id TEXT,
        created_at TEXT,
        updated_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE sources (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        kind TEXT,
        label TEXT,
        metadata TEXT,
        status TEXT,
        last_synced_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        course_id TEXT,
        source_id TEXT,
        title TEXT,
        description TEXT,
        due_at TEXT,
        all_day INTEGER,
        url TEXT,
        location TEXT,
        tags TEXT,
        status TEXT,
        priority INTEGER,
        fingerprint TEXT,
        raw TEXT,
        created_at TEXT,
        updated_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT
      );
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE assignments ADD COLUMN priority INTEGER DEFAULT 0');
    }
  }

  Future<void> close() async {
    await _database.close();
    _instance = null;
  }
}
