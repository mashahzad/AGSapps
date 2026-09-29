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
      version: 2, // Incremented version for new table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE family_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relation TEXT NOT NULL,
        work TEXT,
        phone TEXT,
        type TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE family_members (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          relation TEXT NOT NULL,
          work TEXT,
          phone TEXT,
          type TEXT NOT NULL
        )
      ''');
    }
  }

  // Record methods
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

  // Family Members methods
  Future<int> insertFamilyMember(Map<String, String> member) async {
    final db = await instance.database;
    return await db.insert('family_members', member);
  }

  Future<List<Map<String, dynamic>>> getFamilyMembers(String type) async {
    final db = await instance.database;
    return await db.query(
      'family_members',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<int> deleteFamilyMember(int id) async {
    final db = await instance.database;
    return await db.delete(
      'family_members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<String> getFamilyTitle() async {
    final record = await getRecord('family_screen_title');
    if (record != null && record['content'] != null) {
      return record['content'];
    }
    return 'My Family'; // Default fallback title
  }

  Future<void> saveFamilyTitle(String title) async {
    await insertOrUpdateRecord(
      'family_screen_title',
      'Family Screen Title',
      title,
    );
  }
  // Add these methods inside the DatabaseHelper class

  Future<String?> getFamilyBackground() async {
    final record = await getRecord('family_screen_background');
    if (record != null && record['content'] != null) {
      return record['content'];
    }
    return null; // No custom background set
  }

  Future<void> saveFamilyBackground(String imagePath) async {
    await insertOrUpdateRecord(
      'family_screen_background',
      'Family Screen Background',
      imagePath,
    );
  }
}

