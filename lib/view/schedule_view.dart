// Imports/Packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/model/entities.dart';
import 'package:adhd_todo/viewmodel/schedule_view_model.dart';

class ScheduleBody extends StatefulWidget {
  final AppModel appModel;
  const ScheduleBody({super.key, required this.appModel});

  @override
  State<ScheduleBody> createState() => ScheduleBodyState();
}

class ScheduleBodyState extends State<ScheduleBody> {
  late final ScheduleViewModel vm;

  static const _labels = ['Day', 'Week', 'Month'];
  int _selected = 0;

  static const double _pxPerMinute = 2.0;
  static const double _gutterWidth = 64.0;
  static const double _hPadding = 12.0;

  final GlobalKey _dayDropKey = GlobalKey();

  final ScrollController _dayScrollCtrl = ScrollController();
  final ScrollController _listScrollCtrl = ScrollController();

  // Initialize view model and window
  @override
  void initState() {
    super.initState();
    vm = ScheduleViewModel(widget.appModel);
    vm.setWindow(_windowFor(_selected));
  }

  // Dispose controllers
  @override
  void dispose() {
    _dayScrollCtrl.dispose();
    _listScrollCtrl.dispose();
    super.dispose();
  }

  // Reload slots
  Future<void> reload() => vm.reload();

  // Compute time window for a segment
  TimeWindow _windowFor(int idx) {
    final now = DateTime.now();
    final settings = widget.appModel.settings;

    switch (idx) {
      case 0:
        final base = DateTime(now.year, now.month, now.day);
        final start = base.add(Duration(minutes: settings.workStartMinutes));
        final end = base.add(Duration(minutes: settings.workEndMinutes));
        return TimeWindow(startDate: start, duration: end.difference(start));

      case 1:
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: (now.weekday - DateTime.monday)));
        return TimeWindow(
            startDate: startOfWeek, duration: const Duration(days: 7));

      case 2:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final nextMonth = (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
        return TimeWindow(
          startDate: startOfMonth,
          duration: nextMonth.difference(startOfMonth),
        );

      default:
        final base = DateTime(now.year, now.month, now.day);
        final start = base.add(Duration(minutes: settings.workStartMinutes));
        final end = base.add(Duration(minutes: settings.workEndMinutes));
        return TimeWindow(startDate: start, duration: end.difference(start));
    }
  }

  // Handle segment tap
  void _onSegTap(int i) async {
    if (_selected == i) return;
    setState(() => _selected = i);
    await vm.setWindow(_windowFor(i));
  }

  // Auto-scroll while dragging near edges
  void _maybeAutoScroll(double yInViewport) {
    if (!_dayScrollCtrl.hasClients) return;
    final pos = _dayScrollCtrl.position;

    const triggerBand = 120.0;
    const step = 42.0;

    double? delta;
    if (yInViewport < triggerBand) {
      delta = -step;
    } else if (yInViewport > pos.viewportDimension - triggerBand) {
      delta = step;
    }

    if (delta != null && delta != 0.0) {
      final newOffset = (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_dayScrollCtrl.hasClients) {
          _dayScrollCtrl.jumpTo(newOffset);
        }
      });
    }
  }

  // Format time as 12-hour
  String _fmt12AmPm(DateTime dt) {
    int h = dt.hour % 12;
    if (h == 0) h = 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'am' : 'pm';
    return '$h:$m $suffix';
  }

  // Read deadline safely
  DateTime? _safeDeadline(dynamic task) {
    try {
      final d = task.deadline;
      if (d is DateTime) return d;
    } catch (_) {}
    return null;
  }

  // Build schedule body
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        _PillSegmentBar(
          labels: _labels,
          selectedIndex: _selected,
          onTap: _onSegTap,
        ),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              // Build week/month list
              if (_selected != 0) {
                final slots = vm.slots;
                if (slots.isEmpty) {
                  return const Center(child: Text('No scheduled tasks'));
                }
                return Scrollbar(
                  controller: _listScrollCtrl,
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: _listScrollCtrl,
                    primary: false,
                    padding: const EdgeInsets.all(12),
                    itemCount: slots.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = slots[i];
                      final range =
                          '${_fmt12AmPm(s.start)} - ${_fmt12AmPm(s.end)}';
                      final task = widget.appModel.tasks.firstWhere(
                        (t) => t.id == s.taskId,
                        orElse: () => Task(
                          id: s.taskId,
                          title: 'Task',
                          duration: s.length,
                          date: s.start,
                        ),
                      );
                      return ListTile(
                        key: ValueKey(
                            'wkmon_${s.id}_${s.start.millisecondsSinceEpoch}'),
                        leading: Icon(Icons.schedule, color: scheme.secondary),
                        title: Text(task.title),
                        subtitle: Text(range),
                        trailing: Text('Duration: ${_dur(s.length)}'),
                      );
                    },
                  ),
                );
              }

              // Build day timeline with drag-and-drop
              final settings = widget.appModel.settings;
              final workStart = Duration(minutes: settings.workStartMinutes);
              final workEnd = Duration(minutes: settings.workEndMinutes);

              final displayStart =
                  workStart - const Duration(hours: 1, minutes: 5);
              final displayEnd = workEnd + const Duration(hours: 1, minutes: 5);
              final displaySpan = displayEnd - displayStart;

              final dayStartMidnight = DateTime(
                vm.window.startDate.year,
                vm.window.startDate.month,
                vm.window.startDate.day,
              );

              final dayDisplayStart = dayStartMidnight.add(displayStart);
              final dayDisplayEnd = dayStartMidnight.add(displayEnd);
              final dayWorkStart = dayStartMidnight.add(workStart);
              final dayWorkEnd = dayStartMidnight.add(workEnd);

              final slots = vm.slots;
              final contentHeight = displaySpan.inMinutes * _pxPerMinute;

              // Build scrollable day canvas
              return Scrollbar(
                controller: _dayScrollCtrl,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _dayScrollCtrl,
                  primary: false,
                  child: SizedBox(
                    height: contentHeight,
                    child: Stack(
                      children: [
                        // Hour grid and ruler
                        Positioned.fill(
                          child: _HourGrid(
                            start: dayDisplayStart,
                            end: dayDisplayEnd,
                            workStart: dayWorkStart,
                            workEnd: dayWorkEnd,
                            pxPerMinute: _pxPerMinute,
                            gutterWidth: _gutterWidth,
                            hPadding: _hPadding,
                          ),
                        ),

                        // Current time indicator
                        Positioned.fill(
                          child: _NowIndicator(
                            dayDisplayStart: dayDisplayStart,
                            dayDisplayEnd: dayDisplayEnd,
                            pxPerMinute: _pxPerMinute,
                            gutterWidth: _gutterWidth,
                            hPadding: _hPadding,
                          ),
                        ),

                        // Task chips
                        ...slots.map((s) {
                          final startMinutes = s.start
                              .difference(dayDisplayStart)
                              .inMinutes
                              .clamp(0, displaySpan.inMinutes);
                          final endMinutes = s.end
                              .difference(dayDisplayStart)
                              .inMinutes
                              .clamp(0, displaySpan.inMinutes);
                          final top = startMinutes * _pxPerMinute;
                          final baseHeight =
                              (endMinutes - startMinutes) * _pxPerMinute;

                          final task = widget.appModel.tasks.firstWhere(
                            (t) => t.id == s.taskId,
                            orElse: () => Task(
                              id: s.taskId,
                              title: 'Task',
                              duration: s.length,
                              date: s.start,
                            ),
                          );

                          final isCompleted =
                              task.status == TaskStatus.completed;
                          final deadline = _safeDeadline(task);
                          final subtitleTimes =
                              '${_fmt12AmPm(s.start)} - ${_fmt12AmPm(s.end)}';
                          final deadlineText = deadline != null
                              ? 'Deadline: ${_fmt12AmPm(deadline)}'
                              : null;

                          final isOverdue = (deadline != null) &&
                              deadline.isBefore(DateTime.now());

                          late final Color chipFill;
                          late final Color chipText;
                          if (isOverdue) {
                            chipFill = scheme.errorContainer;
                            chipText = scheme.onErrorContainer;
                          } else if (isCompleted) {
                            chipFill = scheme.tertiaryContainer;
                            chipText = scheme.onTertiaryContainer;
                          } else {
                            chipFill = scheme.secondaryContainer;
                            chipText = scheme.onSecondaryContainer;
                          }

                          final childTile = _TaskChip(
                            key: ValueKey(
                                'day_${s.id}_${s.start.millisecondsSinceEpoch}'),
                            title: task.title,
                            durationText: 'Duration: ${_dur(s.length)}',
                            timeRangeText: subtitleTimes,
                            deadlineText: deadlineText,
                            borderColor: scheme.outlineVariant,
                            fill: chipFill,
                            textColor: chipText,
                            iconColor: chipText,
                            isCompleted: isCompleted,
                          );

                          final contentWidth =
                              MediaQuery.sizeOf(context).width -
                                  (_gutterWidth + _hPadding * 2);
                          final narrowFactor = 0.986;
                          final feedbackWidth = contentWidth * narrowFactor;

                          final feedback = RepaintBoundary(
                            child: Transform.scale(
                              scale: 0.98,
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: feedbackWidth,
                                child: _TaskChip(
                                  title: task.title,
                                  durationText: 'Duration: ${_dur(s.length)}',
                                  timeRangeText: subtitleTimes,
                                  deadlineText: deadlineText,
                                  borderColor: scheme.outlineVariant,
                                  fill: chipFill,
                                  textColor: chipText,
                                  iconColor: chipText,
                                  isCompleted: isCompleted,
                                ),
                              ),
                            ),
                          );

                          final double tileHeight = isCompleted
                              ? 28.0
                              : (baseHeight.isFinite && baseHeight > 0
                                  ? baseHeight
                                  : 1.0);

                          return Positioned(
                            left: _gutterWidth + _hPadding,
                            right: _hPadding,
                            top: top.isFinite ? top : 0.0,
                            height: tileHeight,
                            child: FractionallySizedBox(
                              widthFactor: narrowFactor,
                              alignment: Alignment.center,
                              child: LongPressDraggable<_DragPayload>(
                                data: _DragPayload(
                                  taskId: s.taskId,
                                  originalStart: s.start,
                                ),
                                axis: Axis.vertical,
                                dragAnchorStrategy: childDragAnchorStrategy,
                                maxSimultaneousDrags: 1,
                                feedback: feedback,
                                ignoringFeedbackSemantics: true,
                                childWhenDragging:
                                    Opacity(opacity: 0.45, child: childTile),
                                child: childTile,
                              ),
                            ),
                          );
                        }),

                        // Drop surface for drag placement
                        Positioned.fill(
                          child: DragTarget<_DragPayload>(
                            key: _dayDropKey,
                            onWillAcceptWithDetails: (details) =>
                                details.data.taskId.isNotEmpty,
                            onMove: (details) {
                              try {
                                final ctx = _dayDropKey.currentContext;
                                final ro = ctx?.findRenderObject();
                                if (ctx == null || ro is! RenderBox) return;

                                final local = ro.globalToLocal(details.offset);
                                final dy = local.dy;
                                if (!dy.isFinite) return;

                                if (_dayScrollCtrl.hasClients) {
                                  final pos = _dayScrollCtrl.position;
                                  final yInViewport = dy - pos.pixels;
                                  _maybeAutoScroll(yInViewport);
                                }
                              } catch (_) {}
                            },
                            onAcceptWithDetails: (details) {
                              try {
                                final ctx = _dayDropKey.currentContext;
                                final ro = ctx?.findRenderObject();
                                if (ctx == null || ro is! RenderBox) return;

                                final local = ro.globalToLocal(details.offset);
                                final dy = local.dy;
                                if (!dy.isFinite) return;

                                final clampedDy = dy.clamp(0.0, contentHeight);
                                final rawMinutes =
                                    (clampedDy / _pxPerMinute).round();
                                final snappedMinutes =
                                    ((rawMinutes + 2) ~/ 5) * 5;

                                var computedStart = dayDisplayStart
                                    .add(Duration(minutes: snappedMinutes));

                                if (computedStart.isBefore(dayWorkStart)) {
                                  computedStart = dayWorkStart;
                                } else if (!computedStart
                                    .isBefore(dayWorkEnd)) {
                                  computedStart = dayWorkEnd
                                      .subtract(const Duration(minutes: 1));
                                }

                                final taskId = details.data.taskId;

                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) async {
                                  if (!mounted) return;
                                  try {
                                    await vm.applyDragToStart(
                                      taskId: taskId,
                                      newStart: computedStart,
                                    );
                                  } catch (e, st) {
                                    debugPrint(
                                        '[DragTarget] vm.applyDragToStart error: $e\n$st');
                                  }
                                });
                              } catch (e, st) {
                                debugPrint(
                                    '[DragTarget] onAcceptWithDetails error: $e\n$st');
                              }
                            },
                            builder: (_, __, ___) => const SizedBox.expand(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Format duration in words
  String _dur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) {
      final unit = (m == 1) ? 'min' : 'mins';
      return '$m $unit';
    }
    if (m == 0) {
      final unit = (h == 1) ? 'hour' : 'hours';
      return '$h $unit';
    }
    final hUnit = (h == 1) ? 'hour' : 'hours';
    final mUnit = (m == 1) ? 'min' : 'mins';
    return '$h $hUnit $m $mUnit';
  }
}

class _DragPayload {
  final String taskId;
  final DateTime originalStart;
  _DragPayload({required this.taskId, required this.originalStart});
}

class _TaskChip extends StatelessWidget {
  final String title;
  final String durationText;
  final String timeRangeText;
  final String? deadlineText;
  final Color borderColor;
  final Color fill;
  final Color? textColor;
  final Color? iconColor;
  final bool isCompleted;

  const _TaskChip({
    super.key,
    required this.title,
    required this.durationText,
    required this.timeRangeText,
    required this.deadlineText,
    required this.borderColor,
    required this.fill,
    this.textColor,
    this.iconColor,
    required this.isCompleted,
  });

  // Build task chip
  @override
  Widget build(BuildContext context) {
    final Color effectiveText =
        textColor ?? Theme.of(context).colorScheme.onSurface;
    final Color effectiveIcon = iconColor ?? effectiveText;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 12, vertical: isCompleted ? 6 : 8),
        constraints: BoxConstraints(minHeight: isCompleted ? 28 : 40),
        decoration: ShapeDecoration(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: effectiveText),
          child: IconTheme(
            data: IconThemeData(color: effectiveIcon),
            child: isCompleted
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, size: 18),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and duration
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.schedule, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            durationText,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Time range and optional deadline
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              timeRangeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          if (deadlineText != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              deadlineText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _LightFeedbackChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _LightFeedbackChip({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  // Build lightweight drag feedback chip
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: IgnorePointer(
        child: Transform.scale(
          scale: 0.98,
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            constraints: const BoxConstraints(minHeight: 32),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: scheme.outlineVariant, width: 1),
            ),
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 12, color: scheme.onSurface),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(trailing,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HourGrid extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final DateTime workStart;
  final DateTime workEnd;
  final double pxPerMinute;
  final double gutterWidth;
  final double hPadding;

  const _HourGrid({
    required this.start,
    required this.end,
    required this.workStart,
    required this.workEnd,
    required this.pxPerMinute,
    required this.gutterWidth,
    required this.hPadding,
  });

  String _two(int n) => n.toString().padLeft(2, '0');

  // Format time label
  String _fmt12AmPm(DateTime dt) {
    int h = dt.hour % 12;
    if (h == 0) h = 12;
    final m = _two(dt.minute);
    final suffix = dt.hour < 12 ? 'am' : 'pm';
    return '$h:$m $suffix';
  }

  // Check if time is within range
  bool _isWithin(DateTime t, DateTime a, DateTime b) {
    return !t.isBefore(a) && t.isBefore(b);
  }

  // Build hour grid
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final baseLabel = theme.textTheme.labelSmall!;
    final labelFontSize = (baseLabel.fontSize ?? 11) + 1.0;

    const hourLineThickness = 0.9;

    const hourLabelOpacity = 0.96;
    const halfLabelOpacity = 0.85;

    final children = <Widget>[];

    // Background bands
    final minutesFromMidnightStart = start.hour * 60 + start.minute;
    final floorTo30 =
        minutesFromMidnightStart - (minutesFromMidnightStart % 30);
    DateTime slotCursor = DateTime(
      start.year,
      start.month,
      start.day,
      floorTo30 ~/ 60,
      floorTo30 % 60,
    );

    while (slotCursor.isBefore(end)) {
      final next = slotCursor.add(const Duration(minutes: 30));
      final slotStartClamped = slotCursor.isBefore(start) ? start : slotCursor;
      final slotEndClamped = next.isAfter(end) ? end : next;

      final mid = slotStartClamped.add(
        Duration(
          minutes: ((slotEndClamped.difference(slotStartClamped).inMinutes) / 2)
              .floor(),
        ),
      );

      final yTop = slotStartClamped.difference(start).inMinutes * pxPerMinute;
      final yBottom = slotEndClamped.difference(start).inMinutes * pxPerMinute;
      final height = (yBottom - yTop).clamp(0.0, double.infinity);

      final slotIndex = (slotCursor.hour * 60 + slotCursor.minute) ~/ 30;

      final inWork = _isWithin(mid, workStart, workEnd);

      final inWorkBand = scheme.secondaryContainer.withValues(alpha: 0.45);
      final outWorkBand = scheme.secondaryContainer;

      final Color bandColor = (slotIndex % 2 == 0)
          ? (inWork ? inWorkBand : outWorkBand)
          : (inWork
              ? inWorkBand.withValues(alpha: 0.4)
              : outWorkBand.withValues(alpha: 0.85));

      if (height > 0) {
        children.add(Positioned(
          left: gutterWidth + hPadding,
          right: hPadding,
          top: yTop,
          height: height,
          child: Container(color: bandColor),
        ));
      }

      slotCursor = next;
    }

    // Work window markers
    final workTop = workStart.difference(start).inMinutes * pxPerMinute;
    final workBottom = workEnd.difference(start).inMinutes * pxPerMinute;

    final markerColor = scheme.secondary.withValues();
    for (final y in [workTop, workBottom]) {
      children.add(Positioned(
        left: gutterWidth + hPadding,
        right: hPadding,
        top: y,
        child: Container(
          height: 2.2,
          color: markerColor,
        ),
      ));
    }

    // Start label
    children.add(Positioned(
      left: gutterWidth + hPadding,
      right: hPadding,
      top: (workTop - 34).clamp(0.0, double.infinity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: markerColor),
          ),
          child: Text(
            'Schedule Start: ${_fmt12AmPm(workStart)}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    ));

    // End label
    children.add(Positioned(
      left: gutterWidth + hPadding,
      right: hPadding,
      top: (workBottom + 10).clamp(0.0, double.infinity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: markerColor),
          ),
          child: Text(
            'Schedule End: ${_fmt12AmPm(workEnd)}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    ));

    // Grid lines and labels
    final minutesToNext30 = (30 - (minutesFromMidnightStart % 30)) % 30;
    DateTime tick = start.add(Duration(minutes: minutesToNext30));

    while (!tick.isAfter(end)) {
      final y = tick.difference(start).inMinutes * pxPerMinute;
      final isHour = tick.minute == 0;

      children.add(Positioned(
        left: 0,
        top: y - 10,
        child: SizedBox(
          width: gutterWidth,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 1),
              child: Text(
                _fmt12AmPm(tick),
                style: baseLabel.copyWith(
                  fontSize: labelFontSize,
                  color: (baseLabel.color ?? scheme.onSurface).withValues(
                      alpha: isHour ? hourLabelOpacity : halfLabelOpacity),
                  fontWeight: isHour ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ));

      children.add(Positioned(
        left: gutterWidth + hPadding,
        right: hPadding,
        top: y,
        child: Container(
            height: hourLineThickness,
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
      ));

      tick = tick.add(const Duration(minutes: 30));
    }

    return Stack(children: children);
  }
}

class _PillSegmentBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PillSegmentBar({
    required this.labels,
    required this.selectedIndex,
    required this.onTap,
  });

  // Build segmented control
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final selectedFill = theme.colorScheme.primary.withValues(alpha: 0.12);
    final selectedText = theme.colorScheme.primary;
    final normalText =
        theme.textTheme.labelLarge?.color ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = i == selectedIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? selectedText : normalText,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NowIndicator extends StatefulWidget {
  final DateTime dayDisplayStart;
  final DateTime dayDisplayEnd;
  final double pxPerMinute;
  final double gutterWidth;
  final double hPadding;

  const _NowIndicator({
    required this.dayDisplayStart,
    required this.dayDisplayEnd,
    required this.pxPerMinute,
    required this.gutterWidth,
    required this.hPadding,
  });

  @override
  State<_NowIndicator> createState() => _NowIndicatorState();
}

class _NowIndicatorState extends State<_NowIndicator> {
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now());
  Timer? _alignTimer;
  Timer? _minuteTimer;

  // Start minute-aligned timer
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final toNextMinuteMs =
        (60000 - (now.second * 1000 + now.millisecond)) % 60000;
    _alignTimer = Timer(Duration(milliseconds: toNextMinuteMs), () {
      _now.value = DateTime.now();
      _minuteTimer?.cancel();
      _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        _now.value = DateTime.now();
      });
    });
  }

  // Dispose timers
  @override
  void dispose() {
    _alignTimer?.cancel();
    _minuteTimer?.cancel();
    _now.dispose();
    super.dispose();
  }

  // Compare dates
  bool _sameYMD(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Build now indicator
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _now,
      builder: (context, _) {
        final now = _now.value;

        final isToday = _sameYMD(now, widget.dayDisplayStart);
        if (!isToday ||
            now.isBefore(widget.dayDisplayStart) ||
            !now.isBefore(widget.dayDisplayEnd)) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: _NowIndicatorPainter(
              now: now,
              displayStart: widget.dayDisplayStart,
              pxPerMinute: widget.pxPerMinute,
              gutterWidth: widget.gutterWidth,
              hPadding: widget.hPadding,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            isComplex: false,
            willChange: true,
          ),
        );
      },
    );
  }
}

class _NowIndicatorPainter extends CustomPainter {
  final DateTime now;
  final DateTime displayStart;
  final double pxPerMinute;
  final double gutterWidth;
  final double hPadding;
  final Color color;

  _NowIndicatorPainter({
    required this.now,
    required this.displayStart,
    required this.pxPerMinute,
    required this.gutterWidth,
    required this.hPadding,
    required this.color,
  });

  // Paint now line and dot
  @override
  void paint(Canvas canvas, Size size) {
    final minutesFromDisplayStart =
        now.difference(displayStart).inMinutes.toDouble();
    final y = (minutesFromDisplayStart * pxPerMinute).clamp(0.0, size.height);

    final left = gutterWidth + hPadding;
    final right = size.width - hPadding;

    final line = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(left, y), Offset(right, y), line);

    final r = 4.0;
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(left - r, y), r, dotPaint);
  }

  // Repaint when values change
  @override
  bool shouldRepaint(covariant _NowIndicatorPainter old) {
    return now.minute != old.now.minute ||
        pxPerMinute != old.pxPerMinute ||
        gutterWidth != old.gutterWidth ||
        hPadding != old.hPadding ||
        color != old.color ||
        displayStart != old.displayStart;
  }
}
