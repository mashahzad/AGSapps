import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../services/time_tracker.dart';
import '../widgets/database_grid_tile.dart';

class KidDashboardScreen extends StatefulWidget {
  const KidDashboardScreen({super.key});

  @override
  State<KidDashboardScreen> createState() => _KidDashboardScreenState();
}

class _KidDashboardScreenState extends State<KidDashboardScreen> {
  final PageController _pageController = PageController();
  List<Map<String, String>> _notifications = [];
  bool _isLoading = true;
  String _kidPrefix = '';

  int? _kidId;
  String _kidName = 'Kid';
  String _kidAge = 'Not specified';
  String? _imagePath;

  TimeTracker? _tracker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _kidId = args['id'] as int?;
      _kidName = args['name']?.toString() ?? 'Kid';
      _kidAge = args['age']?.toString() ?? 'Not specified';
      _imagePath = args['image_path']?.toString();
    } else if (args is String) {
      _kidName = args;
    }

    _kidPrefix = _kidName.toLowerCase().replaceAll(' ', '_');

    if (_tracker == null) {
      _tracker = TimeTracker('kids');
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
          {"title": "$_kidName's Daily Schedule", "subtitle": "Check today's activities and reminders."},
        ];
        _isLoading = false;
      });
      _saveNotificationsToDB();
    }
  }

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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _kidName);
    final ageController = TextEditingController(text: _kidAge);
    String? tempImagePath = _imagePath;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Child Profile"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.pink.shade100,
                            backgroundImage: (tempImagePath != null && tempImagePath!.isNotEmpty)
                                ? FileImage(File(tempImagePath!)) as ImageProvider
                                : null,
                            child: (tempImagePath == null || tempImagePath!.isEmpty)
                                ? const Icon(Icons.child_care, size: 40, color: Colors.pink)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                );
                                if (image != null) {
                                  setDialogState(() {
                                    tempImagePath = image.path;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.pink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Child Name"),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(labelText: "Age / Details"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty && _kidId != null) {
                      final updatedData = {
                        'id': _kidId!,
                        'name': nameController.text.trim(),
                        'relation': 'Child',
                        'work': ageController.text.trim(),
                        'phone': 'N/A',
                        'type': 'kid',
                        'is_current_user': 0,
                        'image_path': tempImagePath ?? '',
                      };

                      await DatabaseHelper.instance.updateFamilyMember(updatedData);

                      setState(() {
                        _kidName = updatedData['name'] as String;
                        _kidAge = updatedData['work'] as String;
                        _imagePath = updatedData['image_path'] as String;
                        _kidPrefix = _kidName.toLowerCase().replaceAll(' ', '_');
                      });

                      if (mounted) {
                        Navigator.pop(dialogContext); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Saved! Refresh page to view changes"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_kidName's Dashboard"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditProfileDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.pink, size: 20),
                    SizedBox(width: 10),
                    Text("Edit Profile"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildMainOverviewPage(context, _kidName, _kidAge),
          _buildRecordMemoriesGrid(_kidPrefix, _kidName),
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
            onTap: () => Navigator.pushNamed(context, '/activities', arguments: _kidName),
          ),
          SpeedDialChild(
            child: const Icon(Icons.question_answer),
            label: 'Q&A and Parental Tips',
            onTap: () => Navigator.pushNamed(context, '/qna'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.article),
            label: 'Blog & Tips',
            onTap: () => Navigator.pushNamed(context, '/blogs', arguments: _kidName),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOverviewPage(BuildContext context, String name, String age) {
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.pink.shade100,
                    backgroundImage: (_imagePath != null && _imagePath!.isNotEmpty)
                        ? FileImage(File(_imagePath!)) as ImageProvider
                        : null,
                    child: (_imagePath == null || _imagePath!.isEmpty)
                        ? const Icon(Icons.child_care, size: 35, color: Colors.pink)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: $name",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Age: $age",
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
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
              child: const Text("View & Add Memories"),
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

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tick Mark (Completed)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: "Mark Completed",
                          onPressed: () async {
                            await DatabaseHelper.instance.trackTaskCompletion(true);
                            // TODO: Remove task/reminder from local UI state
                            setState(() {
                              _notifications.removeAt(index);
                            });
                            await _saveNotificationsToDB();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task marked as completed!'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                        // Cross Mark (Incomplete / Dismissed)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: "Mark Incomplete / Dismiss",
                          onPressed: () async {
                            await DatabaseHelper.instance.trackTaskCompletion(false);
                            // TODO: Remove task/reminder from local UI state
                            setState(() {
                              _notifications.removeAt(index);
                            });
                            await _saveNotificationsToDB();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task marked as incomplete.'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    )
                    /*IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () async {
                        setState(() {
                          _notifications.removeAt(index);
                        });
                        await _saveNotificationsToDB();
                      },
                    ),*/

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
          Text("Record Memories for $kidName",
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