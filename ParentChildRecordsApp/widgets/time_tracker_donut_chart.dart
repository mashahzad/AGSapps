import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TimeTrackerDonutChart extends StatefulWidget {
  const TimeTrackerDonutChart({Key? key}) : super(key: key);

  @override
  State<TimeTrackerDonutChart> createState() => _TimeTrackerDonutChartState();
}

class _TimeTrackerDonutChartState extends State<TimeTrackerDonutChart> {
  Map<String, double> _chartData = {'Kids': 0.0, 'Spouse': 0.0, 'Me': 0.0};
  bool _isLoading = true;

  final Map<String, Color> _categoryColors = {
    'Kids': Colors.amber.shade600,
    'Spouse': Colors.purple.shade400,
    'Me': Colors.indigo.shade500,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getTimeTrackingData();
    if (mounted) {
      setState(() {
        _chartData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final double totalSeconds = _chartData.values.fold(0, (sum, val) => sum + val);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Daily Time Distribution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      data: _chartData,
                      colors: _categoryColors,
                      total: totalSeconds,
                    ),
                    child: Center(
                      child: Text(
                        _formatTotalTime(totalSeconds),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _categoryColors.keys.map((key) {
                    final double val = _chartData[key] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _categoryColors[key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$key: ${_formatMinutes(val)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(double seconds) {
    final mins = (seconds / 60).round();
    return '$mins mins';
  }

  String _formatTotalTime(double seconds) {
    if (seconds == 0) return 'No Data';
    final mins = (seconds / 60).round();
    return '$mins min total';
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double total;

  DonutChartPainter({
    required this.data,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (total <= 0) return;

    double startAngle = -pi / 2;

    data.forEach((key, value) {
      if (value > 0) {
        final sweepAngle = (value / total) * 2 * pi;
        final paint = Paint()
          ..color = colors[key] ?? Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );

        startAngle += sweepAngle;
      }
    });
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) =>
      oldDelegate.total != total || oldDelegate.data != data;
}