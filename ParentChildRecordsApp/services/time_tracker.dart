import 'package:flutter/widgets.dart';
import '../database/database_helper.dart';

class TimeTracker with WidgetsBindingObserver {
  final String category; // 'me', 'spouse', or 'kids'
  final Stopwatch _stopwatch = Stopwatch();

  TimeTracker(this.category);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _stopwatch.start();
  }

  Future<void> stopAndSave() async {
    WidgetsBinding.instance.removeObserver(this);
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      final seconds = _stopwatch.elapsed.inSeconds;
      await DatabaseHelper.instance.accumulateTimeSpent(category, seconds);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        final seconds = _stopwatch.elapsed.inSeconds;
        DatabaseHelper.instance.accumulateTimeSpent(category, seconds);
        _stopwatch.reset();
      }
    } else if (state == AppLifecycleState.resumed) {
      _stopwatch.start();
    }
  }
}