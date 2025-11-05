// Imports/Packages
import 'package:adhd_todo/model/entities.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart' show debugPrint;

abstract class NotificationGateway {
  // Schedule reminders for a task
  Future<void> scheduleReminders(
    Task task,
    List<ScheduleSlot> slots,
    UserSettings settings,
  );

  // Reschedule reminders for a task
  Future<void> rescheduleReminders(
    Task task,
    List<ScheduleSlot> slots,
    UserSettings settings,
  );

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  // Request to enable notifications
  Future<bool> requestEnableNotifications();

  // Check exact alarm capability
  Future<bool> areExactAlarmsEnabled();

  // Request exact alarm permission
  Future<bool> requestExactAlarmsPermission();

  // Show a test notification now
  Future<void> showTestNow();
}

class LocalNotificationGateway implements NotificationGateway {
  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _tzInitialized = false;

  static final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'task_reminders',
    'Task Reminders',
    description: 'Start and deadline reminders for tasks',
    importance: Importance.high,
  );

  static const Duration _graceWindow = Duration(minutes: 2);

  // Initialize notification plugin and permissions
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // Build initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize plugin
    await _fln.initialize(initSettings);

    // Create Android channel
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize timezone
    await _ensureTzInitialized();

    // Request runtime permissions
    await _requestPostPermissionIfNeeded();

    _initialized = true;
  }

  // Initialize timezone data and local location
  Future<void> _ensureTzInitialized() async {
    if (_tzInitialized) return;
    tz.initializeTimeZones();
    try {
      final dynamic info = await FlutterTimezone.getLocalTimezone();

      String tzName;
      if (info is String) {
        tzName = info;
      } else {
        final dyn = info as dynamic;
        tzName = dyn.name ??
            dyn.timezone ??
            dyn.timeZone ??
            dyn.timeZoneId ??
            'Etc/UTC';
      }

      final loc = tz.getLocation(tzName);
      tz.setLocalLocation(loc);
    } catch (_) {
    }
    _tzInitialized = true;
  }

  // Convert DateTime to TZDateTime
  tz.TZDateTime _toTz(DateTime dt) => tz.TZDateTime.from(dt, tz.local);

  // Request platform notification permissions if needed
  Future<void> _requestPostPermissionIfNeeded() async {
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _fln
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Check platform notification enabled status
  Future<bool> _platformNotificationsEnabled() async {
    final android = _fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.areNotificationsEnabled();
    return granted ?? false;
  }

  // Check if notifications are enabled
  @override
  Future<bool> areNotificationsEnabled() async {
    await _ensureInitialized();
    return _platformNotificationsEnabled();
  }

  // Request to enable notifications
  @override
  Future<bool> requestEnableNotifications() async {
    await _ensureInitialized();

    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _fln
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return _platformNotificationsEnabled();
  }

  // Check exact alarm capability
  @override
  Future<bool> areExactAlarmsEnabled() async {
    await _ensureInitialized();
    try {
      final android = _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;

      final dyn = android as dynamic;

      Future<bool>? callCanSchedule() {
        try {
          final r = dyn.canScheduleExactNotifications?.call();
          if (r is Future<bool>) return r;
        } catch (_) {}
        try {
          final r = dyn.canScheduleExactAlarms?.call();
          if (r is Future<bool>) return r;
        } catch (_) {}
        try {
          final r = dyn.areExactAlarmsEnabled?.call();
          if (r is Future<bool>) return r;
        } catch (_) {}
        return null;
      }

      final fut = callCanSchedule();
      if (fut != null) return await fut;
      return false;
    } catch (_) {
      return false;
    }
  }

  // Request exact alarm permission
  @override
  Future<bool> requestExactAlarmsPermission() async {
    await _ensureInitialized();
    try {
      final android = _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;
      final dyn = android as dynamic;

      try {
        await (dyn.requestExactAlarmsPermission?.call());
      } catch (_) {
      }

      return await areExactAlarmsEnabled();
    } catch (_) {
      return false;
    }
  }

  // Show a test notification immediately
  @override
  Future<void> showTestNow() async {
    await _ensureInitialized();
    // Check permission
    final allowed = await _platformNotificationsEnabled();
    if (!allowed) return;

    // Show notification
    await _fln.show(
      999100,
      'Notifications are on',
      'This is a test notification from Settings.',
      _details(),
      payload: 'test-notification',
    );
  }

  // Schedule reminders for start and deadline
  @override
  Future<void> scheduleReminders(
    Task task,
    List<ScheduleSlot> slots,
    UserSettings settings,
  ) async {
    await _ensureInitialized();
    debugPrint(
        '[REM] schedule  task=${task.id} title="${task.title}" date=${task.date} deadline=${task.deadline} lead=${settings.reminderLeadTime.inMinutes}m');

    // Check eligibility and cancel if not eligible
    if (!_shouldSchedule(task, settings)) {
      debugPrint('[REM] skip scheduling: shouldSchedule=false');
      await _fln.cancel(_startId(task.id));
      await _fln.cancel(_deadlineId(task.id));
      return;
    }

    // Check platform permission
    final allowed = await _platformNotificationsEnabled();
    debugPrint('[REM] areNotificationsEnabled=$allowed');
    if (!allowed) return;

    // Check exact alarm capability
    try {
      final exact = await areExactAlarmsEnabled();
      debugPrint('[REM] areExactAlarmsEnabled=$exact');
      if (!exact) {
        debugPrint('[REM] requesting exact-alarms permission…');
        await requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('[REM] exact-alarms check failed: $e');
    }

    // Compute triggers
    final lead = settings.reminderLeadTime;

    final DateTime? startTrigger =
        (task.remindOnStart && task.date != null) ? task.date!.subtract(lead) : null;
    final DateTime? deadlineTrigger =
        (task.remindOnDeadline && task.deadline != null) ? task.deadline!.subtract(lead) : null;

    // Schedule or cancel start reminder
    if (startTrigger != null) {
      await _rescheduleOne(
        id: _startId(task.id),
        title: 'Starting Soon: ${task.title}',
        body: 'Start Time: ${_formatClock(task.date!)}',
        triggerLocal: startTrigger,
        payload: task.id,
      );
    } else {
      await _fln.cancel(_startId(task.id));
    }

    // Schedule or cancel deadline reminder
    if (deadlineTrigger != null) {
      await _rescheduleOne(
        id: _deadlineId(task.id),
        title: 'Due Soon: ${task.title}',
        body: 'Deadline: ${_formatClock(task.deadline!)}',
        triggerLocal: deadlineTrigger,
        payload: task.id,
      );
    } else {
      await _fln.cancel(_deadlineId(task.id));
    }

    // Dump pending for debugging
    await debugDumpPending();
  }

  // Reschedule reminders for start and deadline
  @override
  Future<void> rescheduleReminders(
    Task task,
    List<ScheduleSlot> slots,
    UserSettings settings,
  ) async {
    await _ensureInitialized();
    debugPrint(
        '[REM] reschedule task=${task.id} title="${task.title}" date=${task.date} deadline=${task.deadline} lead=${settings.reminderLeadTime.inMinutes}m');

    // Check eligibility and cancel if not eligible
    if (!_shouldSchedule(task, settings)) {
      debugPrint('[REM] skip reschedule: shouldSchedule=false');
      await _fln.cancel(_startId(task.id));
      await _fln.cancel(_deadlineId(task.id));
      return;
    }

    // Check platform permission
    final allowed = await _platformNotificationsEnabled();
    debugPrint('[REM] areNotificationsEnabled=$allowed');
    if (!allowed) return;

    // Check exact alarm capability
    try {
      final exact = await areExactAlarmsEnabled();
      debugPrint('[REM] areExactAlarmsEnabled=$exact');
      if (!exact) {
        debugPrint('[REM] requesting exact-alarms permission…');
        await requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('[REM] exact-alarms check failed: $e');
    }

    // Compute triggers
    final lead = settings.reminderLeadTime;

    final DateTime? startTrigger =
        (task.remindOnStart && task.date != null) ? task.date!.subtract(lead) : null;
    final DateTime? deadlineTrigger =
        (task.remindOnDeadline && task.deadline != null) ? task.deadline!.subtract(lead) : null;

    // Dump pending before
    debugPrint('[PENDING] before reschedule dump:');
    await debugDumpPending();

    // Schedule or cancel start reminder
    if (startTrigger != null) {
      await _rescheduleOne(
        id: _startId(task.id),
        title: 'Starting Soon: ${task.title}',
        body: 'Start Time: ${_formatClock(task.date!)}',
        triggerLocal: startTrigger,
        payload: task.id,
      );
    } else {
      debugPrint('[REM] cancel start id=${_startId(task.id)} (toggle off or no start date)');
      await _fln.cancel(_startId(task.id));
    }

    // Schedule or cancel deadline reminder
    if (deadlineTrigger != null) {
      await _rescheduleOne(
        id: _deadlineId(task.id),
        title: 'Due Soon: ${task.title}',
        body: 'Deadline: ${_formatClock(task.deadline!)}',
        triggerLocal: deadlineTrigger,
        payload: task.id,
      );
    } else {
      debugPrint('[REM] cancel deadline id=${_deadlineId(task.id)} (toggle off or no deadline)');
      await _fln.cancel(_deadlineId(task.id));
    }

    // Dump pending after
    debugPrint('[PENDING] after reschedule dump:');
    await debugDumpPending();
  }

  // Decide if a task should schedule reminders
  bool _shouldSchedule(Task task, UserSettings settings) {
    if (!settings.notificationsEnabled) {
      debugPrint('[REM] shouldSchedule=false (app setting disabled)');
      return false;
    }
    if (task.status != TaskStatus.active) {
      debugPrint('[REM] shouldSchedule=false (task not active)');
      return false;
    }
    final eligibleStart = task.remindOnStart && task.date != null;
    final eligibleDeadline = task.remindOnDeadline && task.deadline != null;
    if (!eligibleStart && !eligibleDeadline) {
      debugPrint('[REM] shouldSchedule=false (no eligible start/deadline reminder)');
      return false;
    }
    return true;
  }

  // Reschedule a single reminder with grace handling
  Future<void> _rescheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime triggerLocal,
    required String payload,
  }) async {
    final now = DateTime.now();

    // Handle past triggers
    if (triggerLocal.isBefore(now)) {
      final age = now.difference(triggerLocal);
      if (age <= _graceWindow) {
        debugPrint('[REM] past within grace -> fire now then cancel  '
            'id=$id "$title" trigger=$triggerLocal now=$now');
        await _fln.show(id, title, body, _details(), payload: payload);
        await _fln.cancel(id);
        return;
      } else {
        debugPrint('[REM] past beyond grace -> cancel only  '
            'id=$id "$title" trigger=$triggerLocal now=$now');
        await _fln.cancel(id);
        return;
      }
    }

    // Schedule future trigger
    debugPrint('[REM] future -> schedule id=$id at $triggerLocal "$title"');
    await _scheduleZoned(
      id: id,
      title: title,
      body: body,
      when: triggerLocal,
      payload: payload,
    );
  }

  // Format a time as HH:mm
  String _formatClock(DateTime when) {
    final local = when;
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(local.hour);
    final m = two(local.minute);
    return '$h:$m';
  }

  // Schedule a zoned notification with fallbacks
  Future<void> _scheduleZoned({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required String payload,
  }) async {
    final tzWhen = _toTz(when);

    // Try alarmClock mode
    try {
      debugPrint('[NOTIFY] scheduling id=$id when=$tzWhen mode=alarmClock');
      debugPrint('[TZ] device=${await FlutterTimezone.getLocalTimezone()}');
      debugPrint('[TZ] tz.local=${tz.local}');
      debugPrint(
          '[TZ] nowLocal=${DateTime.now()} nowTz=${tz.TZDateTime.now(tz.local)}');

      await _fln.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        _details(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[NOTIFY] scheduled OK id=$id mode=alarmClock');
      return;
    } on PlatformException catch (e) {
      debugPrint(
          '[NOTIFY] alarmClock failed id=$id -> $e; trying exactAllowWhileIdle');
    } catch (e) {
      debugPrint(
          '[NOTIFY] alarmClock unexpected error id=$id -> $e; trying exactAllowWhileIdle');
    }

    // Try exactAllowWhileIdle mode
    try {
      debugPrint(
          '[NOTIFY] scheduling id=$id when=$tzWhen mode=exactAllowWhileIdle');
      await _fln.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[NOTIFY] scheduled OK id=$id mode=exactAllowWhileIdle');
      return;
    } on PlatformException catch (e) {
      debugPrint(
          '[NOTIFY] exactAllowWhileIdle failed id=$id -> $e; falling back to inexact');
    } catch (e) {
      debugPrint(
          '[NOTIFY] exactAllowWhileIdle unexpected error id=$id -> $e; falling back to inexact');
    }

    // Fallback to inexact mode
    debugPrint('[NOTIFY] scheduling id=$id when=$tzWhen mode=inexact');
    await _fln.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
    debugPrint('[NOTIFY] scheduled OK id=$id mode=inexact');
  }

  // Build notification details
  NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        enableVibration: true,
        playSound: true,
        ongoing: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Log pending notifications
  Future<void> debugDumpPending() async {
    try {
      final list = await _fln.pendingNotificationRequests();
      debugPrint('[PENDING] count=${list.length}');
      for (final r in list) {
        debugPrint('  id=${r.id} title=${r.title} payload=${r.payload}');
      }
    } catch (e) {
      debugPrint('[PENDING] failed to fetch: $e');
    }
  }

  // Build a base numeric id from task id
  int _idFrom(String taskId) => taskId.hashCode & 0x7fffffff;

  // Build start reminder id
  int _startId(String taskId) => _idFrom(taskId);

  // Build deadline reminder id
  int _deadlineId(String taskId) =>
      (_idFrom(taskId) ^ 0x5a5a5a5a) & 0x7fffffff;
}
