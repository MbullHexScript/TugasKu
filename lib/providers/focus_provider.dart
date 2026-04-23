import 'package:flutter/foundation.dart';
import '../services/hive_service.dart';

class FocusProvider extends ChangeNotifier {
  int _totalMinutes = 0;
  int _streakDays = 0;

  FocusProvider() {
    _load();
  }

  int get totalMinutes => _totalMinutes;
  int get streakDays => _streakDays;
  int get totalHours => _totalMinutes ~/ 60;

  void _load() {
    _totalMinutes = HiveService.getFocusTotalMinutes();
    _streakDays = HiveService.getFocusStreakDays();
    notifyListeners();
  }

  void reload() => _load();

  Future<void> addSessionMinutes(int minutes) async {
    await HiveService.addFocusMinutes(minutes);
    _load();
  }
}
