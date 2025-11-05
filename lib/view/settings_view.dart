// Imports/Packages
import 'package:flutter/material.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/viewmodel/settings_view_model.dart';
import 'package:adhd_todo/model/entities.dart' as ent;
import 'package:duration_picker/duration_picker.dart';

/// Settings screen widget
class SettingsScreen extends StatefulWidget {
  final AppModel appModel;
  const SettingsScreen({super.key, required this.appModel});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// Settings screen state
class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  late final SettingsViewModel vm;

  /// Local edit buffer
  late bool _notificationsEnabled;
  late Duration _defaultTaskDuration;
  late Duration _reminderLeadTime;

  /// Device notification permission state
  bool _deviceNotificationsAllowed = false;

  /// Work window in minutes from midnight
  late int _workStartMinutes;
  late int _workEndMinutes;

  /// Tracks pending exact alarm request
  bool _pendingExactAlarmRequest = false;

  /// Initialize state and seed values
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    vm = SettingsViewModel(widget.appModel);
    final ent.UserSettings cur = vm.current;
    _notificationsEnabled = cur.notificationsEnabled;
    _defaultTaskDuration = cur.defaultTaskDuration;
    _reminderLeadTime = cur.reminderLeadTime;
    _workStartMinutes = cur.workStartMinutes;
    _workEndMinutes = cur.workEndMinutes;

    _hydrateNotificationsPermission();
  }

  /// Remove observer
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle lifecycle to refresh permissions
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _hydrateNotificationsPermission();

      if (_pendingExactAlarmRequest) {
        _pendingExactAlarmRequest = false;
        final enabled = await vm.areExactAlarmsEnabledOnDevice();
        if (!mounted) return;
        setState(() {});
        if (enabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exact alarms are enabled')),
          );
        }
      } else {
        if (mounted) setState(() {});
      }
    }
  }

  /// Refresh device notifications permission
  Future<void> _hydrateNotificationsPermission() async {
    final notif = await vm.areNotificationsEnabledOnDevice();
    if (!mounted) return;
    setState(() {
      _deviceNotificationsAllowed = notif;
    });
  }

  /// Two-digit helper
  String _two(int n) => n.toString().padLeft(2, '0');

  /// Format minutes as HH:mm
  String _formatHm(int minutes) {
    final h = (minutes ~/ 60).clamp(0, 23);
    final m = (minutes % 60).clamp(0, 59);
    return '${_two(h)}:${_two(m)}';
  }

  /// Convert minutes to TimeOfDay
  TimeOfDay _hmToTimeOfDay(int minutes) =>
      TimeOfDay(hour: (minutes ~/ 60).clamp(0, 23), minute: (minutes % 60).clamp(0, 59));

  /// Pick work start time
  Future<void> _pickWorkStart() async {
    final initial = _hmToTimeOfDay(_workStartMinutes);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _workStartMinutes = picked.hour * 60 + picked.minute);
    }
  }

  /// Pick work end time
  Future<void> _pickWorkEnd() async {
    final initial = _hmToTimeOfDay(_workEndMinutes);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _workEndMinutes = picked.hour * 60 + picked.minute);
    }
  }

  /// Save settings to view model
  Future<void> _save() async {
    if (_workEndMinutes <= _workStartMinutes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work end must be after work start')),
      );
      return;
    }

    await vm.save(
      notificationsEnabled: _notificationsEnabled,
      defaultTaskDuration: _defaultTaskDuration,
      reminderLeadTime: _reminderLeadTime,
      workStartMinutes: _workStartMinutes,
      workEndMinutes: _workEndMinutes,
    );
    if (mounted) Navigator.of(context).pop();
  }

  /// Handle notifications toggle
  Future<void> _handleNotificationsToggle(bool v) async {
    if (v) {
      if (!_deviceNotificationsAllowed) {
        final granted = await vm.requestEnableNotificationsOnDevice();
        if (!mounted) return;
        if (!granted) {
          setState(() {
            _deviceNotificationsAllowed = false;
            _notificationsEnabled = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifications are blocked by the phone. Enable them in system settings.',
              ),
            ),
          );
          return;
        }
        setState(() => _deviceNotificationsAllowed = true);
      }
      setState(() => _notificationsEnabled = true);
    } else {
      setState(() => _notificationsEnabled = false);
    }
  }

  /// Build settings UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveToggleOn = _notificationsEnabled && _deviceNotificationsAllowed;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Notifications toggle
          SwitchListTile(
            title: const Text('Enable notifications'),
            subtitle: !_deviceNotificationsAllowed
                ? Text(
                    'Notifications are blocked by the phone',
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                : null,
            value: effectiveToggleOn,
            onChanged: _handleNotificationsToggle,
          ),

          /// Exact alarms row
          FutureBuilder<bool>(
            future: vm.areExactAlarmsEnabledOnDevice(),
            builder: (context, snap) {
              return ListTile(
                leading: const Icon(Icons.alarm_on),
                title: const Text('Allow exact alarms'),
                subtitle: const Text('Enable on time reminders while the phone is asleep'),
                onTap: () async {
                  await vm.requestExactAlarmsOnDevice();
                },
              );
            },
          ),

          const Divider(height: 24),

          /// Default task duration
          ListTile(
            title: const Text('Default task duration'),
            subtitle: Text('${_defaultTaskDuration.inMinutes} minutes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDurationPicker(
                context: context,
                initialTime: _defaultTaskDuration,
                baseUnit: BaseUnit.minute,
                lowerBound: const Duration(minutes: 1),
                upperBound: const Duration(minutes: 60),
              );
              if (!mounted) return;
              if (picked != null) {
                setState(() => _defaultTaskDuration = picked);
              }
            },
          ),

          /// Reminder lead time
          ListTile(
            title: const Text('Reminder lead time'),
            subtitle: Text('${_reminderLeadTime.inMinutes} minutes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDurationPicker(
                context: context,
                initialTime: _reminderLeadTime,
                baseUnit: BaseUnit.minute,
                lowerBound: const Duration(minutes: 1),
                upperBound: const Duration(minutes: 60),
              );
              if (!mounted) return;
              if (picked != null) {
                setState(() => _reminderLeadTime = picked);
              }
            },
          ),

          const Divider(height: 24),

          /// Work start time
          ListTile(
            title: const Text('Schedule Start'),
            subtitle: Text(_formatHm(_workStartMinutes)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickWorkStart,
          ),

          /// Work end time
          ListTile(
            title: const Text('Schedule End'),
            subtitle: Text(_formatHm(_workEndMinutes)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickWorkEnd,
          ),

          const SizedBox(height: 12),

          /// Save button
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ent.AppColors.primary(context),
              foregroundColor: ent.AppColors.onPrimary(context),
            ),
            onPressed: _save,
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
