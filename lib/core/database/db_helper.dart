import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();
  static Database? _db;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database is not supported on web.');
    }
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'numiit.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        thumbnail_path TEXT NOT NULL,
        scanned_at TEXT NOT NULL,
        primary_script TEXT,
        primary_confidence REAL,
        regions_json TEXT,
        notes TEXT,
        is_saved INTEGER DEFAULT 0,
        is_starred INTEGER DEFAULT 0,
        user_email TEXT DEFAULT 'guest'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE scans ADD COLUMN is_starred INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE scans ADD COLUMN user_email TEXT DEFAULT 'guest'",
      );
    }
  }

  Future<void> clearAll() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('scans');
  }

  Future<int> getScanCount() async {
    if (kIsWeb) return 0;
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM scans');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

