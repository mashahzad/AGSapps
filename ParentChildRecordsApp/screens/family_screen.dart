import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/onboarding_dialog.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<Map<String, dynamic>> _parents = [];
  List<Map<String, dynamic>> _kids = [];
  bool _isLoading = true;
  String _pageTitle = "My Family";
  String? _backgroundImagePath;

  // Time tracking metrics (seconds)
  int _meSec = 100;
  int _spouseSec = 100;
  int _kidsSec = 100;
  bool _isGreyState = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUser();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTimeUser') ?? true;

    if (isFirstTime && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OnboardingDialog(),
      );
      await prefs.setBool('isFirstTimeUser', false);
    }
  }

  Future<void> _loadData() async {
    final title = await DatabaseHelper.instance.getFamilyTitle();
    final background = await DatabaseHelper.instance.getFamilyBackground();
    final parentRecords = await DatabaseHelper.instance.getFamilyMembers('parent');
    final kidRecords = await DatabaseHelper.instance.getFamilyMembers('kid');
    final timeStats = await DatabaseHelper.instance.getOrResetDailyTimeStats();

    if (parentRecords.isEmpty && kidRecords.isEmpty) {
      await DatabaseHelper.instance.insertFamilyMember({
        'name': 'John Doe',
        'relation': 'Father',
        'work': 'Software Engineer',
        'phone': '+1 234 567 890',
        'type': 'parent',
        'is_current_user': "0",
      });
      await DatabaseHelper.instance.insertFamilyMember({
        'name': 'Jane Doe',
        'relation': 'Mother',
        'work': 'Architect',
        'phone': '+1 234 567 891',
        'type': 'parent',
        'is_current_user': "1",
      });
      await DatabaseHelper.instance.insertFamilyMember({
        'name': 'Leo Doe',
        'relation': 'Son',
        'work': '5 years old',
        'phone': 'N/A',
        'type': 'kid',
        'is_current_user': "0",
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
        _meSec = timeStats['me_seconds'] ?? 100;
        _spouseSec = timeStats['spouse_seconds'] ?? 100;
        _kidsSec = timeStats['kids_seconds'] ?? 100;
        _isGreyState = (timeStats['is_grey_state'] ?? 1) == 1;
        _isLoading = false;
      });
    }
  }

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
      text: isKidTab ? 'Son or Daughter' : 'Parent or Other',
    );
    final workController = TextEditingController();
    final phoneController = TextEditingController();
    bool isCurrentUser = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isKidTab ? "Add New Child" : "Add Parent / Other"),
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
                        labelText: isKidTab ? "Age" : "Occupation",
                      ),
                    ),
                    if (!isKidTab) ...[
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: "Phone Number"),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: isCurrentUser,
                        title: const Text("This is Me (Primary User)"),
                        subtitle: const Text("Tracks time spent under 'Me' dashboard"),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setDialogState(() {
                            isCurrentUser = val ?? false;
                          });
                        },
                      ),
                    ],
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
                        'is_current_user': (!isKidTab && isCurrentUser) ? 1 : 0,
                      };

                      final newId = await DatabaseHelper.instance.insertFamilyMember(newMember);
                      if (!isKidTab && isCurrentUser) {
                        await DatabaseHelper.instance.updateCurrentParentUser(newId);
                      }

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
    return const AssetImage('assets/images/familybg.jpg');
  }

  Widget _buildDonutChartCard() {
    final double total = (_meSec + _spouseSec + _kidsSec).toDouble();

    final double mePercentage = total > 0 ? (_meSec / total) * 100 : 33.0;
    final double spousePercentage = total > 0 ? (_spouseSec / total) * 100 : 33.0;
    final double kidsPercentage = total > 0 ? (_kidsSec / total) * 100 : 34.0;

    final Color meColor = _isGreyState ? Colors.grey.shade400 : Colors.indigo;
    final Color spouseColor = _isGreyState ? Colors.grey.shade600 : Colors.teal;
    final Color kidsColor = _isGreyState ? Colors.grey.shade800 : Colors.pink;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      color: Colors.white.withOpacity(0.60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isGreyState ? "Time Spent Overview (New Day)" : "Time Spent Overview Today",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isGreyState ? Colors.grey.shade700 : Colors.indigo,
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
                          color: meColor,
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
                          color: spouseColor,
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
                          color: kidsColor,
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
                      _isGreyState ? "Reset Mode" : "My Time",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ChartLegendItem(color: meColor, label: "Me"),
                _ChartLegendItem(color: spouseColor, label: "Spouse"),
                _ChartLegendItem(color: kidsColor, label: "Kids"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgImage = _getBackgroundImage();
    const Color forestGreen = Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70, // Expanded height to accommodate the larger font sizes cleanly
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Gloria",
              style: GoogleFonts.fredoka(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: forestGreen,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              _pageTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: "App Tour",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const OnboardingDialog(),
              );
            },
          ),
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
              Colors.black.withOpacity(0.05),
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
            color: Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isKid
                ? "No kids added yet. Tap '+' to add."
                : "No parents/Other added yet. Tap '+' to add.",
            style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final bool isCurrentUser = (member['is_current_user'] ?? 0) == 1;

        return Card(
          elevation: 2,
          color: Colors.white.withOpacity(0.60),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isKid
                  ? Colors.pink.shade100
                  : (isCurrentUser ? Colors.indigo.shade100 : Colors.teal.shade100),
              child: Icon(
                isKid ? Icons.child_care : Icons.person,
                color: isKid
                    ? Colors.pink
                    : (isCurrentUser ? Colors.indigo : Colors.teal),
              ),
            ),
            title: Row(
              children: [
                Text(
                  member['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!isKid && isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50.withOpacity(0.60),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: const Text(
                      'ME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ],
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
                  arguments: {
                    'name': member['name'] ?? 'Kid',
                    'age': (member['work'] != null &&
                        member['work'].toString().isNotEmpty)
                        ? member['work']
                        : 'Not specified',
                  },
                ).then((_) => _loadData());
              } else {
                Navigator.pushNamed(
                  context,
                  '/parent_dashboard',
                  arguments: {
                    'name': member['name'],
                    'relation': member['relation'],
                    'work': member['work'],
                    'phone': member['phone'],
                    'is_current_user': member['is_current_user'] ?? 0,
                  },
                ).then((_) => _loadData());
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