// Imports/Packages
import 'package:drift/drift.dart' show Value;
import 'package:adhd_todo/data/drift/database.dart';
import 'package:adhd_todo/data/local_store.dart';
import 'package:adhd_todo/model/entities.dart';

class LocalStoreDrift implements ILocalStore {
  final AppDb db;
  LocalStoreDrift(this.db);

  // Read user settings
  @override
  Future<UserSettings?> readSettings() async {
    // Load settings row
    final row = await (db.select(db.settingsTable)
          ..where((tbl) => tbl.id.equals('settings')))
        .getSingleOrNull();
    if (row == null) return null;
    // Map to model
    return _settingsFromRow(row);
  }

  // Write default user settings
  @override
  Future<UserSettings> writeDefaultSettings() async {
    // Build defaults
    final defaultSettings = const UserSettings(
      notificationsEnabled: false,
      defaultTaskDuration: Duration(minutes: 30),
      reminderLeadTime: Duration(minutes: 15),
      workStartMinutes: 8 * 60,
      workEndMinutes: 18 * 60,
      nightMode: false,
      weekendMode: false,
      timeZone: 'local',
    );

    // Build companion for upsert
    final companion = SettingsTableCompanion.insert(
      id: const Value('settings'),
      notificationsEnabled: Value(_bool(defaultSettings.notificationsEnabled)),
      nightMode: Value(_bool(defaultSettings.nightMode)),
      weekendMode: Value(_bool(defaultSettings.weekendMode)),
      defaultTaskDurationMinutes:
          Value(defaultSettings.defaultTaskDuration.inMinutes),
      reminderLeadMinutes: Value(defaultSettings.reminderLeadTime.inMinutes),
      workStartMinutes: Value(defaultSettings.workStartMinutes),
      workEndMinutes: Value(defaultSettings.workEndMinutes),
      timeZone: Value(defaultSettings.timeZone),
    );

    // Upsert settings
    await db.into(db.settingsTable).insertOnConflictUpdate(companion);
    return defaultSettings;
  }

  // Save user settings
  @override
  Future<void> saveSettings(UserSettings s) async {
    // Build companion for upsert
    final companion = SettingsTableCompanion(
      id: const Value('settings'),
      notificationsEnabled: Value(_bool(s.notificationsEnabled)),
      nightMode: Value(_bool(s.nightMode)),
      weekendMode: Value(_bool(s.weekendMode)),
      defaultTaskDurationMinutes: Value(s.defaultTaskDuration.inMinutes),
      reminderLeadMinutes: Value(s.reminderLeadTime.inMinutes),
      workStartMinutes: Value(s.workStartMinutes),
      workEndMinutes: Value(s.workEndMinutes),
      timeZone: Value(s.timeZone),
    );
    // Upsert settings
    await db.into(db.settingsTable).insertOnConflictUpdate(companion);
  }

  // Read all tasks
  @override
  Future<List<Task>> readTasks() async {
    // Fetch rows and map
    final rows = await db.select(db.tasksTable).get();
    return rows.map(_taskFromRow).toList(growable: false);
  }

  // Insert a new task
  @override
  Future<Task> insertTask(String title, Duration defaultDuration) async {
    // Generate id
    final id = _nextId();

    // Build companion
    final companion = TasksTableCompanion.insert(
      id: id,
      title: title,
      dateMillis: const Value<int?>(null),
      deadlineMillis: const Value<int?>(null),
      completedAtMillis: const Value<int?>(null),
      durationMinutes: defaultDuration.inMinutes,
      status: _statusToInt(TaskStatus.active),
      repeatRule: _repeatToInt(RepeatRule.none),
      assignedList: _listToInt(ListKind.today),
      startReminderEnabled: const Value(0),
      deadlineReminderEnabled: const Value(0),
    );

    // Insert row
    await db.into(db.tasksTable).insert(companion);

    // Return model
    return Task(
      id: id,
      title: title,
      date: null,
      deadline: null,
      completedAt: null,
      duration: defaultDuration,
      status: TaskStatus.active,
      repeatRule: RepeatRule.none,
      assignedList: ListKind.today,
      remindOnStart: false,
      remindOnDeadline: false,
    );
  }

  // Update an existing task
  @override
  Future<Task> updateTask(Task updated) async {
    // Build companion
    final companion = TasksTableCompanion(
      id: Value(updated.id),
      title: Value(updated.title),
      dateMillis: Value(_dtToMillis(updated.date)),
      deadlineMillis: Value(_dtToMillis(updated.deadline)),
      completedAtMillis: Value(_dtToMillis(updated.completedAt)),
      durationMinutes: Value(updated.duration.inMinutes),
      status: Value(_statusToInt(updated.status)),
      repeatRule: Value(_repeatToInt(updated.repeatRule)),
      assignedList: Value(_listToInt(updated.assignedList)),
      startReminderEnabled: Value(_bool(updated.remindOnStart)),
      deadlineReminderEnabled: Value(_bool(updated.remindOnDeadline)),
    );

    // Upsert and re-read
    await db.into(db.tasksTable).insertOnConflictUpdate(companion);
    final saved = await (db.select(db.tasksTable)
          ..where((t) => t.id.equals(updated.id)))
        .getSingle();

    // Map to model
    return _taskFromRow(saved);
  }

  // Delete a task
  @override
  Future<bool> deleteTask(String id) async {
    // Delete and return success
    final deleted =
        await (db.delete(db.tasksTable)..where((t) => t.id.equals(id))).go();
    return deleted > 0;
  }

  // Map settings row to model
  UserSettings _settingsFromRow(SettingsTableData r) {
    return UserSettings(
      notificationsEnabled: _boolFromInt(r.notificationsEnabled),
      defaultTaskDuration: Duration(minutes: r.defaultTaskDurationMinutes),
      reminderLeadTime: Duration(minutes: r.reminderLeadMinutes),
      workStartMinutes: r.workStartMinutes,
      workEndMinutes: r.workEndMinutes,
      nightMode: _boolFromInt(r.nightMode),
      weekendMode: _boolFromInt(r.weekendMode),
      timeZone: r.timeZone,
    );
  }

  // Map task row to model
  Task _taskFromRow(TasksTableData r) {
    return Task(
      id: r.id,
      title: r.title,
      date: _millisToDt(r.dateMillis),
      deadline: _millisToDt(r.deadlineMillis),
      completedAt: _millisToDt(r.completedAtMillis),
      duration: Duration(minutes: r.durationMinutes),
      status: _statusFromInt(r.status),
      repeatRule: _repeatFromInt(r.repeatRule),
      assignedList: _listFromInt(r.assignedList),
      remindOnStart: _boolFromInt(r.startReminderEnabled),
      remindOnDeadline: _boolFromInt(r.deadlineReminderEnabled),
    );
  }

  // Convert enums and basic types
  static int _statusToInt(TaskStatus s) => s.index;
  static TaskStatus _statusFromInt(int i) => TaskStatus.values[i];
  static int _repeatToInt(RepeatRule r) => r.index;
  static RepeatRule _repeatFromInt(int i) => RepeatRule.values[i];
  static int _listToInt(ListKind k) => k.index;
  static ListKind _listFromInt(int i) => ListKind.values[i];
  static int _bool(bool v) => v ? 1 : 0;
  static bool _boolFromInt(int v) => v != 0;
  static int? _dtToMillis(DateTime? dt) => dt?.millisecondsSinceEpoch;
  static DateTime? _millisToDt(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);

  // Generate a new task id
  String _nextId() {
    // Build timestamp
    final ts = DateTime.now().microsecondsSinceEpoch;
    // Build pseudo-random component
    final rand = (ts * 1664525 + 1013904223) & 0xFFFFFFFF;
    // Return id string
    return 't_${ts}_$rand';
  }
}
