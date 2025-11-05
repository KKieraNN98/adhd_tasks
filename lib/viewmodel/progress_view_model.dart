// Imports/Packages
import 'package:flutter/foundation.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/model/entities.dart';

class ProgressViewModel extends ChangeNotifier {
  final AppModel app;
  ProgressData? _current;
  TimeWindow? _lastWindow;
  ListKind _currentKind = ListKind.today;

  ProgressViewModel(this.app);

  static const int expPerMinute = 43;
  static const int defaultExpNoDuration = 200;
  static const List<int> levelThresholds = [
    3000,
    8000,
    14000,
    21000,
    29000,
    39000
  ];

  int _expIntoLevel = 0;
  int _expToNextLevel = 0;
  int _currentLevel = 1;

  int _listCompleted = 0;
  int _listPlanned = 0;
  int _listTotal = 0;

  String _rateDisplay = "~";
  String _streakDisplay = "~";

  ProgressData? get current => _current;
  TimeWindow? get lastWindow => _lastWindow;

  int get currentExp => _expIntoLevel;
  int get nextLevelExp => _expToNextLevel;
  int get currentLevel => _currentLevel;

  int get completed => _listCompleted;
  int get total => _listTotal;
  int get tasksPlanned => _listPlanned;

  String get rateDisplay => _rateDisplay;
  String get streakDisplay => _streakDisplay;

  // Set the selected list and time window, then recompute
  Future<ProgressData> setContext({
    required ListKind kind,
    required TimeWindow window,
  }) async {
    _currentKind = kind;
    _lastWindow = window;
    final data = await app.computeProgress(window);
    _current = data;
    _recomputeDerived();
    notifyListeners();
    return data;
  }

  // Load data for a time window
  Future<ProgressData> load(TimeWindow window) async {
    _lastWindow = window;
    final data = await app.computeProgress(window);
    _current = data;
    _recomputeDerived();
    notifyListeners();
    return data;
  }

  // Refresh with the last window
  Future<ProgressData> refresh() async {
    final w = _lastWindow ??
        TimeWindow(
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          duration: const Duration(days: 7),
        );
    final data = await app.computeProgress(w);
    _current = data;
    _recomputeDerived();
    notifyListeners();
    return data;
  }

  // Recompute EXP, level, and list metrics
  void _recomputeDerived() {
    final tasks = app.tasks;

    // Compute total EXP from completed tasks
    int totalExp = 0;
    for (final t in tasks) {
      if (t.status == TaskStatus.completed) {
        final durMinutes = t.duration.inMinutes;
        if (durMinutes > 0) {
          totalExp += durMinutes * expPerMinute;
        } else {
          totalExp += defaultExpNoDuration;
        }
      }
    }

    // Compute level values
    final thresholds = levelThresholds;
    int level = 1;
    int floor = 0;
    int? next;
    for (final th in thresholds) {
      if (totalExp >= th) {
        level++;
        floor = th;
      } else {
        next = th;
        break;
      }
    }
    _currentLevel = level;
    if (next == null) {
      _expIntoLevel = 1;
      _expToNextLevel = 1;
    } else {
      _expIntoLevel = totalExp - floor;
      _expToNextLevel = next - floor;
      if (_expToNextLevel <= 0) {
        _expToNextLevel = 1;
      }
    }

    // Compute per-list metrics for the selected list
    bool inSelectedList(Task t) {
      if (_currentKind == ListKind.all) {
        return t.status != TaskStatus.deleted;
      }
      return t.assignedList == _currentKind && t.status != TaskStatus.deleted;
    }

    _listTotal = 0;
    _listCompleted = 0;
    _listPlanned = 0;

    for (final t in tasks) {
      if (!inSelectedList(t)) continue;
      _listTotal++;
      if (t.status == TaskStatus.completed) {
        _listCompleted++;
      } else if (t.status == TaskStatus.active) {
        _listPlanned++;
      }
    }

    // Update placeholder displays
    _rateDisplay = "~";
    _streakDisplay = "~";
  }
}
