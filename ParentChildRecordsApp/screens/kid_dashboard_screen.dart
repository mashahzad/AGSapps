import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../database/database_helper.dart';
import '../widgets/database_grid_tile.dart';

class KidDashboardScreen extends StatefulWidget {
  const KidDashboardScreen({Key? key}) : super(key: key);

  @override
  State<KidDashboardScreen> createState() => _KidDashboardScreenState();
}

class _KidDashboardScreenState extends State<KidDashboardScreen> {
  final PageController _pageController = PageController();
  List<Map<String, String>> _notifications = [];
  bool _isLoading = true;
  String _kidPrefix = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final kidName = ModalRoute.of(context)?.settings.arguments as String? ?? "Kid";
    _kidPrefix = kidName.toLowerCase().replaceAll(' ', '_');
    _loadNotificationsFromDB();
  }

  // Load reminders from SQLite database
  Future<void> _loadNotificationsFromDB() async {
    final record = await DatabaseHelper.instance.getRecord('${_kidPrefix}_reminders');
    if (record != null && record['content'] != null) {
      try {
        final List<dynamic> decoded = jsonDecode(record['content']);
        if (mounted) {
          setState(() {
            _notifications = decoded.map((e) => Map<String, String>.from(e)).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        _setDefaultNotifications();
      }
    } else {
      _setDefaultNotifications();
    }
  }

  void _setDefaultNotifications() {
    if (mounted) {
      setState(() {
        _notifications = [
          {"title": "Doctor Appointment", "subtitle": "Tomorrow at 10:00 AM"},
          {"title": "Vaccination Alert", "subtitle": "Due in 5 days"},
        ];
        _isLoading = false;
      });
      _saveNotificationsToDB();
    }
  }

  // Save reminders back to SQLite database
  Future<void> _saveNotificationsToDB() async {
    final jsonString = jsonEncode(_notifications);
    await DatabaseHelper.instance.insertOrUpdateRecord(
      '${_kidPrefix}_reminders',
      'Reminders',
      jsonString,
    );
  }

  void _addNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Notification / Reminder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "e.g., Swim Class",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: "Time / Details",
                  hintText: "e.g., Saturday at 4:00 PM",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    _notifications.add({
                      "title": titleController.text.trim(),
                      "subtitle": subtitleController.text.trim().isEmpty
                          ? "No details"
                          : subtitleController.text.trim(),
                    });
                  });
                  await _saveNotificationsToDB();
                  if (mounted) Navigator.pop(dialogContext);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kidName = ModalRoute.of(context)?.settings.arguments as String? ?? "Kid";

    return Scaffold(
      appBar: AppBar(
        title: Text(kidName),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildMainOverviewPage(context, kidName),
          _buildRecordMemoriesGrid(_kidPrefix, kidName),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.sports_esports),
            label: 'Activities and Stories',
            onTap: () => Navigator.pushNamed(context, '/activities', arguments: kidName),
          ),
          SpeedDialChild(
            child: const Icon(Icons.question_answer),
            label: 'Q&A and Parental Tips',
            onTap: () => Navigator.pushNamed(context, '/qna'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.article),
            label: 'Blog & Tips',
            onTap: () => Navigator.pushNamed(context, '/blogs', arguments: kidName),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOverviewPage(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Name: $name\nAge: 5\nCurrently: At school Tampines (8am-4pm)\nNext: Piano classes at Punggol (5pm-7pm)",
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text("View & Edit Details"),
            ),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Notifications & Reminders",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.indigo),
                onPressed: () => _addNotificationDialog(context),
                tooltip: "Add Notification",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? const Center(child: Text("No notifications added yet."))
                : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.orange),
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['subtitle'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () async {
                        setState(() {
                          _notifications.removeAt(index);
                        });
                        await _saveNotificationsToDB();
                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecordMemoriesGrid(String kidPrefix, String kidName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Record Memories for $kidName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tap any card below to enter or edit saved details.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                DatabaseGridTile(
                  recordId: "${kidPrefix}_general_details",
                  defaultTitle: "General Details",
                  defaultContent: "Tap to enter name, birthdate, nicknames, height & weight",
                  icon: Icons.face,
                  color: Colors.purple,
                ),
                DatabaseGridTile(
                  recordId: "${kidPrefix}_health_history",
                  defaultTitle: "Health History",
                  defaultContent: "Tap to enter Insurance, Allergies, vaccinations, doctor visits",
                  icon: Icons.local_hospital,
                  color: Colors.red,
                ),
                DatabaseGridTile(
                  recordId: "${kidPrefix}_likes_hobbies",
                  defaultTitle: "Likes & Hobbies",
                  defaultContent: "Tap to enter favorite food, sports, pets, spots",
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
                DatabaseGridTile(
                  recordId: "${kidPrefix}_growing_milestones",
                  defaultTitle: "Growing",
                  defaultContent: "Tap to enter first words, school achievements, CCA",
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                DatabaseGridTile(
                  recordId: "${kidPrefix}_transportation",
                  defaultTitle: "Transportation",
                  defaultContent: "Tap to enter mode, driver name, routes, friends",
                  icon: Icons.directions_bus,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}