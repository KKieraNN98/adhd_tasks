// Imports/Packages
import 'package:flutter/material.dart';

enum TaskStatus { active, completed, deleted }
enum DelayAmount { minutes15, hour1, tomorrow, nextWeek }
enum RepeatRule { none, daily, weekly, monthly }
enum ListKind { today, week, month, all }

class ListSegment {
  final ListKind kind;
  final DateTime? day;
  const ListSegment({required this.kind, this.day});
}

class TimeWindow {
  final DateTime startDate;
  final Duration duration;

  const TimeWindow({required this.startDate, required this.duration});

  // Get end date
  DateTime get endDate => startDate.add(duration);

  // Check if time is within window
  bool contains(DateTime t) => !t.isBefore(startDate) && t.isBefore(endDate);
}

class ScheduleSlot {
  final String id;
  final String taskId;
  final DateTime start;
  final DateTime end;
  final bool isLocked;

  const ScheduleSlot({
    required this.id,
    required this.taskId,
    required this.start,
    required this.end,
    this.isLocked = false,
  });

  // Get slot duration
  Duration get length => end.difference(start);
}

const Object _unset = Object();

class Task {
  final String id;
  final String title;
  final DateTime? date;
  final DateTime? deadline;
  final Duration duration;
  final TaskStatus status;
  final RepeatRule repeatRule;
  final ListKind assignedList;
  final DateTime? completedAt;
  final bool remindOnStart;
  final bool remindOnDeadline;

  const Task({
    required this.id,
    required this.title,
    required this.duration,
    this.date,
    this.deadline,
    this.status = TaskStatus.active,
    this.repeatRule = RepeatRule.none,
    this.assignedList = ListKind.today,
    this.completedAt,
    this.remindOnStart = false,
    this.remindOnDeadline = false,
  });

  // Create a modified copy
  Task copyWith({
    String? id,
    String? title,
    Object? date = _unset,
    Object? deadline = _unset,
    Object? completedAt = _unset,
    Duration? duration,
    TaskStatus? status,
    RepeatRule? repeatRule,
    ListKind? assignedList,
    bool? remindOnStart,
    bool? remindOnDeadline,
  }) {
    final DateTime? nextDate =
        identical(date, _unset) ? this.date : date as DateTime?;
    final DateTime? nextDeadline =
        identical(deadline, _unset) ? this.deadline : deadline as DateTime?;
    final DateTime? nextCompletedAt =
        identical(completedAt, _unset) ? this.completedAt : completedAt as DateTime?;

    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: nextDate,
      deadline: nextDeadline,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      repeatRule: repeatRule ?? this.repeatRule,
      assignedList: assignedList ?? this.assignedList,
      completedAt: nextCompletedAt,
      remindOnStart: remindOnStart ?? this.remindOnStart,
      remindOnDeadline: remindOnDeadline ?? this.remindOnDeadline,
    );
  }

  // Get end time
  DateTime? get end => date?.add(duration);

  // Check if task is overdue
  bool get isOverdue =>
      status == TaskStatus.active &&
      deadline != null &&
      deadline!.isBefore(DateTime.now());

  // Check if task is scheduled
  bool get isPlanned => status == TaskStatus.active && date != null;

  // Check if completed before deadline
  bool get completedBeforeDeadline =>
      status == TaskStatus.completed &&
      deadline != null &&
      completedAt != null &&
      !completedAt!.isAfter(deadline!);
}

class TaskChanges {
  final String? title;
  final DateTime? date;
  final DateTime? deadline;
  final Duration? duration;
  final TaskStatus? status;
  final RepeatRule? repeatRule;
  final ListKind? assignedList;
  final bool? remindOnStart;
  final bool? remindOnDeadline;
  final bool clearDeadline;

  const TaskChanges({
    this.title,
    this.date,
    this.deadline,
    this.duration,
    this.status,
    this.repeatRule,
    this.assignedList,
    this.remindOnStart,
    this.remindOnDeadline,
    this.clearDeadline = false,
  });
}

class ProgressData {
  final TimeWindow window;
  final int tasksCompleted;
  final int totalTasks;
  final int tasksPlanned;
  final int streakDays;
  final int pointsEarned;
  final Duration totalFocus;

  const ProgressData({
    required this.window,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.tasksPlanned,
    required this.streakDays,
    required this.pointsEarned,
    required this.totalFocus,
  });

  // Create a modified copy
  ProgressData copyWith({
    TimeWindow? window,
    int? tasksCompleted,
    int? totalTasks,
    int? tasksPlanned,
    int? streakDays,
    int? pointsEarned,
    Duration? totalFocus,
  }) {
    return ProgressData(
      window: window ?? this.window,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      totalTasks: totalTasks ?? this.totalTasks,
      tasksPlanned: tasksPlanned ?? this.tasksPlanned,
      streakDays: streakDays ?? this.streakDays,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      totalFocus: totalFocus ?? this.totalFocus,
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final Duration defaultTaskDuration;
  final String timeZone;
  final Duration reminderLeadTime;
  final int workStartMinutes;
  final int workEndMinutes;
  final bool nightMode;
  final bool weekendMode;

  const UserSettings({
    this.notificationsEnabled = false,
    this.defaultTaskDuration = const Duration(minutes: 30),
    this.timeZone = 'local',
    this.reminderLeadTime = const Duration(minutes: 15),
    this.workStartMinutes = 8 * 60,
    this.workEndMinutes = 18 * 60,
    this.nightMode = false,
    this.weekendMode = false,
  });

  // Create a modified copy
  UserSettings copyWith({
    bool? notificationsEnabled,
    Duration? defaultTaskDuration,
    String? timeZone,
    Duration? reminderLeadTime,
    int? workStartMinutes,
    int? workEndMinutes,
    bool? nightMode,
    bool? weekendMode,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultTaskDuration: defaultTaskDuration ?? this.defaultTaskDuration,
      timeZone: timeZone ?? this.timeZone,
      reminderLeadTime: reminderLeadTime ?? this.reminderLeadTime,
      workStartMinutes: workStartMinutes ?? this.workStartMinutes,
      workEndMinutes: workEndMinutes ?? this.workEndMinutes,
      nightMode: nightMode ?? this.nightMode,
      weekendMode: weekendMode ?? this.weekendMode,
    );
  }

  // Check if using system time zone
  bool get usesSystemTimeZone => timeZone == 'local';

  // Check if work range is valid
  bool get validWorkRange => workEndMinutes > workStartMinutes;
}

// Material Design 3 Colors 
class AppColors {
  const AppColors._();
  static Color primary(BuildContext c) => Theme.of(c).colorScheme.primary;
  static Color onPrimary(BuildContext c) => Theme.of(c).colorScheme.onPrimary;
  static Color secondary(BuildContext c) => Theme.of(c).colorScheme.secondary;
  static Color onSecondary(BuildContext c) => Theme.of(c).colorScheme.onSecondary;
  static Color surface(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color onSurface(BuildContext c) => Theme.of(c).colorScheme.onSurface;
  static Color background(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color onBackground(BuildContext c) => Theme.of(c).colorScheme.onSurface;
  static Color outline(BuildContext c) => Theme.of(c).colorScheme.outline;
  static Color danger(BuildContext c) => Theme.of(c).colorScheme.error;
  static Color onDanger(BuildContext c) => Theme.of(c).colorScheme.onError;
  static Color mutedOnSurface(BuildContext c, [double opacity = 0.60]) => onSurface(c).withValues(alpha: opacity);
  static Color elevatedSurface(BuildContext c, [double elevationOpacity = 0.05]) => surface(c).withValues(alpha: 1.0 - elevationOpacity);
}
