import 'package:flutter/material.dart';

// ==========================================
// 7. BLOGS SCREEN
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