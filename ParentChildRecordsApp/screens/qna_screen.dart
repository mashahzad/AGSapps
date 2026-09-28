import 'package:flutter/material.dart';

// ==========================================
// 6. Q&A SCREEN
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
          Card(
            color: Colors.purple.shade50,
            child: const ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.purple),
              title: Text("GPT powered advice on trivial everyday things"),
              subtitle: Text("Tap to launch assistant"),
            ),
          ),
        ],
      ),
    );
  }
}