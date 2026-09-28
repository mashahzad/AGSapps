// lib/database/database_helper.dart
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbDirectory = await getDatabasesPath();
    final fullPath = path.join(dbDirectory, filePath);

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_records (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertOrUpdateRecord(String id, String title, String content) async {
    final db = await instance.database;
    return await db.insert(
      'app_records',
      {'id': id, 'title': title, 'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getRecord(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'app_records',
      columns: ['id', 'title', 'content'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }
}