import 'package:flutter/material.dart';

// ==========================================
// 3. MY FAMILY SCREEN
// ==========================================
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Family"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Me & My Spouse"),
              Tab(text: "My Kids"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/background.jpg',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.indigo.shade100,
                        child: const Icon(Icons.people, size: 60, color: Colors.indigo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Locate Tab 1 in FamilyScreen (under TabBarView):
                  Expanded(
                    child: ListView(
                      children: [
                        // 1. Father Record
                        Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: const Text("John Doe (Father)"),
                            subtitle: const Text("Tap to view records & details"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/parent_dashboard',
                                arguments: {
                                  "name": "John Doe",
                                  "relation": "Father",
                                  "work": "Software Engineer at TechCorp",
                                  "phone": "+65 9123 4567",
                                },
                              );
                            },
                          ),
                        ),

                        // 2. Add Jane Doe (Mother) here:
                        Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.pink,
                              child: Icon(Icons.person_3, color: Colors.white),
                            ),
                            title: const Text("Jane Doe (Mother)"),
                            subtitle: const Text("Tap to view records & details"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/parent_dashboard',
                                arguments: {
                                  "name": "Jane Doe",
                                  "relation": "Mother",
                                  "work": "Product Manager at DesignCo",
                                  "phone": "+65 9876 5432",
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/background.jpg',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.indigo.shade100,
                        child: const Icon(Icons.family_restroom, size: 60, color: Colors.indigo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Icon(Icons.child_care, color: Colors.white),
                            ),
                            title: const Text("Leo (Age: 5)"),
                            subtitle: const Text("Tap to view records & activities"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/kid_dashboard',
                                arguments: "Leo",
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}