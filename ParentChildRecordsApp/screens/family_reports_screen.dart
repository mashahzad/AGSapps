//List<Map<String, dynamic>> _reports = [];
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
  List<int> _availableYears = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    setState(() => _isLoading = true);
    final years = await DatabaseHelper.instance.getAvailableYears();
    setState(() {
      _availableYears = years;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Family Reports",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold, color: const Color(0xFF1B4D3E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4D3E)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Year",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _availableYears.length,
                itemBuilder: (context, index) {
                  final year = _availableYears[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YearWeeksScreen(year: year),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Calendar Icon with Year inside
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 54, color: Color(0xFF2E7D32)),
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  "$year",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B4D3E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Year $year",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WEEKS LIST SCREEN FOR A SELECTED YEAR
// ==========================================
class YearWeeksScreen extends StatefulWidget {
  final int year;
  const YearWeeksScreen({super.key, required this.year});

  @override
  State<YearWeeksScreen> createState() => _YearWeeksScreenState();
}

class _YearWeeksScreenState extends State<YearWeeksScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await DatabaseHelper.instance.getWeeklyReportsForYear(widget.year);
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  // Helper to calculate start & end date string for a given week number
  String _getWeekDateRange(int year, int weekNumber) {
    final firstDayOfYear = DateTime(year, 1, 1);
    // Add offset for the week number
    final daysOffset = (weekNumber - 1) * 7;
    final startDate = firstDayOfYear.add(Duration(days: daysOffset));
    final endDate = startDate.add(const Duration(days: 6));

    String format(DateTime d) => "${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}";
    return "${format(startDate)} - ${format(endDate)}";
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
    }
    return [
      "Quality Over Quantity: Making Family Time Count",
      "Building Strong Family Routines That Last"
    ];
  }

  Future<void> _generateYearlyPdf() async {
    final pdf = pw.Document();
    int totalCompleted = 0;
    int totalIncomplete = 0;
    int totalMemories = 0;

    for (var r in _reports) {
      totalCompleted += (r['tasks_completed'] as int? ?? 0);
      totalIncomplete += (r['tasks_incomplete'] as int? ?? 0);
      totalMemories += (r['memories_count'] as int? ?? 0);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Gloria Yearly Review Report (${widget.year})", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text("Total Weeks Tracked: ${_reports.length} / 52"),
              pw.Text("Total Tasks Completed: $totalCompleted"),
              pw.Text("Total Tasks Incomplete: $totalIncomplete"),
              pw.Text("Total Memories Logged: $totalMemories"),
              pw.SizedBox(height: 15),
              pw.Text("Summary of 52 Weeks Roll-up completed successfully.", style: const pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'yearly_review_${widget.year}.pdf');
  }

  Future<void> _generateWeeklyPdf(Map<String, dynamic> report, int weekNum, String dateRange) async {
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
              pw.Text("Gloria Weekly Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Year: ${widget.year} | Week $weekNum ($dateRange)", style: const pw.TextStyle(fontSize: 16)),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text("Tasks Completed: ${report['tasks_completed'] ?? 0}"),
              pw.Text("Tasks Incomplete: ${report['tasks_incomplete'] ?? 0}"),
              pw.Text("Memories Logged: ${report['memories_count'] ?? 0}"),
              pw.SizedBox(height: 10),
              pw.Text("Time Distribution Bias: $bias", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'family_report_week_${weekNum}_${widget.year}.pdf');
  }

  void _showWeeklyDetailModal(Map<String, dynamic> report, int weekNum, String dateRange) {
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
              Text("Week $weekNum ($dateRange)", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E))),
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
                  onPressed: () => _generateWeeklyPdf(report, weekNum, dateRange),
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
        title: Text("Reports for ${widget.year}", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Download Yearly Review PDF",
            onPressed: _generateYearlyPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 52,
        itemBuilder: (context, index) {
          final weekNum = index + 1;
          final dateRange = _getWeekDateRange(widget.year, weekNum);

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
              title: Text("Week $weekNum ($dateRange)", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Completed: $completed | Incomplete: $incomplete"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showWeeklyDetailModal(reportData, weekNum, dateRange),
            ),
          );
        },
      ),
    );
  }
}