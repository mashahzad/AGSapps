import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
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

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/description');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.child_care, size: 100, color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                const Text(
                  "AGS presents",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1.5 DESCRIPTION SCREEN
// ==========================================
class DescriptionScreen extends StatefulWidget {
  const DescriptionScreen({Key? key}) : super(key: key);

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  bool _isAccepted = false;
  late TapGestureRecognizer _termsGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _termsGestureRecognizer = TapGestureRecognizer()..onTap = _showTermsDialog;
  }

  @override
  void dispose() {
    _termsGestureRecognizer.dispose();
    super.dispose();
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "Welcome to Kids Growth Journal!\n\n"
                  "1. Privacy First: All growth records, photos, and personal notes are kept strictly private and secure.\n\n"
                  "2. Data Responsibility: Users are responsible for maintaining backup copies of their media.\n\n"
                  "3. Content Usage: Features such as AI advice are for general informational purposes only and do not replace professional medical care.\n\n"
                  "4. User Conduct: Ensure all added content respects child privacy and family guidelines.",
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.indigo.shade50),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "“Every child has a story of love, bonding and building in a family.”",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Capture it. Preserve it. Treasure it.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "They grow up faster than we realise.\n"
                                  "One day you're celebrating their first steps.\n"
                                  "Then their first day of school. Their first drawing, first bicycle ride, first swimming lesson, first trophy, first best friend.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Kids Growth Journal helps you keep it all.\n"
                                  "One beautiful, private place to capture your child's growth, learning, interests, achievements, health milestones and the memories that matter most.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Record the moments as they happen. Add a photo. Write a few words. Save a milestone. Track how they're growing.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                            SizedBox(height: 20),
                            Divider(),
                            SizedBox(height: 16),
                            Text(
                              "Celebrate what they've learned and the things they're beginning to love.\n\n"
                                  "Over time, those individual moments become something much more meaningful:\n"
                                  "the story of your child's childhood &\nthe bond you shared with your child.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 20),
                            Divider(),
                            SizedBox(height: 16),
                            Text(
                              "Watch their story unfold.\n"
                                  "See how they grow.\n"
                                  "See what they learn.\n"
                                  "See how their interests change.\n"
                                  "See what makes them smile.\n"
                                  "See how far they've come.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.indigo),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "And when you look back, don't just see a collection of photographs.\n"
                                  "See the journey.\n"
                                  "From today's little moments to tomorrow's treasured memories.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Checkbox(
                          value: _isAccepted,
                          activeColor: Colors.indigo,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAccepted = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "I accept the ",
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                              children: [
                                TextSpan(
                                  text: "Terms and Conditions",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _termsGestureRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          disabledBackgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isAccepted
                            ? () {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                            : null,
                        child: const Text(
                          "Start recording these moments!",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. LOGIN / REGISTER SCREEN
// ==========================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's Begin"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade100),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Parent Child Records App",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withOpacity(0.9),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/family');
                    },
                    child: const Text(
                      "Record Your Memories",
                      style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      backgroundColor: Colors.white.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Admin Portal Clicked")),
                      );
                    },
                    child: const Text(
                      "Admin",
                      style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Proudly made in Singapore",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. MY FAMILY SCREEN (ME / My Kids Tabs)
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
            // Tab 1: Me & My Spouse
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
                  Expanded(
                    child: ListView(
                      children: [
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
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.pink,
                              child: Icon(Icons.person_4, color: Colors.white),
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
                                  "work": "Architect at DesignStudio",
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

            // Tab 2: My Kids
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

// ==========================================
// 3.5 PARENT DASHBOARD (NEW)
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
          _buildManageParentDataPage(),
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
          const SizedBox(height: 4),
          Text(
            "Key tasks, office meetings, and family events from your calendar",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                ListTile(
                  leading: Icon(Icons.health_and_safety, color: Colors.green, size: 20),
                  title: Text("Health Insurance Renewal"),
                  subtitle: Text("Due end of the month"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildManageParentDataPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Manage Profile Data", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("Personal Details:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Full name, NRIC/Passport, Date of Birth, Emergency Contact Numbers"),
            SizedBox(height: 15),
            Text("Work Information:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Company name, Office address, Office phone extension, Working hours"),
            SizedBox(height: 15),
            Text("Health & Insurance Details:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Blood group, Medical conditions, Family health insurance policy info"),
            SizedBox(height: 15),
            Text("Responsibilities & Logistics:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Primary pick-up/drop-off duties for kids, Weekend activity assignments"),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. KID DASHBOARD (PageSwipe & Floating Dial)
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
          _buildManageKidDataPage(),
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
          const SizedBox(height: 4),
          Text(
            "Alerts (Appointments, reminders, birthdates, Events fetched from calendar app)",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.blue, size: 16),
                  title: Text("Birthday Reminder"),
                  subtitle: Text("Next Month"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildManageKidDataPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Manage Data", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("General Details:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Name, birthdate, nicknames, friends, height and weight, guardian name"),
            SizedBox(height: 15),
            Text("Health History:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Medical insurance policy number, Allergies, vaccinations, doctor visits, dosage and medications\n(allergies, hobbies, activities, blood group)"),
            SizedBox(height: 15),
            Text("Likes:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Food, sports, hobbies, pets, picnic spots, places of interest"),
            SizedBox(height: 15),
            Text("Growing:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("First words, School, achievements by date, co-curricular activities"),
            SizedBox(height: 15),
            Text("Transportation Details:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Mode, driver name, usual routes, friends"),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. FLOATING BUTTON 1: ACTIVITIES
// ==========================================
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kidName = ModalRoute.of(context)?.settings.arguments as String? ?? "selected kid";

    return Scaffold(
      appBar: AppBar(title: Text("Activities for $kidName")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(leading: Icon(Icons.palette), title: Text("Hobbies")),
          Divider(),
          ListTile(leading: Icon(Icons.menu_book), title: Text("Audio Story books")),
          Divider(),
          ListTile(leading: Icon(Icons.directions_run), title: Text("Kid activities")),
          Divider(),
          ListTile(leading: Icon(Icons.extension), title: Text("Lego and other kids development games")),
          Divider(),
          ListTile(leading: Icon(Icons.casino), title: Text("Board games")),
        ],
      ),
    );
  }
}

// ==========================================
// 6. FLOATING BUTTON 2: Q&A / SPONSORED
// ==========================================
class QnAScreen extends StatelessWidget {
  const QnAScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Q&A and Tips")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(title: Text("What to feed?")),
          const Divider(),
          const ListTile(title: Text("Allergy advice")),
          const Divider(),
          const ListTile(title: Text("Doctor connect / gynaecologists (premium)")),
          const Divider(),
          Card(
            color: Colors.purple.shade50,
            child: const ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.purple),
              title: Text("GPT powered advice on trivial everyday things related to kids (chatbot)"),
              subtitle: Text("Tap to launch assistant"),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. FLOATING BUTTON 3: BLOGS AND TIPS
// ==========================================
class BlogsScreen extends StatelessWidget {
  const BlogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kidName = ModalRoute.of(context)?.settings.arguments as String? ?? "selected kid";

    return Scaffold(
      appBar: AppBar(title: Text("Blogs and Tips for $kidName")),
      body: const Center(
        child: Text("Articles & Age-Group tips customized for this age group."),
      ),
    );
  }
}