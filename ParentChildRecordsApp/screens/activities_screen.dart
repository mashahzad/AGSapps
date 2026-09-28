import 'package:flutter/material.dart';

// ==========================================
// 5. ACTIVITIES SCREEN
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
        ],
      ),
    );
  }
}