// Imports/Packages
import 'package:adhd_todo/model/entities.dart'
    show Task, TimeWindow, ScheduleSlot, TaskStatus;

class Scheduler {
  static const Duration _snapUnit = Duration(minutes: 5);

  DateTime _snap(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    final q = _snapUnit.inMilliseconds;
    final snapped = ((ms + q ~/ 2) ~/ q) * q;
    return DateTime.fromMillisecondsSinceEpoch(snapped);
  }

  bool _overlaps(
      DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  DateTime? _firstFit({
    required DateTime probe,
    required Duration len,
    required TimeWindow window,
    required List<ScheduleSlot> blocks,
  }) {
    var cursor = probe.isBefore(window.startDate) ? window.startDate : probe;

    // blocks should be sorted for efficient skipping
    blocks.sort((a, b) => a.start.compareTo(b.start));

    while (cursor.isBefore(window.endDate)) {
      final s = _snap(cursor);
      final e = s.add(len);
      if (!e.isBefore(window.endDate)) return null;

      bool fits = true;
      for (final b in blocks) {
        if (_overlaps(s, e, b.start, b.end)) {
          fits = false;
          // jump past the blocking block
          cursor = b.end;
          break;
        }
      }
      if (fits) return s;

      if (cursor == s) {
        cursor = s.add(_snapUnit);
      }
    }
    return null;
  }

  List<ScheduleSlot> _packEarliest({
    required Iterable<Task> tasks,
    required TimeWindow window,
    required List<ScheduleSlot> occupied,
  }) {
    final out = <ScheduleSlot>[];
    final blocks = <ScheduleSlot>[...occupied]
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final t in tasks) {
      if (t.status != TaskStatus.active) continue;

      final start = _firstFit(
        probe: window.startDate,
        len: t.duration,
        window: window,
        blocks: blocks,
      );
      if (start == null) continue;

      final slot = ScheduleSlot(
        id: '${t.id}:${start.millisecondsSinceEpoch}',
        taskId: t.id,
        start: start,
        end: start.add(t.duration),
      );
      out.add(slot);
      blocks.add(slot);
      blocks.sort((a, b) => a.start.compareTo(b.start));
    }

    return out;
  }

  DateTime? _nearestFit({
    required DateTime probe,
    required Duration len,
    required TimeWindow window,
    required List<ScheduleSlot> blocks,
  }) {
    final base = _snap(probe);

    bool fitsAt(DateTime s) {
      final e = s.add(len);
      if (s.isBefore(window.startDate)) return false;
      if (!e.isBefore(window.endDate)) return false;
      for (final b in blocks) {
        if (_overlaps(s, e, b.start, b.end)) return false;
      }
      return true;
    }

    if (fitsAt(base)) return base;

    int step = 1;
    while (true) {
      bool triedAny = false;

      final sEarlier = base.subtract(_snapUnit * step);
      if (!sEarlier.isBefore(window.startDate)) {
        triedAny = true;
        if (fitsAt(sEarlier)) return sEarlier;
      }

      final sLater = base.add(_snapUnit * step);
      if (sLater.isBefore(window.endDate)) {
        triedAny = true;
        if (fitsAt(sLater)) return sLater;
      }

      if (!triedAny) break;
      step += 1;
    }

    return null;
  }

  DateTime? _anchorFor(Task t) {
    if (t.date != null) return _snap(t.date!);
    if (t.deadline != null) return _snap(t.deadline!);
    return null;
  }

  // Helper: convert a task to a fixed slot snapped within window
  ScheduleSlot? _fixedSlotFor(Task t, TimeWindow window) {
    final anchor = _anchorFor(t);
    if (anchor == null) return null;
    final rawStart = anchor;
    final rawEnd = rawStart.add(t.duration);

    final overlaps =
        _overlaps(rawStart, rawEnd, window.startDate, window.endDate);
    if (!overlaps) return null;

    final start =
        rawStart.isBefore(window.startDate) ? window.startDate : rawStart;
    final end = rawEnd.isAfter(window.endDate) ? window.endDate : rawEnd;
    if (!end.isAfter(start)) return null;

    return ScheduleSlot(
      id: '${t.id}:${start.millisecondsSinceEpoch}',
      taskId: t.id,
      start: start,
      end: end,
    );
  }

  // Compute schedule including COMPLETED tasks as fixed/locked occupants
  List<ScheduleSlot> updateSchedule(List<Task> tasks, TimeWindow window) {
    // Completed tasks that overlap the window become fixed blocks & visible slots
    final fixedCompleted = <ScheduleSlot>[];
    for (final t in tasks) {
      if (t.status == TaskStatus.completed) {
        final slot = _fixedSlotFor(t, window);
        if (slot != null) fixedCompleted.add(slot);
      }
    }

    // Active tasks from the list are placed around fixed blocks
    final actives = tasks.where((t) => t.status == TaskStatus.active);

    final anchored = <Task>[];
    final floating = <Task>[];
    for (final t in actives) {
      final a = _anchorFor(t);
      if (a == null) {
        floating.add(t);
      } else {
        anchored.add(t);
      }
    }

    final out = <ScheduleSlot>[...fixedCompleted];
    final blocks = <ScheduleSlot>[...fixedCompleted]
      ..sort((a, b) => a.start.compareTo(b.start));

    anchored.sort((a, b) => (_anchorFor(a)!).compareTo(_anchorFor(b)!));
    for (final t in anchored) {
      final probe = _anchorFor(t)!;
      final s = _nearestFit(
        probe: probe,
        len: t.duration,
        window: window,
        blocks: blocks,
      );
      if (s == null) continue;

      final e = s.add(t.duration);
      final end = e.isAfter(window.endDate) ? window.endDate : e;

      final slot = ScheduleSlot(
        id: '${t.id}:${s.millisecondsSinceEpoch}',
        taskId: t.id,
        start: s,
        end: end,
      );
      out.add(slot);
      blocks.add(slot);
      blocks.sort((a, b) => a.start.compareTo(b.start));
    }

    final packedFloating = _packEarliest(
      tasks: floating,
      window: window,
      occupied: blocks,
    );
    out.addAll(packedFloating);

    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  // Rebalance after a change by pinning one task and placing others nearest
  List<ScheduleSlot> rebalanceForChange(
      List<Task> tasks, Task changed, TimeWindow window) {
    // Fixed blocks from completed tasks that overlap the window
    final fixedCompleted = <ScheduleSlot>[];
    for (final t in tasks) {
      if (t.id == changed.id) continue;
      if (t.status == TaskStatus.completed) {
        final slot = _fixedSlotFor(t, window);
        if (slot != null) fixedCompleted.add(slot);
      }
    }

    final anchorChanged = _anchorFor(changed);
    if (anchorChanged == null) {
      final all = <ScheduleSlot>[...fixedCompleted]
        ..sort((a, b) => a.start.compareTo(b.start));
      return all;
    }

    // Pin the changed task at its snapped time
    final pinStart = _snap(anchorChanged);
    final pinEnd = pinStart.add(changed.duration);
    if (!pinEnd.isAfter(pinStart) || !pinStart.isBefore(window.endDate)) {
      final all = <ScheduleSlot>[...fixedCompleted]
        ..sort((a, b) => a.start.compareTo(b.start));
      return all;
    }
    final pinned = ScheduleSlot(
      id: '${changed.id}:${pinStart.millisecondsSinceEpoch}',
      taskId: changed.id,
      start: pinStart.isBefore(window.startDate) ? window.startDate : pinStart,
      end: pinEnd.isAfter(window.endDate) ? window.endDate : pinEnd,
    );

    final others = tasks
        .where((t) => t.id != changed.id && t.status == TaskStatus.active)
        .toList()
      ..sort((a, b) {
        final aa = _anchorFor(a);
        final bb = _anchorFor(b);
        if (aa == null && bb == null) return 0;
        if (aa == null) return 1;
        if (bb == null) return -1;
        return aa.compareTo(bb);
      });

    final blocks = <ScheduleSlot>[...fixedCompleted, pinned]
      ..sort((a, b) => a.start.compareTo(b.start));
    final out = <ScheduleSlot>[...fixedCompleted, pinned];

    for (final t in others) {
      final probe = _anchorFor(t) ?? window.startDate;
      final target = _nearestFit(
        probe: probe,
        len: t.duration,
        window: window,
        blocks: blocks,
      );
      if (target == null) continue;

      final e = target.add(t.duration);
      final end = e.isAfter(window.endDate) ? window.endDate : e;

      final slot = ScheduleSlot(
        id: '${t.id}:${target.millisecondsSinceEpoch}',
        taskId: t.id,
        start: target,
        end: end,
      );
      out.add(slot);
      blocks.add(slot);
      blocks.sort((a, b) => a.start.compareTo(b.start));
    }

    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }
}
