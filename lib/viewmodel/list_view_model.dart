// Imports/Packages
import 'package:flutter/foundation.dart';
import 'package:adhd_todo/model/entities.dart' as ent;
import 'package:adhd_todo/model/app_model.dart';

class ListCounts {
  final int today;
  final int week;
  final int month;
  final int all;
  const ListCounts(
      {this.today = 0, this.week = 0, this.month = 0, this.all = 0});

  // Create a modified copy
  ListCounts copyWith({int? today, int? week, int? month, int? all}) =>
      ListCounts(
        today: today ?? this.today,
        week: week ?? this.week,
        month: month ?? this.month,
        all: all ?? this.all,
      );
}

class ListViewModel extends ChangeNotifier {
  final AppModel _app;

  ListViewModel(this._app);

  static const todaySeg = ent.ListSegment(kind: ent.ListKind.today);
  static const weekSeg = ent.ListSegment(kind: ent.ListKind.week);
  static const monthSeg = ent.ListSegment(kind: ent.ListKind.month);
  static const allSeg = ent.ListSegment(kind: ent.ListKind.all);

  static const List<ent.ListSegment> segments = <ent.ListSegment>[
    todaySeg,
    weekSeg,
    monthSeg,
    allSeg,
  ];

  ent.ListSegment _currentSegment = todaySeg;
  ent.ListSegment get currentSegment => _currentSegment;

  int get currentIndex => segments.indexOf(_currentSegment);

  List<ent.Task> _currentTasks = const <ent.Task>[];
  List<ent.Task> get currentTasks => _currentTasks;

  ListCounts _counts = const ListCounts();
  ListCounts get counts => _counts;

  // Initialize data
  Future<void> initialize() async {
    await _refreshCurrent();
    notifyListeners();
  }

  // Select a segment
  Future<void> selectSegment(ent.ListSegment seg) async {
    if (_currentSegment == seg) return;
    _currentSegment = seg;
    await _refreshCurrent();
    notifyListeners();
  }

  // Select a segment by index
  Future<void> selectIndex(int index) async {
    if (index < 0 || index >= segments.length) return;
    final seg = segments[index];
    if (_currentSegment == seg) return;
    _currentSegment = seg;
    await _refreshCurrent();
    notifyListeners();
  }

  // Add a task
  Future<void> addTask(
    String title, {
    DateTime? deadline,
    Duration? duration,
    bool remindOnStart = false,
    bool remindOnDeadline = false,
  }) async {
    await _app.addTask(
      title,
      deadline: deadline,
      duration: duration,
      remindOnStart: remindOnStart,
      remindOnDeadline: remindOnDeadline,
    );

    await _refreshCurrent();
    notifyListeners();
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    final ok = await _app.deleteTask(id);
    if (ok) {
      await _refreshCurrent();
      notifyListeners();
    }
  }

  // Complete a task
  Future<void> completeTask(String id) async {
    final saved = await _app.completeTask(id);
    if (saved != null) {
      await _refreshCurrent();
      notifyListeners();
    }
  }

  // Edit a task
  Future<void> editTask(String id, ent.TaskChanges changes) async {
    final saved = await _app.editTask(id, changes);
    if (saved != null) {
      await _refreshCurrent();
      notifyListeners();
    }
  }

  // Get a task by id
  ent.Task? getTask(String id) {
    for (final t in _currentTasks) {
      if (t.id == id) return t;
    }
    for (final t in _app.tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // Decide whether to prompt when moving a task
  Future<bool> shouldPromptForMove({
    required String taskId,
    required ent.ListKind target,
  }) async {
    final t = getTask(taskId);
    if (t == null) return false;

    // Skip non-bucket target
    if (target == ent.ListKind.all) return false;
    if (t.assignedList == target) return false;

    // Skip when no deadline
    final d = t.deadline;
    if (d == null) return false;

    // Compute window bounds
    final win = _DeadlinesWindow.now();

    switch (target) {
      case ent.ListKind.today:
        return false;
      case ent.ListKind.week:
        return d.isBefore(win.endTodayExcl);
      case ent.ListKind.month:
        return d.isBefore(win.endWeekExclForList);
      case ent.ListKind.all:
        return false;
    }
  }

  // Move task ignoring deadline
  Future<void> moveIgnoringDeadline({
    required String taskId,
    required ent.ListKind target,
  }) async {
    final t = getTask(taskId);
    if (t != null && t.deadline != null) {
      final win = _DeadlinesWindow.now();

      // Check if moving to a later bucket
      final isLaterCase = switch (target) {
        ent.ListKind.today => false,
        ent.ListKind.week => t.deadline!.isBefore(win.endTodayExcl),
        ent.ListKind.month => t.deadline!.isBefore(win.endWeekExclForList),
        ent.ListKind.all => false,
      };

      // Clear deadline if moving later
      if (isLaterCase) {
        await _app.editTask(t.id, const ent.TaskChanges(clearDeadline: true));
      }
    }

    // Apply move
    await _app.moveTaskToList(taskId, target);
    await _refreshCurrent();
    notifyListeners();
  }

  // Move task with a new deadline
  Future<void> moveWithNewDeadline({
    required String taskId,
    required ent.ListKind target,
    required DateTime newDeadline,
  }) async {
    final t = getTask(taskId);
    if (t == null) return;
    await _app.editTask(t.id, ent.TaskChanges(deadline: newDeadline));
    await _app.moveTaskToList(t.id, target);
    await _refreshCurrent();
    notifyListeners();
  }

  // Move task while clearing the deadline
  Future<void> moveClearingDeadline({
    required String taskId,
    required ent.ListKind target,
  }) async {
    final t = getTask(taskId);
    if (t == null) return;
    await _app.editTask(t.id, const ent.TaskChanges(clearDeadline: true));
    await _app.moveTaskToList(t.id, target);
    await _refreshCurrent();
    notifyListeners();
  }

  // Refresh current list and counts
  Future<void> _refreshCurrent() async {
    _currentTasks = await _app.listTasks(kind: _currentSegment.kind);
    _counts = await _recount();
  }

  // Recount tasks per list
  Future<ListCounts> _recount() async {
    final today = await _app.listTasks(kind: ent.ListKind.today);
    final week = await _app.listTasks(kind: ent.ListKind.week);
    final month = await _app.listTasks(kind: ent.ListKind.month);
    final all = await _app.listTasks(kind: ent.ListKind.all);
    return ListCounts(
      today: today.length,
      week: week.length,
      month: month.length,
      all: all.length,
    );
  }
}

// Deadline window helpers
class _DeadlinesWindow {
  final DateTime endTodayExcl;
  final DateTime endWeekExclForList;
  final DateTime endMonthExcl;

  _DeadlinesWindow(
      this.endTodayExcl, this.endWeekExclForList, this.endMonthExcl);

  // Create window for now
  static _DeadlinesWindow now() {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final endTodayExcl = startToday.add(const Duration(days: 1));

    // Compute start of week (Monday)
    DateTime startOfWeekLocal(DateTime anchor) {
      final anchorStart = DateTime(anchor.year, anchor.month, anchor.day);
      final weekday = anchorStart.weekday;
      final daysToSubtract = weekday - DateTime.monday;
      return anchorStart.subtract(Duration(days: daysToSubtract));
    }

    // Compute Sunday-aware week end for list bucketing
    final isSunday = now.weekday == DateTime.sunday;
    final listAnchor = isSunday ? now.add(const Duration(days: 1)) : now;
    final startOfListWeek = startOfWeekLocal(listAnchor);
    final endWeekExclForList = startOfListWeek.add(const Duration(days: 7));

    // Compute first day of next month
    final endMonthExcl = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);

    return _DeadlinesWindow(endTodayExcl, endWeekExclForList, endMonthExcl);
  }
}
