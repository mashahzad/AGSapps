// lib/widgets/database_grid_tile.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DatabaseGridTile extends StatefulWidget {
  final String recordId;
  final String defaultTitle;
  final String defaultContent;
  final IconData icon;
  final Color color;

  const DatabaseGridTile({
    Key? key,
    required this.recordId,
    required this.defaultTitle,
    required this.defaultContent,
    required this.icon,
    this.color = Colors.indigo,
  }) : super(key: key);

  @override
  State<DatabaseGridTile> createState() => _DatabaseGridTileState();
}

class _DatabaseGridTileState extends State<DatabaseGridTile> {
  late String content;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final record = await DatabaseHelper.instance.getRecord(widget.recordId);
    if (record != null && mounted) {
      setState(() {
        content = record['content'];
        isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        content = widget.defaultContent;
        isLoading = false;
      });
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(text: content);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Edit ${widget.defaultTitle}"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter updated information...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newContent = controller.text;
                await DatabaseHelper.instance.insertOrUpdateRecord(
                  widget.recordId,
                  widget.defaultTitle,
                  newContent,
                );
                if (mounted) {
                  setState(() {
                    content = newContent;
                  });
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${widget.defaultTitle} saved to database!")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: widget.color, size: 24),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.defaultTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                  content,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}