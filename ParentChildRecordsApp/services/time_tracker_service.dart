import 'dart:async';
import 'package:flutter/widgets.dart';
import '../database/database_helper.dart';

class TimeTrackerService with WidgetsBindingObserver {
  static final TimeTrackerService instance = TimeTrackerService._internal();

  Timer? _timer;
  ScreenCategory? _activeCategory;

  TimeTrackerService._internal();

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void startTracking(ScreenCategory category) {
    stopTracking();
    _activeCategory = category;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeCategory != null) {
        DatabaseHelper.instance.incrementTimeSpent(_activeCategory!, 1);
      }
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _activeCategory = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      stopTracking();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTracking();
  }
}