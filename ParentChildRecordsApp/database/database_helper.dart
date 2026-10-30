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
      version: 3,
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
        is_current_user INTEGER,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        me_seconds INTEGER,
        spouse_seconds INTEGER,
        kids_seconds INTEGER,
        total_time INTEGER,
        is_grey_state INTEGER
      )
    ''');

    // NEW: Weekly Reports Table
    await db.execute('''
      CREATE TABLE weekly_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER,
        week_number INTEGER,
        memories_count INTEGER DEFAULT 0,
        tasks_completed INTEGER DEFAULT 0,
        tasks_incomplete INTEGER DEFAULT 0,
        me_seconds INTEGER DEFAULT 0,
        spouse_seconds INTEGER DEFAULT 0,
        kids_seconds INTEGER DEFAULT 0,
        time_bias TEXT DEFAULT 'perfect',
        UNIQUE(year, week_number)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE family_members ADD COLUMN is_current_user TEXT DEFAULT '0'");
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT UNIQUE,
          me_seconds INTEGER,
          spouse_seconds INTEGER,
          kids_seconds INTEGER,
          total_time INTEGER,
          is_grey_state INTEGER
        )
      ''');
      if (oldVersion < 4) {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS weekly_reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          year INTEGER,
          week_number INTEGER,
          memories_count INTEGER DEFAULT 0,
          tasks_completed INTEGER DEFAULT 0,
          tasks_incomplete INTEGER DEFAULT 0,
          me_seconds INTEGER DEFAULT 0,
          spouse_seconds INTEGER DEFAULT 0,
          kids_seconds INTEGER DEFAULT 0,
          time_bias TEXT DEFAULT 'perfect',
          UNIQUE(year, week_number)
        )
      ''');
      }
    }
  }

  // --- Weekly Reports & Task Tracking Methods ---
  int _calculateWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  Future<void> trackTaskCompletion(bool isCompleted) async {
    final db = await database;
    final now = DateTime.now();
    final year = now.year;
    final weekNumber = _calculateWeekNumber(now);

    // Upsert weekly report tracking data
    await db.rawInsert('''
      INSERT INTO weekly_reports (year, week_number, tasks_completed, tasks_incomplete)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(year, week_number) DO UPDATE SET
      tasks_completed = tasks_completed + ?,
      tasks_incomplete = tasks_incomplete + ?
    ''', [
      year,
      weekNumber,
      isCompleted ? 1 : 0,
      isCompleted ? 0 : 1,
      isCompleted ? 1 : 0,
      isCompleted ? 0 : 1,
    ]);
  }

  Future<List<Map<String, dynamic>>> getWeeklyReportsForYear(int year) async {
    final db = await database;
    return await db.query(
      'weekly_reports',
      where: 'year = ?',
      whereArgs: [year],
      orderBy: 'week_number ASC',
    );
  }

  // --- Dashboard Updates ---
  Future<int> updateFamilyMember(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update(
      'family_members',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Historical Stats Query ---
  Future<List<Map<String, dynamic>>> getPast7DaysStats() async {
    final db = await database;
    final todayStr = DateTime.now().toString().split(' ')[0];
    final result = await db.rawQuery('''
      SELECT * FROM daily_stats 
      WHERE date != ?
      ORDER BY date DESC 
      LIMIT 7
    ''', [todayStr]);
    return result;
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

  // --- Streamlined Daily Stats (Using daily_stats table exclusively) ---
  Future<Map<String, dynamic>> getOrResetDailyTimeStats() async {
    final db = await database;
    final todayStr = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

    // Check if today's record already exists in daily_stats
    final maps = await db.query(
      'daily_stats',
      where: 'date = ?',
      whereArgs: [todayStr],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }

    // If day changed, grab the most recent record or check if we need to archive/reset
    // Let's check what the latest entry was before today
    final lastRecords = await db.query(
      'daily_stats',
      orderBy: 'date DESC',
      limit: 1,
    );

    if (lastRecords.isNotEmpty) {
      // Ensure the last active day's ending stats are securely committed
      // (They are already stored as time accumulated, so we just let a fresh row initialize for today)
    }

    // Initialize fresh default stats for the new day
    final defaultStats = {
      'date': todayStr,
      'me_seconds': 100,
      'spouse_seconds': 100,
      'kids_seconds': 100,
      'total_time': 300,
      'is_grey_state': 1,
    };

    await db.insert(
      'daily_stats',
      defaultStats,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return defaultStats;
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

    final todayStr = DateTime.now().toString().split(' ')[0];
    final totalTime = meSec + spouseSec + kidsSec;

    final db = await database;
    await db.insert(
      'daily_stats',
      {
        'date': todayStr,
        'me_seconds': meSec,
        'spouse_seconds': spouseSec,
        'kids_seconds': kidsSec,
        'total_time': totalTime,
        'is_grey_state': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /*
  // =========================================================================
  // ISOLATED TEST HELPER: REMOVE THIS METHOD AND CALL AFTER TESTING
  // =========================================================================
  Future<void> insertMock7DaysDataForTesting() async {
    final db = await database;

    await db.delete('daily_stats');

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final pastDate = now.subtract(Duration(days: i));
      final dateString =
          "${pastDate.year}-${pastDate.month.toString().padLeft(2, '0')}-${pastDate.day.toString().padLeft(2, '0')}";

      await db.insert(
        'daily_stats',
        {
          'date': dateString,
          'me_seconds': 1200 + (i * 150),
          'spouse_seconds': 900 + (i * 100),
          'kids_seconds': 1500 + (i * 200),
          'total_time': 3600 + (i * 450),
          'is_grey_state': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
// =========================================================================
*/
}