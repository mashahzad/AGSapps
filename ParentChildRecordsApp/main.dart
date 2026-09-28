import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/description_screen.dart';
import 'screens/login_screen.dart';
import 'screens/family_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/kid_dashboard_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/qna_screen.dart';
import 'screens/blogs_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParentKidApp());
}

class ParentKidApp extends StatelessWidget {
  const ParentKidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Child Records App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/description': (context) => const DescriptionScreen(),
        '/login': (context) => const LoginScreen(),
        '/family': (context) => const FamilyScreen(),
        '/parent_dashboard': (context) => const ParentDashboardScreen(),
        '/kid_dashboard': (context) => const KidDashboardScreen(),
        '/activities': (context) => const ActivitiesScreen(),
        '/qna': (context) => const QnAScreen(),
        '/blogs': (context) => const BlogsScreen(),
      },
    );
  }
}



/*
lib/
│
├── main.dart                   # Entry point, app configuration, and routes
│
├── database/
│   └── database_helper.dart    # Database initialization & SQFlite CRUD operations
│
├── models/                     # (Optional) Data classes for Parent, Kid, or Records
│
├── widgets/
│   └── database_grid_tile.dart # Reusable UI widgets like DatabaseGridTile
│
└── screens/                    # Individual screen UI components
    ├── splash_screen.dart
    ├── description_screen.dart
    ├── login_screen.dart
    ├── family_screen.dart
    ├── parent_dashboard_screen.dart
    ├── kid_dashboard_screen.dart
    ├── activities_screen.dart
    ├── qna_screen.dart
    └── blogs_screen.dart
 */

// lib/main.dart

/*
// ==========================================
// LOCAL DATABASE HELPER (SQFlite)
// ==========================================
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParentKidApp());
}

class ParentKidApp extends StatelessWidget {
  const ParentKidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Child Records App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/description': (context) => const DescriptionScreen(),
        '/login': (context) => const LoginScreen(),
        '/family': (context) => const FamilyScreen(),
        '/parent_dashboard': (context) => const ParentDashboardScreen(),
        '/kid_dashboard': (context) => const KidDashboardScreen(),
        '/activities': (context) => const ActivitiesScreen(),
        '/qna': (context) => const QnAScreen(),
        '/blogs': (context) => const BlogsScreen(),
      },
    );
  }
}
*/


/*
// ==========================================
// DATABASE PERSISTENT EDITABLE GRID TILE
// ==========================================
class DatabaseGridTile extends StatefulWidget {
  final String recordId;
  final String defaultTitle;
  final String defaultContent;
  final IconData icon;
  final Color color;

  const DatabaseGridTile({
    Key? key,
    required this.recordId,
    required this.defaultTitle,
    required this.defaultContent,
    required this.icon,
    this.color = Colors.indigo,
  }) : super(key: key);

  @override
  State<DatabaseGridTile> createState() => _DatabaseGridTileState();
}

class _DatabaseGridTileState extends State<DatabaseGridTile> {
  late String content;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final record = await DatabaseHelper.instance.getRecord(widget.recordId);
    if (record != null && mounted) {
      setState(() {
        content = record['content'];
        isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        content = widget.defaultContent;
        isLoading = false;
      });
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Edit ${widget.defaultTitle}"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter updated information...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newContent = controller.text;
                await DatabaseHelper.instance.insertOrUpdateRecord(
                  widget.recordId,
                  widget.defaultTitle,
                  newContent,
                );
                if (mounted) {
                  setState(() {
                    content = newContent;
                  });
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${widget.defaultTitle} saved to database!")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: widget.color, size: 24),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.defaultTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                  content,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/



