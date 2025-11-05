// Imports/Packages
import 'dart:math';
import 'package:adhd_todo/model/entities.dart';

abstract class ILocalStore {
  // Read settings
  Future<UserSettings?> readSettings();
  // Write default settings
  Future<UserSettings> writeDefaultSettings();
  // Save settings
  Future<void> saveSettings(UserSettings s);

  // Read all tasks
  Future<List<Task>> readTasks();
  // Insert a task
  Future<Task> insertTask(String title, Duration defaultDuration);
  // Update a task
  Future<Task> updateTask(Task updated);
  // Delete a task
  Future<bool> deleteTask(String id);
}

class InMemoryLocalStore implements ILocalStore {
  final List<Task> _tasks = <Task>[];
  UserSettings? _settings;

  // Read settings
  @override
  Future<UserSettings?> readSettings() async => _settings;

  // Write default settings
  @override
  Future<UserSettings> writeDefaultSettings() async {
    // Build defaults
    _settings = const UserSettings(
      notificationsEnabled: false,
      defaultTaskDuration: Duration(minutes: 30),
      reminderLeadTime: Duration(minutes: 15),
    );
    return _settings!;
  }

  // Save settings
  @override
  Future<void> saveSettings(UserSettings s) async {
    _settings = s;
  }

  // Read all tasks
  @override
  Future<List<Task>> readTasks() async => List<Task>.from(_tasks);

  // Insert a task
  @override
  Future<Task> insertTask(String title, Duration defaultDuration) async {
    // Build task
    final task = Task(
      id: _nextId(),
      title: title,
      date: null,
      deadline: null,
      duration: defaultDuration,
      status: TaskStatus.active,
      assignedList: ListKind.today,
      remindOnStart: false,
      remindOnDeadline: false,
    );
    // Save task
    _tasks.add(task);
    return task;
  }

  // Update a task
  @override
  Future<Task> updateTask(Task updated) async {
    // Find and replace or add
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) {
      _tasks.add(updated);
      return updated;
    }
    _tasks[idx] = updated;
    return updated;
  }

  // Delete a task
  @override
  Future<bool> deleteTask(String id) async {
    // Remove by id
    final before = _tasks.length;
    _tasks.removeWhere((t) => t.id == id);
    return _tasks.length != before;
  }

  // Generate a new id
  String _nextId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final r = Random().nextInt(1 << 32);
    return 't_${ts}_$r';
  }
}

typedef LocalStore = InMemoryLocalStore;
