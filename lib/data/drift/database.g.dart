// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TasksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMillisMeta =
      const VerificationMeta('dateMillis');
  @override
  late final GeneratedColumn<int> dateMillis = GeneratedColumn<int>(
      'date_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMillisMeta =
      const VerificationMeta('deadlineMillis');
  @override
  late final GeneratedColumn<int> deadlineMillis = GeneratedColumn<int>(
      'deadline_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMillisMeta =
      const VerificationMeta('completedAtMillis');
  @override
  late final GeneratedColumn<int> completedAtMillis = GeneratedColumn<int>(
      'completed_at_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repeatRuleMeta =
      const VerificationMeta('repeatRule');
  @override
  late final GeneratedColumn<int> repeatRule = GeneratedColumn<int>(
      'repeat_rule', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _assignedListMeta =
      const VerificationMeta('assignedList');
  @override
  late final GeneratedColumn<int> assignedList = GeneratedColumn<int>(
      'assigned_list', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startReminderEnabledMeta =
      const VerificationMeta('startReminderEnabled');
  @override
  late final GeneratedColumn<int> startReminderEnabled = GeneratedColumn<int>(
      'start_reminder_enabled', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deadlineReminderEnabledMeta =
      const VerificationMeta('deadlineReminderEnabled');
  @override
  late final GeneratedColumn<int> deadlineReminderEnabled =
      GeneratedColumn<int>('deadline_reminder_enabled', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        dateMillis,
        deadlineMillis,
        completedAtMillis,
        durationMinutes,
        status,
        repeatRule,
        assignedList,
        startReminderEnabled,
        deadlineReminderEnabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(Insertable<TasksTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date_millis')) {
      context.handle(
          _dateMillisMeta,
          dateMillis.isAcceptableOrUnknown(
              data['date_millis']!, _dateMillisMeta));
    }
    if (data.containsKey('deadline_millis')) {
      context.handle(
          _deadlineMillisMeta,
          deadlineMillis.isAcceptableOrUnknown(
              data['deadline_millis']!, _deadlineMillisMeta));
    }
    if (data.containsKey('completed_at_millis')) {
      context.handle(
          _completedAtMillisMeta,
          completedAtMillis.isAcceptableOrUnknown(
              data['completed_at_millis']!, _completedAtMillisMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
          _repeatRuleMeta,
          repeatRule.isAcceptableOrUnknown(
              data['repeat_rule']!, _repeatRuleMeta));
    } else if (isInserting) {
      context.missing(_repeatRuleMeta);
    }
    if (data.containsKey('assigned_list')) {
      context.handle(
          _assignedListMeta,
          assignedList.isAcceptableOrUnknown(
              data['assigned_list']!, _assignedListMeta));
    } else if (isInserting) {
      context.missing(_assignedListMeta);
    }
    if (data.containsKey('start_reminder_enabled')) {
      context.handle(
          _startReminderEnabledMeta,
          startReminderEnabled.isAcceptableOrUnknown(
              data['start_reminder_enabled']!, _startReminderEnabledMeta));
    }
    if (data.containsKey('deadline_reminder_enabled')) {
      context.handle(
          _deadlineReminderEnabledMeta,
          deadlineReminderEnabled.isAcceptableOrUnknown(
              data['deadline_reminder_enabled']!,
              _deadlineReminderEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasksTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      dateMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date_millis']),
      deadlineMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deadline_millis']),
      completedAtMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_at_millis']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      repeatRule: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repeat_rule'])!,
      assignedList: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}assigned_list'])!,
      startReminderEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}start_reminder_enabled'])!,
      deadlineReminderEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deadline_reminder_enabled'])!,
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TasksTableData extends DataClass implements Insertable<TasksTableData> {
  final String id;
  final String title;
  final int? dateMillis;
  final int? deadlineMillis;
  final int? completedAtMillis;
  final int durationMinutes;
  final int status;
  final int repeatRule;
  final int assignedList;
  final int startReminderEnabled;
  final int deadlineReminderEnabled;
  const TasksTableData(
      {required this.id,
      required this.title,
      this.dateMillis,
      this.deadlineMillis,
      this.completedAtMillis,
      required this.durationMinutes,
      required this.status,
      required this.repeatRule,
      required this.assignedList,
      required this.startReminderEnabled,
      required this.deadlineReminderEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dateMillis != null) {
      map['date_millis'] = Variable<int>(dateMillis);
    }
    if (!nullToAbsent || deadlineMillis != null) {
      map['deadline_millis'] = Variable<int>(deadlineMillis);
    }
    if (!nullToAbsent || completedAtMillis != null) {
      map['completed_at_millis'] = Variable<int>(completedAtMillis);
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['status'] = Variable<int>(status);
    map['repeat_rule'] = Variable<int>(repeatRule);
    map['assigned_list'] = Variable<int>(assignedList);
    map['start_reminder_enabled'] = Variable<int>(startReminderEnabled);
    map['deadline_reminder_enabled'] = Variable<int>(deadlineReminderEnabled);
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      id: Value(id),
      title: Value(title),
      dateMillis: dateMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(dateMillis),
      deadlineMillis: deadlineMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineMillis),
      completedAtMillis: completedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtMillis),
      durationMinutes: Value(durationMinutes),
      status: Value(status),
      repeatRule: Value(repeatRule),
      assignedList: Value(assignedList),
      startReminderEnabled: Value(startReminderEnabled),
      deadlineReminderEnabled: Value(deadlineReminderEnabled),
    );
  }

  factory TasksTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasksTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      dateMillis: serializer.fromJson<int?>(json['dateMillis']),
      deadlineMillis: serializer.fromJson<int?>(json['deadlineMillis']),
      completedAtMillis: serializer.fromJson<int?>(json['completedAtMillis']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      status: serializer.fromJson<int>(json['status']),
      repeatRule: serializer.fromJson<int>(json['repeatRule']),
      assignedList: serializer.fromJson<int>(json['assignedList']),
      startReminderEnabled:
          serializer.fromJson<int>(json['startReminderEnabled']),
      deadlineReminderEnabled:
          serializer.fromJson<int>(json['deadlineReminderEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'dateMillis': serializer.toJson<int?>(dateMillis),
      'deadlineMillis': serializer.toJson<int?>(deadlineMillis),
      'completedAtMillis': serializer.toJson<int?>(completedAtMillis),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'status': serializer.toJson<int>(status),
      'repeatRule': serializer.toJson<int>(repeatRule),
      'assignedList': serializer.toJson<int>(assignedList),
      'startReminderEnabled': serializer.toJson<int>(startReminderEnabled),
      'deadlineReminderEnabled':
          serializer.toJson<int>(deadlineReminderEnabled),
    };
  }

  TasksTableData copyWith(
          {String? id,
          String? title,
          Value<int?> dateMillis = const Value.absent(),
          Value<int?> deadlineMillis = const Value.absent(),
          Value<int?> completedAtMillis = const Value.absent(),
          int? durationMinutes,
          int? status,
          int? repeatRule,
          int? assignedList,
          int? startReminderEnabled,
          int? deadlineReminderEnabled}) =>
      TasksTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        dateMillis: dateMillis.present ? dateMillis.value : this.dateMillis,
        deadlineMillis:
            deadlineMillis.present ? deadlineMillis.value : this.deadlineMillis,
        completedAtMillis: completedAtMillis.present
            ? completedAtMillis.value
            : this.completedAtMillis,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        status: status ?? this.status,
        repeatRule: repeatRule ?? this.repeatRule,
        assignedList: assignedList ?? this.assignedList,
        startReminderEnabled: startReminderEnabled ?? this.startReminderEnabled,
        deadlineReminderEnabled:
            deadlineReminderEnabled ?? this.deadlineReminderEnabled,
      );
  TasksTableData copyWithCompanion(TasksTableCompanion data) {
    return TasksTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      dateMillis:
          data.dateMillis.present ? data.dateMillis.value : this.dateMillis,
      deadlineMillis: data.deadlineMillis.present
          ? data.deadlineMillis.value
          : this.deadlineMillis,
      completedAtMillis: data.completedAtMillis.present
          ? data.completedAtMillis.value
          : this.completedAtMillis,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      status: data.status.present ? data.status.value : this.status,
      repeatRule:
          data.repeatRule.present ? data.repeatRule.value : this.repeatRule,
      assignedList: data.assignedList.present
          ? data.assignedList.value
          : this.assignedList,
      startReminderEnabled: data.startReminderEnabled.present
          ? data.startReminderEnabled.value
          : this.startReminderEnabled,
      deadlineReminderEnabled: data.deadlineReminderEnabled.present
          ? data.deadlineReminderEnabled.value
          : this.deadlineReminderEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('dateMillis: $dateMillis, ')
          ..write('deadlineMillis: $deadlineMillis, ')
          ..write('completedAtMillis: $completedAtMillis, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('assignedList: $assignedList, ')
          ..write('startReminderEnabled: $startReminderEnabled, ')
          ..write('deadlineReminderEnabled: $deadlineReminderEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      dateMillis,
      deadlineMillis,
      completedAtMillis,
      durationMinutes,
      status,
      repeatRule,
      assignedList,
      startReminderEnabled,
      deadlineReminderEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasksTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.dateMillis == this.dateMillis &&
          other.deadlineMillis == this.deadlineMillis &&
          other.completedAtMillis == this.completedAtMillis &&
          other.durationMinutes == this.durationMinutes &&
          other.status == this.status &&
          other.repeatRule == this.repeatRule &&
          other.assignedList == this.assignedList &&
          other.startReminderEnabled == this.startReminderEnabled &&
          other.deadlineReminderEnabled == this.deadlineReminderEnabled);
}

class TasksTableCompanion extends UpdateCompanion<TasksTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int?> dateMillis;
  final Value<int?> deadlineMillis;
  final Value<int?> completedAtMillis;
  final Value<int> durationMinutes;
  final Value<int> status;
  final Value<int> repeatRule;
  final Value<int> assignedList;
  final Value<int> startReminderEnabled;
  final Value<int> deadlineReminderEnabled;
  final Value<int> rowid;
  const TasksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.dateMillis = const Value.absent(),
    this.deadlineMillis = const Value.absent(),
    this.completedAtMillis = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.assignedList = const Value.absent(),
    this.startReminderEnabled = const Value.absent(),
    this.deadlineReminderEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksTableCompanion.insert({
    required String id,
    required String title,
    this.dateMillis = const Value.absent(),
    this.deadlineMillis = const Value.absent(),
    this.completedAtMillis = const Value.absent(),
    required int durationMinutes,
    required int status,
    required int repeatRule,
    required int assignedList,
    this.startReminderEnabled = const Value.absent(),
    this.deadlineReminderEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        durationMinutes = Value(durationMinutes),
        status = Value(status),
        repeatRule = Value(repeatRule),
        assignedList = Value(assignedList);
  static Insertable<TasksTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? dateMillis,
    Expression<int>? deadlineMillis,
    Expression<int>? completedAtMillis,
    Expression<int>? durationMinutes,
    Expression<int>? status,
    Expression<int>? repeatRule,
    Expression<int>? assignedList,
    Expression<int>? startReminderEnabled,
    Expression<int>? deadlineReminderEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (dateMillis != null) 'date_millis': dateMillis,
      if (deadlineMillis != null) 'deadline_millis': deadlineMillis,
      if (completedAtMillis != null) 'completed_at_millis': completedAtMillis,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (status != null) 'status': status,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (assignedList != null) 'assigned_list': assignedList,
      if (startReminderEnabled != null)
        'start_reminder_enabled': startReminderEnabled,
      if (deadlineReminderEnabled != null)
        'deadline_reminder_enabled': deadlineReminderEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<int?>? dateMillis,
      Value<int?>? deadlineMillis,
      Value<int?>? completedAtMillis,
      Value<int>? durationMinutes,
      Value<int>? status,
      Value<int>? repeatRule,
      Value<int>? assignedList,
      Value<int>? startReminderEnabled,
      Value<int>? deadlineReminderEnabled,
      Value<int>? rowid}) {
    return TasksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      dateMillis: dateMillis ?? this.dateMillis,
      deadlineMillis: deadlineMillis ?? this.deadlineMillis,
      completedAtMillis: completedAtMillis ?? this.completedAtMillis,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      repeatRule: repeatRule ?? this.repeatRule,
      assignedList: assignedList ?? this.assignedList,
      startReminderEnabled: startReminderEnabled ?? this.startReminderEnabled,
      deadlineReminderEnabled:
          deadlineReminderEnabled ?? this.deadlineReminderEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dateMillis.present) {
      map['date_millis'] = Variable<int>(dateMillis.value);
    }
    if (deadlineMillis.present) {
      map['deadline_millis'] = Variable<int>(deadlineMillis.value);
    }
    if (completedAtMillis.present) {
      map['completed_at_millis'] = Variable<int>(completedAtMillis.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<int>(repeatRule.value);
    }
    if (assignedList.present) {
      map['assigned_list'] = Variable<int>(assignedList.value);
    }
    if (startReminderEnabled.present) {
      map['start_reminder_enabled'] = Variable<int>(startReminderEnabled.value);
    }
    if (deadlineReminderEnabled.present) {
      map['deadline_reminder_enabled'] =
          Variable<int>(deadlineReminderEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('dateMillis: $dateMillis, ')
          ..write('deadlineMillis: $deadlineMillis, ')
          ..write('completedAtMillis: $completedAtMillis, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('assignedList: $assignedList, ')
          ..write('startReminderEnabled: $startReminderEnabled, ')
          ..write('deadlineReminderEnabled: $deadlineReminderEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => 'settings');
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<int> notificationsEnabled = GeneratedColumn<int>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nightModeMeta =
      const VerificationMeta('nightMode');
  @override
  late final GeneratedColumn<int> nightMode = GeneratedColumn<int>(
      'night_mode', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _weekendModeMeta =
      const VerificationMeta('weekendMode');
  @override
  late final GeneratedColumn<int> weekendMode = GeneratedColumn<int>(
      'weekend_mode', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _defaultTaskDurationMinutesMeta =
      const VerificationMeta('defaultTaskDurationMinutes');
  @override
  late final GeneratedColumn<int> defaultTaskDurationMinutes =
      GeneratedColumn<int>('default_task_duration_minutes', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(30));
  static const VerificationMeta _reminderLeadMinutesMeta =
      const VerificationMeta('reminderLeadMinutes');
  @override
  late final GeneratedColumn<int> reminderLeadMinutes = GeneratedColumn<int>(
      'reminder_lead_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _workStartMinutesMeta =
      const VerificationMeta('workStartMinutes');
  @override
  late final GeneratedColumn<int> workStartMinutes = GeneratedColumn<int>(
      'work_start_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8 * 60));
  static const VerificationMeta _workEndMinutesMeta =
      const VerificationMeta('workEndMinutes');
  @override
  late final GeneratedColumn<int> workEndMinutes = GeneratedColumn<int>(
      'work_end_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(18 * 60));
  static const VerificationMeta _timeZoneMeta =
      const VerificationMeta('timeZone');
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
      'time_zone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        notificationsEnabled,
        nightMode,
        weekendMode,
        defaultTaskDurationMinutes,
        reminderLeadMinutes,
        workStartMinutes,
        workEndMinutes,
        timeZone
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('night_mode')) {
      context.handle(_nightModeMeta,
          nightMode.isAcceptableOrUnknown(data['night_mode']!, _nightModeMeta));
    }
    if (data.containsKey('weekend_mode')) {
      context.handle(
          _weekendModeMeta,
          weekendMode.isAcceptableOrUnknown(
              data['weekend_mode']!, _weekendModeMeta));
    }
    if (data.containsKey('default_task_duration_minutes')) {
      context.handle(
          _defaultTaskDurationMinutesMeta,
          defaultTaskDurationMinutes.isAcceptableOrUnknown(
              data['default_task_duration_minutes']!,
              _defaultTaskDurationMinutesMeta));
    }
    if (data.containsKey('reminder_lead_minutes')) {
      context.handle(
          _reminderLeadMinutesMeta,
          reminderLeadMinutes.isAcceptableOrUnknown(
              data['reminder_lead_minutes']!, _reminderLeadMinutesMeta));
    }
    if (data.containsKey('work_start_minutes')) {
      context.handle(
          _workStartMinutesMeta,
          workStartMinutes.isAcceptableOrUnknown(
              data['work_start_minutes']!, _workStartMinutesMeta));
    }
    if (data.containsKey('work_end_minutes')) {
      context.handle(
          _workEndMinutesMeta,
          workEndMinutes.isAcceptableOrUnknown(
              data['work_end_minutes']!, _workEndMinutesMeta));
    }
    if (data.containsKey('time_zone')) {
      context.handle(_timeZoneMeta,
          timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}notifications_enabled'])!,
      nightMode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}night_mode'])!,
      weekendMode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekend_mode'])!,
      defaultTaskDurationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}default_task_duration_minutes'])!,
      reminderLeadMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_lead_minutes'])!,
      workStartMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}work_start_minutes'])!,
      workEndMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}work_end_minutes'])!,
      timeZone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_zone'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String id;
  final int notificationsEnabled;
  final int nightMode;
  final int weekendMode;
  final int defaultTaskDurationMinutes;
  final int reminderLeadMinutes;
  final int workStartMinutes;
  final int workEndMinutes;
  final String timeZone;
  const SettingsTableData(
      {required this.id,
      required this.notificationsEnabled,
      required this.nightMode,
      required this.weekendMode,
      required this.defaultTaskDurationMinutes,
      required this.reminderLeadMinutes,
      required this.workStartMinutes,
      required this.workEndMinutes,
      required this.timeZone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['notifications_enabled'] = Variable<int>(notificationsEnabled);
    map['night_mode'] = Variable<int>(nightMode);
    map['weekend_mode'] = Variable<int>(weekendMode);
    map['default_task_duration_minutes'] =
        Variable<int>(defaultTaskDurationMinutes);
    map['reminder_lead_minutes'] = Variable<int>(reminderLeadMinutes);
    map['work_start_minutes'] = Variable<int>(workStartMinutes);
    map['work_end_minutes'] = Variable<int>(workEndMinutes);
    map['time_zone'] = Variable<String>(timeZone);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      notificationsEnabled: Value(notificationsEnabled),
      nightMode: Value(nightMode),
      weekendMode: Value(weekendMode),
      defaultTaskDurationMinutes: Value(defaultTaskDurationMinutes),
      reminderLeadMinutes: Value(reminderLeadMinutes),
      workStartMinutes: Value(workStartMinutes),
      workEndMinutes: Value(workEndMinutes),
      timeZone: Value(timeZone),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      notificationsEnabled:
          serializer.fromJson<int>(json['notificationsEnabled']),
      nightMode: serializer.fromJson<int>(json['nightMode']),
      weekendMode: serializer.fromJson<int>(json['weekendMode']),
      defaultTaskDurationMinutes:
          serializer.fromJson<int>(json['defaultTaskDurationMinutes']),
      reminderLeadMinutes:
          serializer.fromJson<int>(json['reminderLeadMinutes']),
      workStartMinutes: serializer.fromJson<int>(json['workStartMinutes']),
      workEndMinutes: serializer.fromJson<int>(json['workEndMinutes']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'notificationsEnabled': serializer.toJson<int>(notificationsEnabled),
      'nightMode': serializer.toJson<int>(nightMode),
      'weekendMode': serializer.toJson<int>(weekendMode),
      'defaultTaskDurationMinutes':
          serializer.toJson<int>(defaultTaskDurationMinutes),
      'reminderLeadMinutes': serializer.toJson<int>(reminderLeadMinutes),
      'workStartMinutes': serializer.toJson<int>(workStartMinutes),
      'workEndMinutes': serializer.toJson<int>(workEndMinutes),
      'timeZone': serializer.toJson<String>(timeZone),
    };
  }

  SettingsTableData copyWith(
          {String? id,
          int? notificationsEnabled,
          int? nightMode,
          int? weekendMode,
          int? defaultTaskDurationMinutes,
          int? reminderLeadMinutes,
          int? workStartMinutes,
          int? workEndMinutes,
          String? timeZone}) =>
      SettingsTableData(
        id: id ?? this.id,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        nightMode: nightMode ?? this.nightMode,
        weekendMode: weekendMode ?? this.weekendMode,
        defaultTaskDurationMinutes:
            defaultTaskDurationMinutes ?? this.defaultTaskDurationMinutes,
        reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
        workStartMinutes: workStartMinutes ?? this.workStartMinutes,
        workEndMinutes: workEndMinutes ?? this.workEndMinutes,
        timeZone: timeZone ?? this.timeZone,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      nightMode: data.nightMode.present ? data.nightMode.value : this.nightMode,
      weekendMode:
          data.weekendMode.present ? data.weekendMode.value : this.weekendMode,
      defaultTaskDurationMinutes: data.defaultTaskDurationMinutes.present
          ? data.defaultTaskDurationMinutes.value
          : this.defaultTaskDurationMinutes,
      reminderLeadMinutes: data.reminderLeadMinutes.present
          ? data.reminderLeadMinutes.value
          : this.reminderLeadMinutes,
      workStartMinutes: data.workStartMinutes.present
          ? data.workStartMinutes.value
          : this.workStartMinutes,
      workEndMinutes: data.workEndMinutes.present
          ? data.workEndMinutes.value
          : this.workEndMinutes,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('nightMode: $nightMode, ')
          ..write('weekendMode: $weekendMode, ')
          ..write('defaultTaskDurationMinutes: $defaultTaskDurationMinutes, ')
          ..write('reminderLeadMinutes: $reminderLeadMinutes, ')
          ..write('workStartMinutes: $workStartMinutes, ')
          ..write('workEndMinutes: $workEndMinutes, ')
          ..write('timeZone: $timeZone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      notificationsEnabled,
      nightMode,
      weekendMode,
      defaultTaskDurationMinutes,
      reminderLeadMinutes,
      workStartMinutes,
      workEndMinutes,
      timeZone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.nightMode == this.nightMode &&
          other.weekendMode == this.weekendMode &&
          other.defaultTaskDurationMinutes == this.defaultTaskDurationMinutes &&
          other.reminderLeadMinutes == this.reminderLeadMinutes &&
          other.workStartMinutes == this.workStartMinutes &&
          other.workEndMinutes == this.workEndMinutes &&
          other.timeZone == this.timeZone);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> id;
  final Value<int> notificationsEnabled;
  final Value<int> nightMode;
  final Value<int> weekendMode;
  final Value<int> defaultTaskDurationMinutes;
  final Value<int> reminderLeadMinutes;
  final Value<int> workStartMinutes;
  final Value<int> workEndMinutes;
  final Value<String> timeZone;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.nightMode = const Value.absent(),
    this.weekendMode = const Value.absent(),
    this.defaultTaskDurationMinutes = const Value.absent(),
    this.reminderLeadMinutes = const Value.absent(),
    this.workStartMinutes = const Value.absent(),
    this.workEndMinutes = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.nightMode = const Value.absent(),
    this.weekendMode = const Value.absent(),
    this.defaultTaskDurationMinutes = const Value.absent(),
    this.reminderLeadMinutes = const Value.absent(),
    this.workStartMinutes = const Value.absent(),
    this.workEndMinutes = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<SettingsTableData> custom({
    Expression<String>? id,
    Expression<int>? notificationsEnabled,
    Expression<int>? nightMode,
    Expression<int>? weekendMode,
    Expression<int>? defaultTaskDurationMinutes,
    Expression<int>? reminderLeadMinutes,
    Expression<int>? workStartMinutes,
    Expression<int>? workEndMinutes,
    Expression<String>? timeZone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (nightMode != null) 'night_mode': nightMode,
      if (weekendMode != null) 'weekend_mode': weekendMode,
      if (defaultTaskDurationMinutes != null)
        'default_task_duration_minutes': defaultTaskDurationMinutes,
      if (reminderLeadMinutes != null)
        'reminder_lead_minutes': reminderLeadMinutes,
      if (workStartMinutes != null) 'work_start_minutes': workStartMinutes,
      if (workEndMinutes != null) 'work_end_minutes': workEndMinutes,
      if (timeZone != null) 'time_zone': timeZone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? notificationsEnabled,
      Value<int>? nightMode,
      Value<int>? weekendMode,
      Value<int>? defaultTaskDurationMinutes,
      Value<int>? reminderLeadMinutes,
      Value<int>? workStartMinutes,
      Value<int>? workEndMinutes,
      Value<String>? timeZone,
      Value<int>? rowid}) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      nightMode: nightMode ?? this.nightMode,
      weekendMode: weekendMode ?? this.weekendMode,
      defaultTaskDurationMinutes:
          defaultTaskDurationMinutes ?? this.defaultTaskDurationMinutes,
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      workStartMinutes: workStartMinutes ?? this.workStartMinutes,
      workEndMinutes: workEndMinutes ?? this.workEndMinutes,
      timeZone: timeZone ?? this.timeZone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<int>(notificationsEnabled.value);
    }
    if (nightMode.present) {
      map['night_mode'] = Variable<int>(nightMode.value);
    }
    if (weekendMode.present) {
      map['weekend_mode'] = Variable<int>(weekendMode.value);
    }
    if (defaultTaskDurationMinutes.present) {
      map['default_task_duration_minutes'] =
          Variable<int>(defaultTaskDurationMinutes.value);
    }
    if (reminderLeadMinutes.present) {
      map['reminder_lead_minutes'] = Variable<int>(reminderLeadMinutes.value);
    }
    if (workStartMinutes.present) {
      map['work_start_minutes'] = Variable<int>(workStartMinutes.value);
    }
    if (workEndMinutes.present) {
      map['work_end_minutes'] = Variable<int>(workEndMinutes.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('nightMode: $nightMode, ')
          ..write('weekendMode: $weekendMode, ')
          ..write('defaultTaskDurationMinutes: $defaultTaskDurationMinutes, ')
          ..write('reminderLeadMinutes: $reminderLeadMinutes, ')
          ..write('workStartMinutes: $workStartMinutes, ')
          ..write('workEndMinutes: $workEndMinutes, ')
          ..write('timeZone: $timeZone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tasksTable, settingsTable];
}

typedef $$TasksTableTableCreateCompanionBuilder = TasksTableCompanion Function({
  required String id,
  required String title,
  Value<int?> dateMillis,
  Value<int?> deadlineMillis,
  Value<int?> completedAtMillis,
  required int durationMinutes,
  required int status,
  required int repeatRule,
  required int assignedList,
  Value<int> startReminderEnabled,
  Value<int> deadlineReminderEnabled,
  Value<int> rowid,
});
typedef $$TasksTableTableUpdateCompanionBuilder = TasksTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<int?> dateMillis,
  Value<int?> deadlineMillis,
  Value<int?> completedAtMillis,
  Value<int> durationMinutes,
  Value<int> status,
  Value<int> repeatRule,
  Value<int> assignedList,
  Value<int> startReminderEnabled,
  Value<int> deadlineReminderEnabled,
  Value<int> rowid,
});

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDb, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dateMillis => $composableBuilder(
      column: $table.dateMillis, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deadlineMillis => $composableBuilder(
      column: $table.deadlineMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAtMillis => $composableBuilder(
      column: $table.completedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repeatRule => $composableBuilder(
      column: $table.repeatRule, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get assignedList => $composableBuilder(
      column: $table.assignedList, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startReminderEnabled => $composableBuilder(
      column: $table.startReminderEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deadlineReminderEnabled => $composableBuilder(
      column: $table.deadlineReminderEnabled,
      builder: (column) => ColumnFilters(column));
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDb, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dateMillis => $composableBuilder(
      column: $table.dateMillis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deadlineMillis => $composableBuilder(
      column: $table.deadlineMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAtMillis => $composableBuilder(
      column: $table.completedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repeatRule => $composableBuilder(
      column: $table.repeatRule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get assignedList => $composableBuilder(
      column: $table.assignedList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startReminderEnabled => $composableBuilder(
      column: $table.startReminderEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deadlineReminderEnabled => $composableBuilder(
      column: $table.deadlineReminderEnabled,
      builder: (column) => ColumnOrderings(column));
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDb, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get dateMillis => $composableBuilder(
      column: $table.dateMillis, builder: (column) => column);

  GeneratedColumn<int> get deadlineMillis => $composableBuilder(
      column: $table.deadlineMillis, builder: (column) => column);

  GeneratedColumn<int> get completedAtMillis => $composableBuilder(
      column: $table.completedAtMillis, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get repeatRule => $composableBuilder(
      column: $table.repeatRule, builder: (column) => column);

  GeneratedColumn<int> get assignedList => $composableBuilder(
      column: $table.assignedList, builder: (column) => column);

  GeneratedColumn<int> get startReminderEnabled => $composableBuilder(
      column: $table.startReminderEnabled, builder: (column) => column);

  GeneratedColumn<int> get deadlineReminderEnabled => $composableBuilder(
      column: $table.deadlineReminderEnabled, builder: (column) => column);
}

class $$TasksTableTableTableManager extends RootTableManager<
    _$AppDb,
    $TasksTableTable,
    TasksTableData,
    $$TasksTableTableFilterComposer,
    $$TasksTableTableOrderingComposer,
    $$TasksTableTableAnnotationComposer,
    $$TasksTableTableCreateCompanionBuilder,
    $$TasksTableTableUpdateCompanionBuilder,
    (TasksTableData, BaseReferences<_$AppDb, $TasksTableTable, TasksTableData>),
    TasksTableData,
    PrefetchHooks Function()> {
  $$TasksTableTableTableManager(_$AppDb db, $TasksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int?> dateMillis = const Value.absent(),
            Value<int?> deadlineMillis = const Value.absent(),
            Value<int?> completedAtMillis = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<int> repeatRule = const Value.absent(),
            Value<int> assignedList = const Value.absent(),
            Value<int> startReminderEnabled = const Value.absent(),
            Value<int> deadlineReminderEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksTableCompanion(
            id: id,
            title: title,
            dateMillis: dateMillis,
            deadlineMillis: deadlineMillis,
            completedAtMillis: completedAtMillis,
            durationMinutes: durationMinutes,
            status: status,
            repeatRule: repeatRule,
            assignedList: assignedList,
            startReminderEnabled: startReminderEnabled,
            deadlineReminderEnabled: deadlineReminderEnabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<int?> dateMillis = const Value.absent(),
            Value<int?> deadlineMillis = const Value.absent(),
            Value<int?> completedAtMillis = const Value.absent(),
            required int durationMinutes,
            required int status,
            required int repeatRule,
            required int assignedList,
            Value<int> startReminderEnabled = const Value.absent(),
            Value<int> deadlineReminderEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksTableCompanion.insert(
            id: id,
            title: title,
            dateMillis: dateMillis,
            deadlineMillis: deadlineMillis,
            completedAtMillis: completedAtMillis,
            durationMinutes: durationMinutes,
            status: status,
            repeatRule: repeatRule,
            assignedList: assignedList,
            startReminderEnabled: startReminderEnabled,
            deadlineReminderEnabled: deadlineReminderEnabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $TasksTableTable,
    TasksTableData,
    $$TasksTableTableFilterComposer,
    $$TasksTableTableOrderingComposer,
    $$TasksTableTableAnnotationComposer,
    $$TasksTableTableCreateCompanionBuilder,
    $$TasksTableTableUpdateCompanionBuilder,
    (TasksTableData, BaseReferences<_$AppDb, $TasksTableTable, TasksTableData>),
    TasksTableData,
    PrefetchHooks Function()>;
typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<String> id,
  Value<int> notificationsEnabled,
  Value<int> nightMode,
  Value<int> weekendMode,
  Value<int> defaultTaskDurationMinutes,
  Value<int> reminderLeadMinutes,
  Value<int> workStartMinutes,
  Value<int> workEndMinutes,
  Value<String> timeZone,
  Value<int> rowid,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<String> id,
  Value<int> notificationsEnabled,
  Value<int> nightMode,
  Value<int> weekendMode,
  Value<int> defaultTaskDurationMinutes,
  Value<int> reminderLeadMinutes,
  Value<int> workStartMinutes,
  Value<int> workEndMinutes,
  Value<String> timeZone,
  Value<int> rowid,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDb, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nightMode => $composableBuilder(
      column: $table.nightMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekendMode => $composableBuilder(
      column: $table.weekendMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultTaskDurationMinutes => $composableBuilder(
      column: $table.defaultTaskDurationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderLeadMinutes => $composableBuilder(
      column: $table.reminderLeadMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workStartMinutes => $composableBuilder(
      column: $table.workStartMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workEndMinutes => $composableBuilder(
      column: $table.workEndMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeZone => $composableBuilder(
      column: $table.timeZone, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDb, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nightMode => $composableBuilder(
      column: $table.nightMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekendMode => $composableBuilder(
      column: $table.weekendMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultTaskDurationMinutes => $composableBuilder(
      column: $table.defaultTaskDurationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderLeadMinutes => $composableBuilder(
      column: $table.reminderLeadMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workStartMinutes => $composableBuilder(
      column: $table.workStartMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workEndMinutes => $composableBuilder(
      column: $table.workEndMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeZone => $composableBuilder(
      column: $table.timeZone, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDb, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<int> get nightMode =>
      $composableBuilder(column: $table.nightMode, builder: (column) => column);

  GeneratedColumn<int> get weekendMode => $composableBuilder(
      column: $table.weekendMode, builder: (column) => column);

  GeneratedColumn<int> get defaultTaskDurationMinutes => $composableBuilder(
      column: $table.defaultTaskDurationMinutes, builder: (column) => column);

  GeneratedColumn<int> get reminderLeadMinutes => $composableBuilder(
      column: $table.reminderLeadMinutes, builder: (column) => column);

  GeneratedColumn<int> get workStartMinutes => $composableBuilder(
      column: $table.workStartMinutes, builder: (column) => column);

  GeneratedColumn<int> get workEndMinutes => $composableBuilder(
      column: $table.workEndMinutes, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDb,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDb, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDb db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> notificationsEnabled = const Value.absent(),
            Value<int> nightMode = const Value.absent(),
            Value<int> weekendMode = const Value.absent(),
            Value<int> defaultTaskDurationMinutes = const Value.absent(),
            Value<int> reminderLeadMinutes = const Value.absent(),
            Value<int> workStartMinutes = const Value.absent(),
            Value<int> workEndMinutes = const Value.absent(),
            Value<String> timeZone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            id: id,
            notificationsEnabled: notificationsEnabled,
            nightMode: nightMode,
            weekendMode: weekendMode,
            defaultTaskDurationMinutes: defaultTaskDurationMinutes,
            reminderLeadMinutes: reminderLeadMinutes,
            workStartMinutes: workStartMinutes,
            workEndMinutes: workEndMinutes,
            timeZone: timeZone,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> notificationsEnabled = const Value.absent(),
            Value<int> nightMode = const Value.absent(),
            Value<int> weekendMode = const Value.absent(),
            Value<int> defaultTaskDurationMinutes = const Value.absent(),
            Value<int> reminderLeadMinutes = const Value.absent(),
            Value<int> workStartMinutes = const Value.absent(),
            Value<int> workEndMinutes = const Value.absent(),
            Value<String> timeZone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            id: id,
            notificationsEnabled: notificationsEnabled,
            nightMode: nightMode,
            weekendMode: weekendMode,
            defaultTaskDurationMinutes: defaultTaskDurationMinutes,
            reminderLeadMinutes: reminderLeadMinutes,
            workStartMinutes: workStartMinutes,
            workEndMinutes: workEndMinutes,
            timeZone: timeZone,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDb, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
