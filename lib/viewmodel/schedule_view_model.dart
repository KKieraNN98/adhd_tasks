// Imports/Packages
import 'package:flutter/foundation.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/model/entities.dart';
import 'package:adhd_todo/domain/scheduler.dart';

class ScheduleViewModel extends ChangeNotifier {
  final AppModel _app;
  final Scheduler _scheduler;

  TimeWindow _window;
  List<ScheduleSlot> _slots = const [];

  ScheduleViewModel(AppModel app)
      : _app = app,
        _scheduler = app.scheduler ?? Scheduler(),
        _window = TimeWindow(
          startDate: DateTime.now(),
          duration: const Duration(days: 1),
        ) {
    reload();
  }

  TimeWindow get window => _window;
  List<ScheduleSlot> get slots => _slots;

  // Set the current time window and refresh
  Future<void> setWindow(TimeWindow w) async {
    _window = w;
    await reload();
  }

  // Refresh schedule slots for the current window using Today tasks
  Future<void> reload() async {
    final today = await _app.listTasks(kind: ListKind.today);
    _slots = _scheduler.updateSchedule(today, _window);
    notifyListeners();
  }

  // Apply a time delta drag to a task and refresh
  Future<void> applyDrag({
    required String taskId,
    required Duration delta,
  }) async {
    await _app.applyDrag(taskId: taskId, delta: delta);
    await reload();
  }

  // Apply an absolute start time drag to a task and refresh
  Future<void> applyDragToStart({
    required String taskId,
    required DateTime newStart,
  }) async {
    // Find the task and clamp the new start within the window
    final task = _app.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw StateError('Task $taskId not found'),
    );

    final DateTime minStart = _window.startDate;
    final DateTime maxStart = _window.endDate.subtract(task.duration);
    final DateTime clamped = newStart.isBefore(minStart)
        ? minStart
        : (newStart.isAfter(maxStart) ? maxStart : newStart);

    await _app.applyDrag(taskId: taskId, newStart: clamped);
    await reload();
  }
}
