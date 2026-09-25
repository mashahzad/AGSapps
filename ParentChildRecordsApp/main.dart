import 'dart:async';
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
        '/login': (context) => const LoginScreen(),
        '/family': (context) => const FamilyScreen(),
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
    // Auto navigate to Login Screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // Replace with your background path
              fit: BoxFit.cover,
            ),
          ),

          // 2. Centered Content (Logo & Text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Company Logo JPG
                Image.asset(
                  'assets/images/logo.jpg', // Replace with your logo path
                  width: 100, // Adjust size as needed
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  "AGS presents",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Change text color if needed for visibility against the background
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
// 2. LOGIN / REGISTER SCREEN
// ==========================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make the app bar transparent so the background shows through
      appBar: AppBar(
        title: const Text("Login page"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Extend the body behind the transparent app bar if you want the image to cover the whole screen
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Original Login Page Content
          SafeArea( // SafeArea prevents content from hiding behind the notch/status bar
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "SG Govt body approved!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8), // Optional: adds a slight white tint behind text for better readability
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/family');
                    },
                    child: const Text(
                      "LOGIN or register",
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 1.5),
                      backgroundColor: Colors.white.withOpacity(0.8), // Optional readability tweak
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Admin Portal Clicked")),
                      );
                    },
                    child: const Text(
                      "Admin",
                      style: TextStyle(color: Colors.green),
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
      initialIndex: 1, // Focus on "My Kids" tab by default
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Family"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "ME"),
              Tab(text: "My Kids"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const Center(child: Text("Parent Profile & Personal Info Details")),
            // My Kids Tab View
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.family_restroom, size: 100, color: Colors.indigo),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.child_care)),
                            title: const Text("Leo (Age: 5)"),
                            subtitle: const Text("Tap to view records & activities"),
                            trailing: const Icon(Icons.arrow_forward_ios),
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
          // Screen 1: Overview & Notifications
          _buildMainOverviewPage(context, kidName),
          // Screen 2: Manage My Kid Data (Swiped from Left to Right)
          _buildManageKidDataPage(),
        ],
      ),
      // Floating Buttons (1: Activities, 2: Q&A, 3: Blogs)
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.sports_esports),
            label: 'Activities and stories',
            onTap: () => Navigator.pushNamed(context, '/activities', arguments: kidName),
          ),
          SpeedDialChild(
            child: const Icon(Icons.question_answer),
            label: 'Q&A',
            onTap: () => Navigator.pushNamed(context, '/qna'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.article),
            label: 'Blog & tips',
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
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Details:\nName: $name\nAge: 5\nPersonal: (allergies, hobbies, activities, blood group)",
                      style: const TextStyle(fontSize: 13),
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
              child: const Text("Personal details / Manage details->"),
            ),
          ),
          const Divider(height: 30),
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text("Alerts (Appointments, reminders, birthdates)"),
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
                  leading: Icon(Icons.circle, color: Colors.red, size: 16),
                  title: Text("Vaccination Alert"),
                  subtitle: Text("Due in 5 days"),
                ),
                ListTile(
                  leading: Icon(Icons.circle, color: Colors.red, size: 16),
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
            Text("Health History:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Allergies, vaccinations, doctor visits, dosage and medications"),
            SizedBox(height: 15),
            Text("Likes:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Food, sports, hobbies, pets, picnics"),
            SizedBox(height: 15),
            Text("Growing:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("First words, School, achievements by date"),
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
      appBar: AppBar(title: Text("Activities for <$kidName>")),
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
      appBar: AppBar(title: const Text("Q&A / Sponsored content")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(title: Text("What to feed?")),
          const Divider(),
          const ListTile(title: Text("Allery advise")),
          const Divider(),
          const ListTile(title: Text("Doctor connect / gynaecologists (premium)")),
          const Divider(),
          Card(
            color: Colors.purple.shade50,
            child: const ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.purple),
              title: Text("GPT powered advise on trivial everyday things related to kids (chatbot)"),
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
      appBar: AppBar(title: Text("Blogs and tips <$kidName>")),
      body: const Center(
        child: Text("Articles & Age-Group tips customized for this age group."),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/
