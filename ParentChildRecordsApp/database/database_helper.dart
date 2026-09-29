import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('parent_child_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE family_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        relation TEXT,
        work TEXT,
        phone TEXT,
        type TEXT,
        is_current_user TEXT DEFAULT '0'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE family_members ADD COLUMN is_current_user TEXT DEFAULT '0'");
    }
  }

  // --- Family Members CRUD ---
  Future<int> insertFamilyMember(Map<String, dynamic> member) async {
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
    return await db.delete('family_members', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCurrentParentUser(int memberId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'family_members',
        {'is_current_user': '0'},
        where: 'type = ?',
        whereArgs: ['parent'],
      );
      await txn.update(
        'family_members',
        {'is_current_user': '1'},
        where: 'id = ?',
        whereArgs: [memberId],
      );
    });
  }

  // --- App Key-Value Records ---
  Future<void> insertOrUpdateRecord(String id, String title, String content) async {
    final db = await instance.database;
    await db.insert(
      'records',
      {'id': id, 'title': title, 'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getRecord(String id) async {
    final db = await instance.database;
    final results = await db.query('records', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<String> getFamilyTitle() async {
    final record = await getRecord('family_title');
    return record?['content'] ?? 'My Family';
  }

  Future<void> saveFamilyTitle(String title) async {
    await insertOrUpdateRecord('family_title', 'Family Title', title);
  }

  Future<String?> getFamilyBackground() async {
    final record = await getRecord('family_background');
    return record?['content'];
  }

  Future<void> saveFamilyBackground(String path) async {
    await insertOrUpdateRecord('family_background', 'Family Background', path);
  }

  // --- Midnight Reset & Daily Stats ---
  Future<Map<String, dynamic>> getOrResetDailyTimeStats() async {
    final todayStr = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    final record = await getRecord('daily_time_stats');

    if (record == null || record['content'] == null) {
      final defaultStats = {
        'date': todayStr,
        'me_seconds': 100,
        'spouse_seconds': 100,
        'kids_seconds': 100,
        'is_grey_state': 1,
      };
      await insertOrUpdateRecord('daily_time_stats', 'Time Stats', jsonEncode(defaultStats));
      return defaultStats;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(record['content']);
      if (data['date'] != todayStr) {
        final resetStats = {
          'date': todayStr,
          'me_seconds': 100,
          'spouse_seconds': 100,
          'kids_seconds': 100,
          'is_grey_state': 1,
        };
        await insertOrUpdateRecord('daily_time_stats', 'Time Stats', jsonEncode(resetStats));
        return resetStats;
      }
      return data;
    } catch (e) {
      return {
        'date': todayStr,
        'me_seconds': 100,
        'spouse_seconds': 100,
        'kids_seconds': 100,
        'is_grey_state': 1,
      };
    }
  }

  Future<void> accumulateTimeSpent(String category, int elapsedSeconds) async {
    if (elapsedSeconds <= 0) return;

    final currentStats = await getOrResetDailyTimeStats();
    int meSec = currentStats['me_seconds'] ?? 100;
    int spouseSec = currentStats['spouse_seconds'] ?? 100;
    int kidsSec = currentStats['kids_seconds'] ?? 100;

    if (category == 'me') {
      meSec += elapsedSeconds;
    } else if (category == 'spouse') {
      spouseSec += elapsedSeconds;
    } else if (category == 'kids') {
      kidsSec += elapsedSeconds;
    }

    final updatedStats = {
      'date': DateTime.now().toString().split(' ')[0],
      'me_seconds': meSec,
      'spouse_seconds': spouseSec,
      'kids_seconds': kidsSec,
      'is_grey_state': 0,
    };

    await insertOrUpdateRecord('daily_time_stats', 'Time Stats', jsonEncode(updatedStats));
  }
}