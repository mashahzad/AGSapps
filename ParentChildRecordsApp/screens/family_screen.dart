import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _kids = [];
  bool _isLoading = true;
  String _pageTitle = "My Family";
  String? _backgroundImagePath;

  // Time tracking values (percentages or raw time units)
  double _meTime = 25.0;
  double _spouseTime = 35.0;
  double _kidsTime = 40.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final title = await DatabaseHelper.instance.getFamilyTitle();
    final background = await DatabaseHelper.instance.getFamilyBackground();
    final parentRecords = await DatabaseHelper.instance.getFamilyMembers('parent');
    final kidRecords = await DatabaseHelper.instance.getFamilyMembers('kid');

    if (parentRecords.isEmpty && kidRecords.isEmpty) {
      await DatabaseHelper.instance.insertFamilyMember({
        'name': 'John Doe',
        'relation': 'Father',
        'work': 'Software Engineer',
        'phone': '+1 234 567 890',
        'type': 'parent'
      });
      await DatabaseHelper.instance.insertFamilyMember({
        'name': 'Jane Doe',
        'relation': 'Mother',
        'work': 'Architect',
        'phone': '+1 234 567 891',
        'type': 'parent'
      });
      await DatabaseHelper.instance.insertFamilyMember({
        'name': 'Leo Doe',
        'relation': 'Son',
        'work': '5 years old',
        'phone': 'N/A',
        'type': 'kid'
      });

      _loadData();
      return;
    }

    if (mounted) {
      setState(() {
        _pageTitle = title;
        _backgroundImagePath = background;
        _parents = parentRecords;
        _kids = kidRecords;
        _isLoading = false;
      });
    }
  }

  // Pick image from gallery using native device picker
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await DatabaseHelper.instance.saveFamilyBackground(pickedFile.path);
        if (mounted) {
          setState(() {
            _backgroundImagePath = pickedFile.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showChangeBackgroundDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Change Background Photo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.indigo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickImageFromGallery();
                },
              ),
              if (_backgroundImagePath != null && _backgroundImagePath!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  title: const Text("Restore Default Background"),
                  onTap: () async {
                    await DatabaseHelper.instance.saveFamilyBackground('');
                    if (mounted) {
                      setState(() {
                        _backgroundImagePath = null;
                      });
                      Navigator.pop(dialogContext);
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTitleDialog() {
    final titleController = TextEditingController(text: _pageTitle);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Family Name"),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Family Name",
              hintText: "e.g., Doe Family",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  await DatabaseHelper.instance.saveFamilyTitle(newTitle);
                  if (mounted) {
                    setState(() {
                      _pageTitle = newTitle;
                    });
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final bool isKidTab = _tabController.index == 1;
    final nameController = TextEditingController();
    final relationController = TextEditingController(
      text: isKidTab ? 'Son / Daughter' : 'Spouse',
    );
    final workController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isKidTab ? "Add New Child" : "Add Parent / Spouse"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(labelText: "Relation / Role"),
                ),
                TextField(
                  controller: workController,
                  decoration: InputDecoration(
                    labelText: isKidTab ? "Age / Grade" : "Occupation",
                  ),
                ),
                if (!isKidTab)
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
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
                if (nameController.text.trim().isNotEmpty) {
                  final newMember = {
                    'name': nameController.text.trim(),
                    'relation': relationController.text.trim(),
                    'work': workController.text.trim().isEmpty
                        ? 'Not specified'
                        : workController.text.trim(),
                    'phone': phoneController.text.trim().isEmpty
                        ? 'N/A'
                        : phoneController.text.trim(),
                    'type': isKidTab ? 'kid' : 'parent',
                  };

                  await DatabaseHelper.instance.insertFamilyMember(newMember);
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    _loadData();
                  }
                }
              },
              child: const Text("Add Member"),
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getBackgroundImage() {
    if (_backgroundImagePath != null && _backgroundImagePath!.trim().isNotEmpty) {
      final file = File(_backgroundImagePath!.trim());
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    // Correct local path fallback
    return const AssetImage('assets/images/familybg.jpg');
  }

  // --- Donut Style Pie Chart Widget ---
  Widget _buildDonutChartCard() {
    final double total = _meTime + _spouseTime + _kidsTime;

    final double mePercentage = total > 0 ? (_meTime / total) * 100 : 0;
    final double spousePercentage = total > 0 ? (_spouseTime / total) * 100 : 0;
    final double kidsPercentage = total > 0 ? (_kidsTime / total) * 100 : 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: Colors.white.withOpacity(0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Time Spent Overview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: Colors.indigo,
                          value: mePercentage,
                          title: '${mePercentage.toStringAsFixed(0)}%',
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.teal,
                          value: spousePercentage,
                          title: '${spousePercentage.toStringAsFixed(0)}%',
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.pink,
                          value: kidsPercentage,
                          title: '${kidsPercentage.toStringAsFixed(0)}%',
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      "My Time",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ChartLegendItem(color: Colors.indigo, label: "Me"),
                _ChartLegendItem(color: Colors.teal, label: "Spouse"),
                _ChartLegendItem(color: Colors.pink, label: "Kids"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgImage = _getBackgroundImage();

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit_name') {
                _showEditTitleDialog();
              } else if (value == 'change_bg') {
                _showChangeBackgroundDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit_name',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.indigo, size: 20),
                    SizedBox(width: 10),
                    Text('Edit Family Name'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'change_bg',
                child: Row(
                  children: [
                    Icon(Icons.photo_library, color: Colors.indigo, size: 20),
                    SizedBox(width: 10),
                    Text('Change Background Photo'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: "Me & My Spouse"),
            Tab(icon: Icon(Icons.child_care), text: "My Kids"),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: bgImage,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.15),
              BlendMode.darken,
            ),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            _buildDonutChartCard(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMemberList(_parents, isKid: false),
                  _buildMemberList(_kids, isKid: true),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        icon: const Icon(Icons.person_add),
        label: const Text("Add Member"),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildMemberList(List<Map<String, dynamic>> members, {required bool isKid}) {
    if (members.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isKid ? "No kids added yet. Tap '+' to add." : "No parents/spouses added yet. Tap '+' to add.",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          elevation: 3,
          color: Colors.white.withOpacity(0.92),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isKid ? Colors.pink.shade100 : Colors.indigo.shade100,
              child: Icon(
                isKid ? Icons.child_care : Icons.person,
                color: isKid ? Colors.pink : Colors.indigo,
              ),
            ),
            title: Text(
              member['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${member['relation']} • ${member['work']}\nPhone: ${member['phone']}",
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                await DatabaseHelper.instance.deleteFamilyMember(member['id']);
                _loadData();
              },
            ),
            onTap: () {
              if (isKid) {
                Navigator.pushNamed(
                  context,
                  '/kid_dashboard',
                  arguments: member['name'],
                );
              } else {
                Navigator.pushNamed(
                  context,
                  '/parent_dashboard',
                  arguments: {
                    "name": member['name'],
                    "relation": member['relation'],
                    "work": member['work'],
                    "phone": member['phone'],
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}