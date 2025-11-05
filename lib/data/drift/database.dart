// Imports/Packages
import 'package:drift/drift.dart';

part 'database.g.dart';

class TasksTable extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  IntColumn get dateMillis => integer().nullable()();
  IntColumn get deadlineMillis => integer().nullable()();
  IntColumn get completedAtMillis => integer().nullable()();

  IntColumn get durationMinutes => integer()();

  IntColumn get status => integer()();
  IntColumn get repeatRule => integer()();
  IntColumn get assignedList => integer()();

  IntColumn get startReminderEnabled =>
      integer().withDefault(const Constant(0))();
  IntColumn get deadlineReminderEnabled =>
      integer().withDefault(const Constant(0))();

  // Define primary key
  @override
  Set<Column> get primaryKey => {id};
}

class SettingsTable extends Table {
  TextColumn get id => text().clientDefault(() => 'settings')();

  IntColumn get notificationsEnabled => integer().withDefault(const Constant(0))();
  IntColumn get nightMode => integer().withDefault(const Constant(0))();
  IntColumn get weekendMode => integer().withDefault(const Constant(0))();

  IntColumn get defaultTaskDurationMinutes =>
      integer().withDefault(const Constant(30))();
  IntColumn get reminderLeadMinutes =>
      integer().withDefault(const Constant(15))();

  IntColumn get workStartMinutes =>
      integer().withDefault(const Constant(8 * 60))();
  IntColumn get workEndMinutes =>
      integer().withDefault(const Constant(18 * 60))();

  TextColumn get timeZone => text().withDefault(const Constant('local'))();

  // Define primary key
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TasksTable, SettingsTable])
class AppDb extends _$AppDb {
  AppDb(super.e);

  // Return schema version
  @override
  int get schemaVersion => 2;

  // Define migration strategy
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Create all tables
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Add columns for version 2
          if (from < 2) {
            // Add reminder toggle columns
            await m.addColumn(tasksTable, tasksTable.startReminderEnabled);
            await m.addColumn(tasksTable, tasksTable.deadlineReminderEnabled);
          }
        },
      );
}
