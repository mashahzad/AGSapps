import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../database/database_helper.dart';

class FamilyReportsScreen extends StatefulWidget {
  const FamilyReportsScreen({super.key});

  @override
  State<FamilyReportsScreen> createState() => _FamilyReportsScreenState();
}

class _FamilyReportsScreenState extends State<FamilyReportsScreen> {
  int _selectedYear = DateTime.now().year;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await DatabaseHelper.instance.getWeeklyReportsForYear(_selectedYear);
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  String _calculateBias(int me, int spouse, int kids) {
    final total = me + spouse + kids;
    if (total == 0) return "Perfect Balance";
    final kidsPct = (kids / total) * 100;
    final spousePct = (spouse / total) * 100;
    final mePct = (me / total) * 100;

    if (kidsPct > 50) return "Bias on Kids";
    if (spousePct > 50) return "Bias on Spouse";
    if (mePct > 50) return "Bias on You (Personal Time)";
    return "Perfect Balance";
  }

  List<String> _getBlogSuggestions(String bias) {
    if (bias.contains("Kids")) {
      return [
        "5 Creative Date Night Ideas to Reconnect with Your Spouse",
        "The Importance of Personal Self-Care for Parents"
      ];
    } else if (bias.contains("Spouse")) {
      return [
        "Meaningful Weekend Activities to Bond with Young Children",
        "Balancing Partnership and Parenthood Successfully"
      ];
    } else if (bias.contains("You")) {
      return [
        "Quality Over Quantity: Making Family Time Count",
        "Building Strong Family Routines That Last"
      ];
    }
    return [
      "Maintaining Harmony: The Secret to Family Balance",
      "Top 10 Activities for Healthy Family Growth"
    ];
  }

  Future<void> _generatePdf(Map<String, dynamic> report, int weekNum) async {
    final pdf = pw.Document();
    final me = report['me_seconds'] ?? 0;
    final spouse = report['spouse_seconds'] ?? 0;
    final kids = report['kids_seconds'] ?? 0;
    final bias = _calculateBias(me, spouse, kids);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Gloria Family Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Year: $_selectedYear | Week: $weekNum", style: const pw.TextStyle(fontSize: 16)),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text("Tasks Completed: ${report['tasks_completed'] ?? 0}"),
              pw.Text("Tasks Incomplete: ${report['tasks_incomplete'] ?? 0}"),
              pw.Text("Memories Logged: ${report['memories_count'] ?? 0}"),
              pw.SizedBox(height: 10),
              pw.Text("Time Distribution Bias: $bias", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(" - Me: ${me}s"),
              pw.Text(" - Spouse: ${spouse}s"),
              pw.Text(" - Kids: ${kids}s"),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'family_report_week_$weekNum.pdf');
  }

  void _showWeeklyDetailModal(Map<String, dynamic> report, int weekNum) {
    final me = report['me_seconds'] ?? 0;
    final spouse = report['spouse_seconds'] ?? 0;
    final kids = report['kids_seconds'] ?? 0;
    final bias = _calculateBias(me, spouse, kids);
    final blogs = _getBlogSuggestions(bias);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Week $weekNum Detailed Report", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E))),
              const SizedBox(height: 12),
              Text("Tasks Completed: ${report['tasks_completed'] ?? 0}"),
              Text("Tasks Incomplete: ${report['tasks_incomplete'] ?? 0}"),
              Text("Memories Visited: ${report['memories_count'] ?? 0}"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text("Time Ratio Bias: $bias", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
              ),
              const SizedBox(height: 16),
              const Text("Recommended Blogs For You:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...blogs.map((blog) => ListTile(
                dense: true,
                leading: const Icon(Icons.article, color: Colors.indigo, size: 20),
                title: Text(blog, style: const TextStyle(fontSize: 13)),
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                  icon: const Icon(Icons.download),
                  label: const Text("Save / Share PDF Report"),
                  onPressed: () => _generatePdf(report, weekNum),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Family Reports ($_selectedYear)", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 52,
        itemBuilder: (context, index) {
          final weekNum = index + 1;
          final reportData = _reports.firstWhere(
                (r) => r['week_number'] == weekNum,
            orElse: () => <String, dynamic>{},
          );

          final completed = reportData['tasks_completed'] ?? 0;
          final incomplete = reportData['tasks_incomplete'] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Text("$weekNum", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ),
              title: Text("Week $weekNum Summary", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Completed: $completed | Incomplete: $incomplete"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showWeeklyDetailModal(reportData, weekNum),
            ),
          );
        },
      ),
    );
  }
}