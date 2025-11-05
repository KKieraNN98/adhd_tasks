// Imports/Packages
import 'package:flutter/foundation.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/model/entities.dart';

class SettingsViewModel extends ChangeNotifier {
  final AppModel _app;

  SettingsViewModel(this._app);

  // Get current settings
  UserSettings get current => _app.settings;

  // Check if device allows notifications
  Future<bool> areNotificationsEnabledOnDevice() async {
    return await _app.notifier?.areNotificationsEnabled() ?? false;
  }

  // Request notification permission
  Future<bool> requestEnableNotificationsOnDevice() async {
    return await _app.notifier?.requestEnableNotifications() ?? false;
  }

  // Check if exact alarms are allowed
  Future<bool> areExactAlarmsEnabledOnDevice() async {
    return await _app.notifier?.areExactAlarmsEnabled() ?? false;
  }

  // Request exact alarm permission
  Future<bool> requestExactAlarmsOnDevice() async {
    return await _app.notifier?.requestExactAlarmsPermission() ?? false;
  }

  // Show a test notification now
  Future<void> showTestNotification() async {
    await _app.notifier?.showTestNow();
  }

  // Save settings
  Future<void> save({
    bool? notificationsEnabled,
    Duration? defaultTaskDuration,
    String? timeZone,
    Duration? reminderLeadTime,
    int? workStartMinutes,
    int? workEndMinutes,
  }) async {
    final next = _app.settings.copyWith(
      notificationsEnabled: notificationsEnabled,
      defaultTaskDuration: defaultTaskDuration,
      timeZone: timeZone,
      reminderLeadTime: reminderLeadTime,
      workStartMinutes: workStartMinutes,
      workEndMinutes: workEndMinutes,
    );
    await _app.saveSettings(next);
    notifyListeners();
  }
}
