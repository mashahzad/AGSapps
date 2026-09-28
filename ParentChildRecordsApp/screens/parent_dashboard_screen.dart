import 'package:flutter/material.dart';
import '../widgets/database_grid_tile.dart';

// ==========================================
// 3.5 PARENT DASHBOARD
// ==========================================
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final parentData = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ??
        {
          "name": "Parent",
          "relation": "Guardian",
          "work": "Not specified",
          "phone": "Not specified",
        };

    return Scaffold(
      appBar: AppBar(
        title: Text("${parentData['name']}'s Dashboard"),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildMainOverviewPage(context, parentData),
          _buildManageParentDataGrid(),
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
              child: const Text("View details"),
            ),
          ),
          const Divider(height: 30),
          const Text(
            "Schedules & Reminders",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.business_center, color: Colors.indigo, size: 20),
                  title: Text("Parent-Teacher Conference"),
                  subtitle: Text("Friday at 3:00 PM"),
                ),
                ListTile(
                  leading: Icon(Icons.directions_car, color: Colors.orange, size: 20),
                  title: Text("Car Servicing"),
                  subtitle: Text("This Weekend"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildManageParentDataGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Parent Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tap any card below to view or update persistent details.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: const [
                DatabaseGridTile(
                  recordId: "parent_personal_details",
                  defaultTitle: "Personal Details",
                  defaultContent: "Full name, NRIC/Passport, DOB, Emergency Contact Numbers",
                  icon: Icons.badge,
                ),
                DatabaseGridTile(
                  recordId: "parent_work_info",
                  defaultTitle: "Work Info",
                  defaultContent: "Company name, Office address, Extension, Working hours",
                  icon: Icons.work,
                  color: Colors.blue,
                ),
                DatabaseGridTile(
                  recordId: "parent_health_info",
                  defaultTitle: "Health & Insurance",
                  defaultContent: "Blood group, Medical conditions, Policy details",
                  icon: Icons.medical_information,
                  color: Colors.redAccent,
                ),
                DatabaseGridTile(
                  recordId: "parent_logistics",
                  defaultTitle: "Logistics",
                  defaultContent: "Primary pick-up duties, Weekend activity roles",
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