import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../widgets/database_grid_tile.dart';

// ==========================================
// 4. KID DASHBOARD
// ==========================================
class KidDashboardScreen extends StatefulWidget {
  const KidDashboardScreen({Key? key}) : super(key: key);

  @override
  State<KidDashboardScreen> createState() => _KidDashboardScreenState();
}

class _KidDashboardScreenState extends State<KidDashboardScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final kidName = ModalRoute.of(context)?.settings.arguments as String? ?? "Kid Name";

    return Scaffold(
      appBar: AppBar(
        title: Text(kidName),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildMainOverviewPage(context, kidName),
          _buildRecordMemoriesGrid(),
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
              child: const Text("View details"),
            ),
          ),
          const Divider(height: 30),
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.red, size: 16),
                  title: Text("Doctor Appointment"),
                  subtitle: Text("Tomorrow at 10:00 AM"),
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.orange, size: 16),
                  title: Text("Vaccination Alert"),
                  subtitle: Text("Due in 5 days"),
                ),
              ],
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
          const Text("Record Memories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tap any card below to edit and permanently save new memories.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: const [
                DatabaseGridTile(
                  recordId: "kid_general_details",
                  defaultTitle: "General Details",
                  defaultContent: "Name, birthdate, nicknames, height & weight, guardian",
                  icon: Icons.face,
                  color: Colors.purple,
                ),
                DatabaseGridTile(
                  recordId: "kid_health_history",
                  defaultTitle: "Health History",
                  defaultContent: "Insurance, Allergies, vaccinations, doctor visits, dosage",
                  icon: Icons.local_hospital,
                  color: Colors.red,
                ),
                DatabaseGridTile(
                  recordId: "kid_likes_hobbies",
                  defaultTitle: "Likes & Hobbies",
                  defaultContent: "Food, sports, pets, favorite spots",
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
                DatabaseGridTile(
                  recordId: "kid_growing_milestones",
                  defaultTitle: "Growing",
                  defaultContent: "First words, School, achievements, CCA",
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                DatabaseGridTile(
                  recordId: "kid_transportation",
                  defaultTitle: "Transportation",
                  defaultContent: "Mode, driver name, routes, friends",
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