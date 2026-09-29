import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/database_grid_tile.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final PageController _pageController = PageController();
  List<Map<String, String>> _schedules = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  Map<String, String> _parentData = {
    "name": "Parent",
    "relation": "Guardian",
    "work": "Not specified",
    "phone": "Not specified",
  };
  String _parentPrefix = 'parent';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _parentData = Map<String, String>.from(args);
      }
      _parentPrefix = (_parentData['name'] ?? 'parent').toLowerCase().replaceAll(' ', '_');
      _loadSchedulesFromDB();
      _isInitialized = true;
    }
  }

  // Load schedules from SQLite database
  Future<void> _loadSchedulesFromDB() async {
    final record = await DatabaseHelper.instance.getRecord('${_parentPrefix}_schedules');
    if (record != null && record['content'] != null) {
      try {
        final List<dynamic> decoded = jsonDecode(record['content']);
        if (mounted) {
          setState(() {
            _schedules = decoded.map((e) => Map<String, String>.from(e)).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        _setDefaultSchedules();
      }
    } else {
      _setDefaultSchedules();
    }
  }

  void _setDefaultSchedules() {
    if (mounted) {
      setState(() {
        _schedules = [
          {"title": "Parent-Teacher Conference", "subtitle": "Friday at 3:00 PM"},
          {"title": "Car Servicing", "subtitle": "This Weekend"},
        ];
        _isLoading = false;
      });
      _saveSchedulesToDB();
    }
  }

  // Save schedules back to SQLite database
  Future<void> _saveSchedulesToDB() async {
    final jsonString = jsonEncode(_schedules);
    await DatabaseHelper.instance.insertOrUpdateRecord(
      '${_parentPrefix}_schedules',
      'Schedules',
      jsonString,
    );
  }

  void _addScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add New Schedule / Reminder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "e.g., Dental Appointment",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: "Time / Notes",
                  hintText: "e.g., Tomorrow at 2:00 PM",
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
                    _schedules.add({
                      "title": titleController.text.trim(),
                      "subtitle": subtitleController.text.trim().isEmpty
                          ? "No details"
                          : subtitleController.text.trim(),
                    });
                  });
                  await _saveSchedulesToDB();
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
        title: Text("${_parentData['name']}'s Dashboard"),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildMainOverviewPage(context, _parentData),
          _buildManageParentDataGrid(_parentPrefix, _parentData['name'] ?? 'Parent'),
        ],
      ),
    );
  }

  Widget _buildMainOverviewPage(BuildContext context, Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.indigo.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.indigo),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Name: ${data['name']}\nRole: ${data['relation']}\nOccupation: ${data['work']}\nContact: ${data['phone']}",
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
                "Schedules & Reminders",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.indigo),
                onPressed: () => _addScheduleDialog(context),
                tooltip: "Add Schedule",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _schedules.isEmpty
                ? const Center(child: Text("No schedules added yet."))
                : ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final item = _schedules[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_note, color: Colors.indigo),
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['subtitle'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () async {
                        setState(() {
                          _schedules.removeAt(index);
                        });
                        await _saveSchedulesToDB();
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

  Widget _buildManageParentDataGrid(String parentPrefix, String parentName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$parentName's Profile", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tap any card below to enter or update information.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                DatabaseGridTile(
                  recordId: "${parentPrefix}_personal_details",
                  defaultTitle: "Personal Details",
                  defaultContent: "Tap to enter NRIC/Passport, DOB, Emergency Contact",
                  icon: Icons.badge,
                ),
                DatabaseGridTile(
                  recordId: "${parentPrefix}_work_info",
                  defaultTitle: "Work Info",
                  defaultContent: "Tap to enter Company name, Office address, Extension",
                  icon: Icons.work,
                  color: Colors.blue,
                ),
                DatabaseGridTile(
                  recordId: "${parentPrefix}_health_info",
                  defaultTitle: "Health & Insurance",
                  defaultContent: "Tap to enter Blood group, Medical conditions, Policy details",
                  icon: Icons.medical_information,
                  color: Colors.redAccent,
                ),
                DatabaseGridTile(
                  recordId: "${parentPrefix}_logistics",
                  defaultTitle: "Logistics",
                  defaultContent: "Tap to enter Primary pick-up duties, Weekend roles",
                  icon: Icons.time_to_leave,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}