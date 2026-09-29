import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../database/database_helper.dart';
import '../services/time_tracker.dart';
import '../widgets/database_grid_tile.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final PageController _pageController = PageController();
  List<Map<String, String>> _notifications = [];
  bool _isLoading = true;

  String _parentName = 'Parent';
  String _parentRelation = 'Parent';
  String _parentWork = 'Not specified';
  String _parentPhone = 'N/A';
  String _parentPrefix = '';

  TimeTracker? _tracker;
  bool _isCurrentUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _parentName = args['name']?.toString() ?? 'Parent';
      _parentRelation = args['relation']?.toString() ?? 'Parent';
      _parentWork = args['work']?.toString() ?? 'Not specified';
      _parentPhone = args['phone']?.toString() ?? 'N/A';
      _isCurrentUser = args['is_current_user']?.toString() == '1';
    } else if (args is String) {
      _parentName = args;
    }

    _parentPrefix = _parentName.toLowerCase().replaceAll(' ', '_');

    if (_tracker == null) {
      _tracker = TimeTracker(_isCurrentUser ? 'me' : 'spouse');
      _tracker!.start();
    }

    _loadNotificationsFromDB();
  }

  @override
  void dispose() {
    _tracker?.stopAndSave();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationsFromDB() async {
    final record = await DatabaseHelper.instance.getRecord('${_parentPrefix}_reminders');
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
          {"title": "$_parentName's Daily Schedule", "subtitle": "Check today's activities and reminders."},
        ];
        _isLoading = false;
      });
      _saveNotificationsToDB();
    }
  }

  Future<void> _saveNotificationsToDB() async {
    final jsonString = jsonEncode(_notifications);
    await DatabaseHelper.instance.insertOrUpdateRecord(
      '${_parentPrefix}_reminders',
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
                  hintText: "e.g., Doctor Appointment",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: "Time / Details",
                  hintText: "e.g., Tomorrow at 10:00 AM",
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
    return Scaffold(
      appBar: AppBar(
        title: Text("$_parentName's Dashboard"),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildMainOverviewPage(),
          _buildRecordMemoriesGrid(),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.question_answer),
            label: 'Q&A and Parental Tips',
            onTap: () => Navigator.pushNamed(context, '/qna'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.article),
            label: 'Blog & Tips',
            onTap: () => Navigator.pushNamed(context, '/blogs', arguments: _parentName),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOverviewPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: _isCurrentUser ? Colors.indigo : Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: $_parentName ${_isCurrentUser ? '(Me)' : ''}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Role: $_parentRelation • $_parentWork",
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        Text(
                          "Phone: $_parentPhone",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
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
                "Schedules & Reminders",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.teal),
                onPressed: () => _addNotificationDialog(context),
                tooltip: "Add Reminder",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? const Center(child: Text("No reminders added yet."))
                : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.teal),
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

  Widget _buildRecordMemoriesGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Records for $_parentName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tap any card below to enter or edit saved details.",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                DatabaseGridTile(
                  recordId: "${_parentPrefix}_general_details",
                  defaultTitle: "General Details",
                  defaultContent: "Tap to enter personal background, occupation, notes",
                  icon: Icons.badge,
                  color: Colors.indigo,
                ),
                DatabaseGridTile(
                  recordId: "${_parentPrefix}_health_history",
                  defaultTitle: "Health & Care",
                  defaultContent: "Tap to enter insurance details, prescriptions, visits",
                  icon: Icons.local_hospital,
                  color: Colors.red,
                ),
                DatabaseGridTile(
                  recordId: "${_parentPrefix}_important_contacts",
                  defaultTitle: "Important Contacts",
                  defaultContent: "Tap to enter work contacts, emergency numbers",
                  icon: Icons.contacts,
                  color: Colors.teal,
                ),
                DatabaseGridTile(
                  recordId: "${_parentPrefix}_notes_goals",
                  defaultTitle: "Notes & Goals",
                  defaultContent: "Tap to enter family goals, tasks, personal notes",
                  icon: Icons.assignment,
                  color: Colors.amber.shade800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}