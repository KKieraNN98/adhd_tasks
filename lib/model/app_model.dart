// Imports/Packages
import 'package:adhd_todo/model/entities.dart';
import 'package:adhd_todo/data/local_store.dart';
import 'package:adhd_todo/platform/notification_gateway.dart';
import 'package:adhd_todo/domain/scheduler.dart' show Scheduler;

class AppModel {
  final ILocalStore store;
  final Scheduler? scheduler;
  final NotificationGateway? notifier;

  AppModel({required this.store, this.scheduler, this.notifier});

  final List<Task> _tasks = <Task>[];
  List<Task> get tasks => List.unmodifiable(_tasks);
  UserSettings _settings = const UserSettings();

  // Get settings
  UserSettings get settings => _settings;

  // Initialize data and state
  Future<void> initialize() async {
    final s = await store.readSettings();
    _settings = s ?? await store.writeDefaultSettings();
    _tasks
      ..clear()
      ..addAll(await store.readTasks());

    // Update lists based on time
    await _oneWayAdvanceAssignments();
  }

  // List tasks by assigned list
  Future<List<Task>> listTasks({ListSegment? segment, ListKind? kind}) async {
    // Update lists based on time
    await _oneWayAdvanceAssignments();

    final k = kind ?? segment?.kind ?? ListKind.all;
    final now = DateTime.now();

    // Visibility after completion
    bool visibleAfterCompletion(Task t) {
      if (t.status != TaskStatus.completed) return true;
      if (t.deadline != null) {
        return now.isBefore(t.deadline!.add(const Duration(hours: 24)));
      }
      if (t.completedAt != null) {
        final endOfCompletionDay = DateTime(
                t.completedAt!.year, t.completedAt!.month, t.completedAt!.day)
            .add(const Duration(days: 1));
        return now.isBefore(endOfCompletionDay);
      }
      return true;
    }

    // Base filtered list
    final base = _tasks.where(
        (t) => t.status != TaskStatus.deleted && visibleAfterCompletion(t));

    // Return by bucket
    switch (k) {
      case ListKind.today:
      case ListKind.week:
      case ListKind.month:
        return base.where((t) => t.assignedList == k).toList();
      case ListKind.all:
        return base.toList();
    }
  }

  // Classify deadline into list
  ListKind _classifyByDeadline(
    DateTime? deadline, {
    required DateTime endTodayExcl,
    required DateTime endWeekExcl,
    required DateTime endMonthExcl,
  }) {
    if (deadline == null) return ListKind.today;

    if (deadline.isBefore(endTodayExcl)) return ListKind.today;

    final inWeek =
        !deadline.isBefore(endTodayExcl) && deadline.isBefore(endWeekExcl);
    if (inWeek) return ListKind.week;

    final inMonth =
        !deadline.isBefore(endWeekExcl) && deadline.isBefore(endMonthExcl);
    if (inMonth) return ListKind.month;

    return ListKind.month;
  }

  // Add a task
  Future<Task> addTask(
    String title, {
    RepeatRule repeatRule = RepeatRule.none,
    DateTime? deadline,
    Duration? duration,
    bool remindOnStart = false,
    bool remindOnDeadline = false,
  }) async {
    // Create task
    final base = await store.insertTask(title, _settings.defaultTaskDuration);

    // Compute boundaries
    final now = DateTime.now();
    final endTodayExcl = _endOfTodayExcl(now);
    final endWeekExclList = _endOfWeekForListExcl(now);
    final endMonthExcl = _endOfMonthExcl(now);

    // Choose initial list
    final initialList = _classifyByDeadline(
      deadline,
      endTodayExcl: endTodayExcl,
      endWeekExcl: endWeekExclList,
      endMonthExcl: endMonthExcl,
    );

    // Save task
    final updated = base.copyWith(
      repeatRule: repeatRule,
      deadline: deadline ?? base.deadline,
      duration: duration ?? base.duration,
      assignedList: initialList,
      remindOnStart: remindOnStart,
      remindOnDeadline: remindOnDeadline,
    );
    final saved = await store.updateTask(updated);
    _tasks.add(saved);

    // Handle notification permissions
    if (notifier != null &&
        ((saved.remindOnStart && saved.date != null) ||
            (saved.remindOnDeadline && saved.deadline != null))) {
      bool postOk = await notifier!.areNotificationsEnabled();
      if (!postOk) {
        postOk = await notifier!.requestEnableNotifications();
      }

      if (postOk) {
        final exactOk = await notifier!.areExactAlarmsEnabled();
        if (!exactOk) {
          await notifier!.requestExactAlarmsPermission();
        }
      }

      if (postOk && !_settings.notificationsEnabled) {
        await saveSettings(_settings.copyWith(notificationsEnabled: true));
      }
    }

    // Sync notifications
    await notifier?.rescheduleReminders(
        saved, const <ScheduleSlot>[], _settings);

    // Return task
    return saved;
  }

  // Complete a task
  Future<Task?> completeTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return null;
    final base = _tasks[idx];
    final now = DateTime.now();
    final saved = await store.updateTask(
      base.copyWith(
        status: TaskStatus.completed,
        completedAt: base.completedAt ?? now,
      ),
    );
    _tasks[idx] = saved;

    // Cancel reminders
    await notifier?.rescheduleReminders(
        saved, const <ScheduleSlot>[], _settings);

    return saved;
  }

  // Delete a task
  Future<bool> deleteTask(String id) async {
    final ok = await store.deleteTask(id);
    if (ok) {
      // Cancel reminders for deleted task
      final ghost = _tasks.firstWhere(
        (t) => t.id == id,
        orElse: () => Task(
          id: id,
          title: '',
          status: TaskStatus.deleted,
          assignedList: ListKind.today,
          duration: const Duration(minutes: 0),
          date: null,
          deadline: null,
        ),
      );
      await notifier?.rescheduleReminders(
          ghost, const <ScheduleSlot>[], _settings);

      _tasks.removeWhere((t) => t.id == id);
    }
    return ok;
  }

  // Edit a task
  Future<Task?> editTask(String id, TaskChanges changes) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return null;
    final base = _tasks[idx];

    // Compute next deadline
    final DateTime? nextDeadline =
        changes.clearDeadline ? null : (changes.deadline ?? base.deadline);

    // Build updated task
    final updated = base.copyWith(
      title: changes.title ?? base.title,
      date: changes.date ?? base.date,
      deadline: nextDeadline,
      duration: changes.duration ?? base.duration,
      status: changes.status ?? base.status,
      repeatRule: changes.repeatRule ?? base.repeatRule,
      assignedList: changes.assignedList ?? base.assignedList,
      remindOnStart: changes.remindOnStart ?? base.remindOnStart,
      remindOnDeadline: changes.remindOnDeadline ?? base.remindOnDeadline,
    );

    // Persist and cache
    final saved = await store.updateTask(updated);
    _tasks[idx] = saved;

    // Handle notification permissions
    if (notifier != null &&
        ((saved.remindOnStart && saved.date != null) ||
            (saved.remindOnDeadline && saved.deadline != null))) {
      bool postOk = await notifier!.areNotificationsEnabled();
      if (!postOk) {
        postOk = await notifier!.requestEnableNotifications();
      }
      if (postOk) {
        final exactOk = await notifier!.areExactAlarmsEnabled();
        if (!exactOk) {
          await notifier!.requestExactAlarmsPermission();
        }
      }
      if (postOk && !_settings.notificationsEnabled) {
        await saveSettings(_settings.copyWith(notificationsEnabled: true));
      }
    }

    // Update list if needed
    await _oneWayAdvanceAssignments(forSingleId: saved.id);

    // Sync notifications
    await notifier?.rescheduleReminders(
        saved, const <ScheduleSlot>[], _settings);

    return saved;
  }

  // Move a task to a different list
  Future<Task?> moveTaskToList(String id, ListKind target) async {
    if (target == ListKind.all) {
      return null;
    }
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return null;
    final base = _tasks[idx];
    if (base.assignedList == target) return base;

    final updated = base.copyWith(assignedList: target);
    final saved = await store.updateTask(updated);
    _tasks[idx] = saved;
    return saved;
  }

  // Generate schedule slots for a window
  Future<List<ScheduleSlot>> generateSchedule(TimeWindow window) async {
    final start = window.startDate;
    final end = window.endDate;

    // Detect day window
    final isDayWindow = window.duration <= const Duration(hours: 24) &&
        (start.hour * 60 + start.minute) == _settings.workStartMinutes;

    if (isDayWindow) {
      // Day bounds
      final dayStart = DateTime(start.year, start.month, start.day);
      final dayEndExcl = dayStart.add(const Duration(days: 1));

      // Existing scheduled tasks
      final existing = _tasks
          .where((t) =>
              t.status == TaskStatus.active &&
              t.date != null &&
              !t.date!.isBefore(start) &&
              t.date!.isBefore(end))
          .toList()
        ..sort((a, b) => a.date!.compareTo(b.date!));

      // Build initial slots
      final slots = <ScheduleSlot>[];
      for (final t in existing) {
        final s = t.date!;
        final e = s.add(t.duration);
        if (!e.isAfter(s)) continue;
        if (s.isBefore(start) || !s.isBefore(end)) continue;
        final id = '${t.id}:${s.millisecondsSinceEpoch}';
        slots.add(ScheduleSlot(id: id, taskId: t.id, start: s, end: e));
      }
      // Track occupied
      final occupied = <ScheduleSlot>[...slots]
        ..sort((a, b) => a.start.compareTo(b.start));

      // Candidates due today
      final scheduledIds = existing.map((t) => t.id).toSet();
      final candidates = _tasks
          .where((t) =>
              t.status == TaskStatus.active &&
              t.deadline != null &&
              !t.deadline!.isBefore(dayStart) &&
              t.deadline!.isBefore(dayEndExcl) &&
              !scheduledIds.contains(t.id))
          .toList()
        ..sort((a, b) {
          final ad = a.deadline!;
          final bd = b.deadline!;
          final cmp = ad.compareTo(bd);
          if (cmp != 0) return cmp;
          return a.duration.compareTo(b.duration);
        });

      // Helpers
      DateTime snapToGridLocal(DateTime dt) {
        final ms = dt.millisecondsSinceEpoch;
        final q = _snapUnit.inMilliseconds;
        final snapped = ((ms + q ~/ 2) ~/ q) * q;
        return DateTime.fromMillisecondsSinceEpoch(snapped);
      }

      bool overlapsLocal(
          DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
        return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
      }

      // Find first fitting gap
      DateTime? firstGapThatFits(Duration len) {
        var probe = start;

        occupied.sort((a, b) => a.start.compareTo(b.start));
        for (final b in occupied) {
          while (probe.isBefore(b.start)) {
            final s = snapToGridLocal(probe);
            final e = s.add(len);
            if ((e.isBefore(b.start) || e.isAtSameMomentAs(b.start)) &&
                e.isBefore(end)) {
              bool ok = true;
              for (final k in occupied) {
                if (overlapsLocal(s, e, k.start, k.end)) {
                  ok = false;
                  break;
                }
              }
              if (ok) return s;
            }
            if (!s.isBefore(b.start)) break;
            probe = s.add(_snapUnit);
          }
          probe = b.end;
        }

        while (probe.isBefore(end)) {
          final s = snapToGridLocal(probe);
          final e = s.add(len);
          if (e.isBefore(end)) {
            bool ok = true;
            for (final k in occupied) {
              if (overlapsLocal(s, e, k.start, k.end)) {
                ok = false;
                break;
              }
            }
            if (ok) return s;
          }
          probe = s.add(_snapUnit);
        }
        return null; // no room
      }

      // Place candidates
      for (final task in candidates) {
        final place = firstGapThatFits(task.duration);
        if (place == null) break;

        if (task.date == null || !task.date!.isAtSameMomentAs(place)) {
          final updated = task.copyWith(date: place);
          final saved = await store.updateTask(updated);
          final i = _tasks.indexWhere((t) => t.id == saved.id);
          if (i != -1) _tasks[i] = saved;

          // Sync notifications
          await notifier?.rescheduleReminders(
              saved, const <ScheduleSlot>[], _settings);
        }

        final id = '${task.id}:${place.millisecondsSinceEpoch}';
        final slot = ScheduleSlot(
          id: id,
          taskId: task.id,
          start: place,
          end: place.add(task.duration),
        );
        slots.add(slot);
        occupied.add(slot);
        occupied.sort((a, b) => a.start.compareTo(b.start));
      }

      // Sorted result
      slots.sort((a, b) => a.start.compareTo(b.start));
      return slots;
    }

    // Non-day windows
    if (scheduler != null) {
      return scheduler!.updateSchedule(_tasks, window);
    }
    return _fallbackSchedule(window);
  }

  // Build slots from dated tasks
  List<ScheduleSlot> _fallbackSchedule(TimeWindow window) {
    final start = window.startDate;
    final end = start.add(window.duration);
    final slots = <ScheduleSlot>[];

    for (final t in _tasks) {
      final d = t.date;
      if (d == null) continue;
      if (t.status == TaskStatus.completed || t.status == TaskStatus.deleted)
        continue;
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      final s = d;
      final e = d.add(t.duration);
      if (!e.isAfter(s)) continue;
      final id = '${t.id}:${s.millisecondsSinceEpoch}';
      slots.add(ScheduleSlot(id: id, taskId: t.id, start: s, end: e));
    }
    slots.sort((a, b) => a.start.compareTo(b.start));
    return slots;
  }

  // Drag and rebalance helpers
  static const Duration _snapUnit = Duration(minutes: 5);

  // Snap time to grid
  DateTime _snapToGrid(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    final q = _snapUnit.inMilliseconds;
    final snapped = ((ms + q ~/ 2) ~/ q) * q;
    return DateTime.fromMillisecondsSinceEpoch(snapped);
  }

  // Apply drag and rebalance
  Future<Task?> applyDrag(
      {required String taskId, DateTime? newStart, Duration? delta}) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx < 0) return null;
    final base = _tasks[idx];

    // Compute candidate start
    DateTime candidate;
    if (newStart != null) {
      candidate = newStart;
    } else {
      final d = base.date ?? DateTime.now();
      candidate = d.add(delta ?? Duration.zero);
    }

    // Compute work window
    final startOfDay = DateTime(candidate.year, candidate.month, candidate.day);
    final workStart =
        startOfDay.add(Duration(minutes: _settings.workStartMinutes));
    final workEnd = startOfDay.add(Duration(minutes: _settings.workEndMinutes));
    final window = TimeWindow(
        startDate: workStart, duration: workEnd.difference(workStart));

    // Constrain start time
    final notBefore = workStart; // allow dragging earlier than current time

    DateTime snapped = _snapToGrid(candidate);
    if (snapped.isBefore(notBefore)) snapped = notBefore;

    final maxStart = workEnd.subtract(base.duration);
    if (snapped.isAfter(maxStart)) snapped = maxStart;

    // Persist updated start
    final updated = base.copyWith(date: snapped);
    final saved = await store.updateTask(updated);
    _tasks[idx] = saved;

    // Sync notifications
    await notifier?.rescheduleReminders(
        saved, const <ScheduleSlot>[], _settings);

    // Rebalance if scheduler exists
    if (scheduler != null) {
      final participants = _tasks.where((t) {
        if (t.status != TaskStatus.active) return false;
        final d = t.date;
        if (d == null) return false;
        return !d.isBefore(window.startDate) && d.isBefore(window.endDate);
      }).toList();

      if (!participants.any((t) => t.id == saved.id)) {
        participants.add(saved);
      }

      final slots = scheduler!.rebalanceForChange(participants, saved, window);

      final Map<String, DateTime> nextStarts = {
        for (final s in slots) s.taskId: s.start,
      };

      for (var i = 0; i < _tasks.length; i++) {
        final t = _tasks[i];
        final ns = nextStarts[t.id];
        if (ns == null) continue;
        if (t.date == null || !t.date!.isAtSameMomentAs(ns)) {
          final patched = t.copyWith(date: ns);
          final persisted = await store.updateTask(patched);
          _tasks[i] = persisted;

          // Sync notifications for shifted tasks
          await notifier?.rescheduleReminders(
              persisted, const <ScheduleSlot>[], _settings);
        }
      }
    }

    return saved;
  }

  // Save settings
  Future<void> saveSettings(UserSettings s) async {
    await store.saveSettings(s);
    _settings = s;
  }

  // Compute progress
  Future<ProgressData> computeProgress(TimeWindow window) async {
    final start = window.startDate;
    final end = start.add(window.duration);

    int completed = 0;
    int total = 0;
    Duration totalFocus = Duration.zero;

    for (final t in _tasks) {
      final d = t.date;
      if (d == null) continue;
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      total++;
      if (t.status == TaskStatus.completed) {
        completed++;
        totalFocus += t.duration;
      }
    }

    return ProgressData(
      window: window,
      tasksCompleted: completed,
      totalTasks: total,
      tasksPlanned: total,
      pointsEarned: completed,
      streakDays: 0,
      totalFocus: totalFocus,
    );
  }

  // Advance list assignments
  Future<void> _oneWayAdvanceAssignments({String? forSingleId}) async {
    final now = DateTime.now();
    final endTodayExcl = _endOfTodayExcl(now);
    final endWeekExclList = _endOfWeekForListExcl(now);
    final endMonthExcl = _endOfMonthExcl(now);

    // Ordering helper
    int orderOf(ListKind k) {
      switch (k) {
        case ListKind.today:
          return 0;
        case ListKind.week:
          return 1;
        case ListKind.month:
          return 2;
        case ListKind.all:
          return 3;
      }
    }

    // Select tasks to process
    final indicesToProcess = <int>[];
    if (forSingleId != null) {
      final i = _tasks.indexWhere((t) => t.id == forSingleId);
      if (i >= 0) indicesToProcess.add(i);
    } else {
      for (var i = 0; i < _tasks.length; i++) {
        indicesToProcess.add(i);
      }
    }

    // Update tasks when needed
    for (final i in indicesToProcess) {
      final t = _tasks[i];
      if (t.status == TaskStatus.deleted) continue;
      if (t.deadline == null) continue;

      final minKind = _classifyByDeadline(
        t.deadline,
        endTodayExcl: endTodayExcl,
        endWeekExcl: endWeekExclList,
        endMonthExcl: endMonthExcl,
      );

      if (orderOf(t.assignedList) > orderOf(minKind)) {
        final patched = t.copyWith(assignedList: minKind);
        final saved = await store.updateTask(patched);
        _tasks[i] = saved;
      }
    }
  }

  // Time helpers
  DateTime _startOfDayLocal(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // End of today (exclusive)
  DateTime _endOfTodayExcl(DateTime dt) =>
      _startOfDayLocal(dt).add(const Duration(days: 1));

  // Start of this week (Monday)
  DateTime _startOfWeekLocal(DateTime dt) {
    final startOfToday = _startOfDayLocal(dt);
    final weekday = startOfToday.weekday;
    final daysToSubtract = weekday - DateTime.monday;
    return startOfToday.subtract(Duration(days: daysToSubtract));
  }

  // End of this week (exclusive)
  DateTime _endOfWeekExcl(DateTime dt) =>
      _startOfWeekLocal(dt).add(const Duration(days: 7));

  // Show next week instead of this week on Sunday
  DateTime _endOfWeekForListExcl(DateTime dt) {
    final isSunday = dt.weekday == DateTime.sunday;
    final anchor = isSunday ? dt.add(const Duration(days: 1)) : dt;
    return _endOfWeekExcl(anchor);
  }

  // End of month (exclusive)
  DateTime _endOfMonthExcl(DateTime dt) {
    if (dt.month == 12) return DateTime(dt.year + 1, 1, 1);
    return DateTime(dt.year, dt.month + 1, 1);
  }
}
