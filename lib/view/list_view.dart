// Imports/Packages
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/model/entities.dart' as ent;
import 'package:adhd_todo/viewmodel/list_view_model.dart';
import 'package:adhd_todo/view/schedule_view.dart';
import 'package:adhd_todo/view/progress_view.dart';
import 'package:adhd_todo/view/settings_view.dart';

class ListViewScreen extends StatefulWidget {
  final AppModel appModel;
  const ListViewScreen({super.key, required this.appModel});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  late final ListViewModel vm;
  late final PageController _pageController;
  int _index = 0;

  final GlobalKey<ScheduleBodyState> _scheduleKey = GlobalKey<ScheduleBodyState>();
  final GlobalKey<ProgressBodyState> _progressKey = GlobalKey<ProgressBodyState>();

  // Initialize state
  @override
  void initState() {
    super.initState();
    vm = ListViewModel(widget.appModel);
    _pageController = PageController(initialPage: 0);
    vm.initialize();
  }

  // Dispose controllers
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get current title
  String get _title {
    switch (_index) {
      case 0:
        return 'Tasks';
      case 1:
        return 'Schedule';
      case 2:
        return 'Progress';
      default:
        return 'ADHD TODO';
    }
  }

  // Open settings screen
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(appModel: widget.appModel)),
    );
  }

  // Handle bottom navigation tap
  void _onNavTap(int i) {
    setState(() {
      _index = i;
    });
    // Refresh schedule when entering schedule tab
    if (i == 1) {
      _scheduleKey.currentState?.reload();
    }
    // Refresh progress when entering progress tab
    if (i == 2) {
      _progressKey.currentState?.refresh();
    }
  }

  // Build screen
  @override
  Widget build(BuildContext context) {
    final showFab = _index == 0 || _index == 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _openSettings,
          tooltip: 'Settings',
        ),
        // Counts in title
        title: _index == 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_title),
                  const SizedBox(height: 2),
                  ListenableBuilder(
                    listenable: vm,
                    builder: (context, _) {
                      final counts = vm.counts;
                      return Text(
                        'Today ${counts.today} • Week ${counts.week} • Month ${counts.month} • All ${counts.all}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ],
              )
            : Text(_title),
        centerTitle: true,
        bottom: null,
      ),
      body: IndexedStack(
        index: _index,
        children: [
          // Tasks tab with PageView
          Column(
            children: [
              // Segment bar and page control
              ListenableBuilder(
                listenable: vm,
                builder: (context, _) {
                  return _SegmentBar(
                    currentIndex: vm.currentIndex,
                    onSelectIndex: (i) {
                      // Update view model and animate
                      vm.selectIndex(i);
                      _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      );
                    },
                  );
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ListenableBuilder(
                  listenable: vm,
                  builder: (context, _) {
                    return PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) async {
                        // Sync view model with swipe
                        await vm.selectIndex(i);
                      },
                      itemCount: ListViewModel.segments.length,
                      itemBuilder: (context, pageIndex) {
                        final isCurrent = pageIndex == vm.currentIndex;
                        final pageKind = ListViewModel.segments[pageIndex].kind;
                        // Current page tasks
                        final tasks = isCurrent ? vm.currentTasks : const <ent.Task>[];

                        // Build page content
                        Widget content;
                        if (tasks.isEmpty) {
                          content = isCurrent
                              ? const Center(child: Text('No tasks yet'))
                              : const SizedBox.shrink();
                        } else {
                          content = ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 0),
                            itemBuilder: (context, i) {
                              final t = tasks[i];
                              final deadlineText =
                                  t.deadline == null ? 'None' : _formatDeadlineHhmmDdMmYyyy(t.deadline!);
                              final durationText = _formatDurationHHMM(t.duration);

                              // Draggable task row
                              return LongPressDraggable<_DragData>(
                                data: _DragData(taskId: t.id, from: pageKind),
                                dragAnchorStrategy: childDragAnchorStrategy,
                                feedback: Material(
                                  type: MaterialType.transparency,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 340),
                                    child: Opacity(
                                      opacity: 0.95,
                                      child: _TaskTile(
                                        title: t.title,
                                        deadlineText: 'Deadline: $deadlineText',
                                        durationText: 'Duration: $durationText',
                                        isPreview: true,
                                        isCompleted: t.status == ent.TaskStatus.completed,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.25,
                                  child: _dismissibleTaskTile(context, vm, t, deadlineText, durationText),
                                ),
                                child: _dismissibleTaskTile(context, vm, t, deadlineText, durationText),
                              );
                            },
                          );
                        }

                        // Wrap with drop target and auto-swipe
                        return Stack(
                          children: [
                            Positioned.fill(child: content),

                            // Full-page drop zone
                            Positioned.fill(
                              child: DragTarget<_DragData>(
                                onWillAcceptWithDetails: (details) => pageKind != ent.ListKind.all,
                                onAcceptWithDetails: (details) async {
                                  // Block moves into "All"
                                  if (pageKind == ent.ListKind.all) return;

                                  // Capture context
                                  final pageCtx = context;

                                  final taskId = details.data.taskId;
                                  final task = vm.getTask(taskId);
                                  if (task == null) return;

                                  // Decide prompt
                                  final needsPrompt = await vm.shouldPromptForMove(
                                    taskId: taskId,
                                    target: pageKind,
                                  );

                                  if (!pageCtx.mounted) return;

                                  // Handle prompt choice
                                  if (needsPrompt) {
                                    final choice = await _showMovePromptDialog(
                                      context: pageCtx,
                                      task: task,
                                    );

                                    if (!pageCtx.mounted) return;

                                    if (choice == _MoveChoice.ignore) {
                                      await vm.moveClearingDeadline(taskId: taskId, target: pageKind);
                                    } else if (choice == _MoveChoice.newDeadline) {
                                      final picked = await _pickDeadline(pageCtx, initial: task.deadline);
                                      if (!pageCtx.mounted) return;
                                      if (picked != null) {
                                        await vm.moveWithNewDeadline(
                                          taskId: taskId,
                                          target: pageKind,
                                          newDeadline: picked,
                                        );
                                      }
                                    } else {
                                      // Do nothing
                                    }
                                  } else {
                                    // Move without changing deadline
                                    await vm.moveIgnoringDeadline(taskId: taskId, target: pageKind);
                                  }
                                },
                                builder: (context, candidates, rejects) {
                                  final active = candidates.isNotEmpty;
                                  final scrim = Theme.of(context).colorScheme.scrim;
                                  return IgnorePointer(
                                    ignoring: true,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 120),
                                      color: active
                                          ? scrim.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Edge auto-swipe overlays
                            _EdgeAutoSwipe(
                              side: AxisDirection.left,
                              controller: _pageController,
                              currentIndex: vm.currentIndex,
                            ),
                            _EdgeAutoSwipe(
                              side: AxisDirection.right,
                              controller: _pageController,
                              currentIndex: vm.currentIndex,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Schedule tab
          ScheduleBody(key: _scheduleKey, appModel: widget.appModel),

          // Progress tab
          ProgressBody(key: _progressKey, appModel: widget.appModel),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Progress'),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Open add task sheet
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (ctx) => _TaskEditorSheet.add(vm: vm),
                );
                // Refresh schedule if needed
                if (_index == 1) {
                  _scheduleKey.currentState?.reload();
                }
              },
              label: const Text('New Task'),
              icon: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Build a dismissible task tile
  Widget _dismissibleTaskTile(
    BuildContext context,
    ListViewModel vm,
    ent.Task t,
    String deadlineText,
    String durationText,
  ) {
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) async {
        await vm.deleteTask(t.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      },
      child: Semantics(
        label: t.title,
        value: 'Deadline $deadlineText, Duration $durationText',
        button: true,
        child: InkWell(
          onTap: () async {
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (ctx) => _TaskEditorSheet.edit(
                vm: vm,
                task: t,
              ),
            );
          },
          child: _TaskTile(
            title: t.title,
            deadlineText: 'Deadline: $deadlineText',
            durationText: 'Duration: ${_formatDurationHHMM(t.duration)}',
            isCompleted: t.status == ent.TaskStatus.completed,
          ),
        ),
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectIndex;
  const _SegmentBar({required this.currentIndex, required this.onSelectIndex});

  // Build segment bar
  @override
  Widget build(BuildContext context) {
    const items = [
      ListViewModel.todaySeg,
      ListViewModel.weekSeg,
      ListViewModel.monthSeg,
      ListViewModel.allSeg,
    ];

    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final selectedFill = ent.AppColors.primary(context).withValues(alpha: 0.12);
    final selectedText = ent.AppColors.primary(context);
    final normalText = ent.AppColors.onSurface(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ent.AppColors.outline(context).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final seg = items[i];
            final selected = i == currentIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelectIndex(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _labelFor(seg.kind),
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

  // Label for segment
  static String _labelFor(ent.ListKind k) {
    switch (k) {
      case ent.ListKind.today:
        return 'Today';
      case ent.ListKind.week:
        return 'Week';
      case ent.ListKind.month:
        return 'Month';
      case ent.ListKind.all:
        return 'All';
    }
  }
}

// Task tile widget
class _TaskTile extends StatelessWidget {
  final String title;
  final String deadlineText;
  final String durationText;
  final bool isPreview;
  final bool isCompleted;

  const _TaskTile({
    required this.title,
    required this.deadlineText,
    required this.durationText,
    this.isPreview = false,
    this.isCompleted = false,
  });

  // Build task tile
  @override
  Widget build(BuildContext context) {
    final compact = isCompleted;
    return Container(
      margin: EdgeInsets.symmetric(vertical: compact ? 2 : 6),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPreview
            ? []
            : [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
        border: Border.all(
          color: ent.AppColors.outline(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
                        color: compact
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : null,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deadlineText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        durationText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          compact
              ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

// Edge auto-swipe zone
class _EdgeAutoSwipe extends StatefulWidget {
  final AxisDirection side;
  final PageController controller;
  final int currentIndex;
  const _EdgeAutoSwipe({
    required this.side,
    required this.controller,
    required this.currentIndex,
  });

  @override
  State<_EdgeAutoSwipe> createState() => _EdgeAutoSwipeState();
}

class _EdgeAutoSwipeState extends State<_EdgeAutoSwipe> {
  bool _hovering = false;

  // Build edge zone
  @override
  Widget build(BuildContext context) {
    final isLeft = widget.side == AxisDirection.left;
    return Positioned(
      top: 0,
      bottom: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: 56,
      child: DragTarget<_DragData>(
        onMove: (details) async {
          // Delay to avoid accidental swipes
          if (!_hovering) {
            _hovering = true;
            await Future.delayed(const Duration(milliseconds: 120));
            if (!mounted) return;
            if (_hovering) {
              final nextIndex = isLeft ? widget.currentIndex - 1 : widget.currentIndex + 1;
              if (nextIndex >= 0 && nextIndex < ListViewModel.segments.length) {
                widget.controller.animateToPage(
                  nextIndex,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            }
          }
        },
        onLeave: (_) => _hovering = false,
        builder: (context, candidates, rejects) {
          final active = candidates.isNotEmpty && _hovering;
          final scrim = Theme.of(context).colorScheme.scrim;
          return IgnorePointer(
            ignoring: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              color: active ? scrim.withValues(alpha: 0.06) : Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}

// Drag payload
class _DragData {
  final String taskId;
  final ent.ListKind from;
  _DragData({required this.taskId, required this.from});
}

// Task editor bottom sheet
enum _EditorMode { add, edit }

class _TaskEditorSheet extends StatefulWidget {
  final ListViewModel vm;
  final _EditorMode mode;
  final ent.Task? task;

  const _TaskEditorSheet._({
    required this.vm,
    required this.mode,
    this.task,
  });

  // Factory for add
  factory _TaskEditorSheet.add({required ListViewModel vm}) =>
      _TaskEditorSheet._(vm: vm, mode: _EditorMode.add);

  // Factory for edit
  factory _TaskEditorSheet.edit({required ListViewModel vm, required ent.Task task}) =>
      _TaskEditorSheet._(vm: vm, mode: _EditorMode.edit, task: task);

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  bool _expanded = false;

  Duration _duration = const Duration(minutes: 30);
  DateTime? _deadline;
  bool _startReminder = false;
  bool _deadlineReminder = false;

  // Filled button style
  ButtonStyle get _filledWideStyle => FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // Outlined button style
  ButtonStyle get _outlinedWideStyle => OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // Initialize editor state
  @override
  void initState() {
    super.initState();
    if (widget.mode == _EditorMode.edit && widget.task != null) {
      final t = widget.task!;
      _nameCtrl.text = t.title;
      _duration = t.duration;
      _deadline = t.deadline;
      // Set reminder switches from task
      _startReminder = t.remindOnStart;
      _deadlineReminder = t.remindOnDeadline;
      // Start expanded in edit mode
      _expanded = true;
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // Build editor content
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == _EditorMode.edit;

    // Header row
    final header = Row(
      children: [
        const Spacer(),
        Text(
          isEdit ? 'Edit Task' : 'New Task',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    // Form fields
    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          // Task name
          TextFormField(
            controller: _nameCtrl,
            autofocus: !isEdit,
            decoration: InputDecoration(
              labelText: 'Task Name',
              contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
              suffixText: '*',
              suffixStyle: TextStyle(color: Theme.of(context).colorScheme.error),
              border: const OutlineInputBorder(),
              isDense: false,
            ),
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Task name is required';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Collapsed: deadline only
          if (!_expanded) ...[
            Row(
              children: [
                Expanded(
                  child: _DeadlineButton(
                    value: _deadline,
                    onChanged: (d) => setState(() => _deadline = d),
                  ),
                ),
              ],
            ),
          ],

          // Expanded: duration and deadline
          if (_expanded) ...[
            Row(
              children: [
                Expanded(
                  child: _DurationButton(
                    value: _duration,
                    onChanged: (d) => setState(() => _duration = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DeadlineButton(
                    value: _deadline,
                    onChanged: (d) => setState(() => _deadline = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reminder switches
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start reminder'),
              value: _startReminder,
              onChanged: (b) => setState(() => _startReminder = b),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline reminder'),
              value: _deadlineReminder,
              onChanged: (b) => setState(() => _deadlineReminder = b),
            ),
          ],
        ],
      ),
    );

    // Action rows
    final rowCompleteDelete = isEdit
        ? Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: _outlinedWideStyle,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Task'),
                  onPressed: () async {
                    final id = widget.task!.id;
                    await widget.vm.deleteTask(id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  style: _filledWideStyle,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete Task'),
                  onPressed: () async {
                    final id = widget.task!.id;
                    await widget.vm.completeTask(id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          )
        : const SizedBox.shrink();

    // Bottom action row
    final rowBottom = Row(
      children: [
        if (!isEdit)
          Expanded(
            child: OutlinedButton(
              style: _outlinedWideStyle,
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Collapse' : 'Expand'),
            ),
          ),
        if (!isEdit) const SizedBox(width: 12),
        if (!isEdit)
          Expanded(
            child: FilledButton(
              style: _filledWideStyle,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                await widget.vm.addTask(
                  _nameCtrl.text.trim(),
                  deadline: _deadline,
                  duration: _duration,
                  // Pass reminder switches
                  remindOnStart: _startReminder,
                  remindOnDeadline: _deadlineReminder,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Add Task'),
            ),
          ),

        // Edit mode buttons
        if (isEdit)
          Expanded(
            child: OutlinedButton(
              style: _outlinedWideStyle,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        if (isEdit) const SizedBox(width: 12),
        if (isEdit)
          Expanded(
            child: FilledButton(
              style: _filledWideStyle,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final id = widget.task!.id;
                final changes = ent.TaskChanges(
                  title: _nameCtrl.text.trim(),
                  deadline: _deadline,
                  duration: _duration,
                  // Include reminder toggles
                  remindOnStart: _startReminder,
                  remindOnDeadline: _deadlineReminder,
                );
                await widget.vm.editTask(id, changes);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
      ],
    );

    return FractionallySizedBox(
      heightFactor: _expanded ? 0.55 : 1 / 3,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: form,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (isEdit) ...[
                rowCompleteDelete,
                const SizedBox(height: 8),
              ],
              rowBottom,
            ],
          ),
        ),
      ),
    );
  }
}

// Buttons
class _DeadlineButton extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _DeadlineButton({required this.value, required this.onChanged});

  // Build deadline button
  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'No deadline' : _formatDateTime(value!);
    return OutlinedButton.icon(
      onPressed: () async {
        // Pick date then time
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 5),
        );
        if (date == null) return;
        if (!context.mounted) return;
        final timeOfDay = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? now),
        );
        final combined = timeOfDay == null
            ? DateTime(date.year, date.month, date.day)
            : DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
        onChanged(combined);
      },
      icon: const Icon(Icons.event),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text('Deadline: $text'),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final Duration value;
  final ValueChanged<Duration> onChanged;
  const _DurationButton({required this.value, required this.onChanged});

  // Build duration button
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await _pickDurationCupertino(context, value);
        if (picked != null) onChanged(picked);
      },
      icon: const Icon(Icons.timer),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text('Duration: ${_formatDuration(value)}'),
      ),
    );
  }
}

// Duration picker
Future<Duration?> _pickDurationCupertino(BuildContext context, Duration initial) async {
  Duration temp = initial;
  return showModalBottomSheet<Duration>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 216,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: initial,
                onTimerDurationChanged: (d) => temp = d,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, temp),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Formatting helpers
String _two(int n) => n.toString().padLeft(2, '0');

String _formatDateTime(DateTime dt) {
  final d = dt.toLocal();
  final y = d.year;
  final m = _two(d.month);
  final day = _two(d.day);
  final hh = _two(d.hour);
  final mm = _two(d.minute);
  return '$y-$m-$day $hh:$mm';
}

// Format deadline as HH:MM - DD/MM/YYYY
String _formatDeadlineHhmmDdMmYyyy(DateTime dt) {
  final d = dt.toLocal();
  final dd = _two(d.day);
  final mm = _two(d.month);
  final yyyy = d.year.toString();
  final hh = _two(d.hour);
  final min = _two(d.minute);
  return '$hh:$min - $dd/$mm/$yyyy';
}

// Format duration as HH:MM
String _formatDurationHHMM(Duration dur) {
  final totalMinutes = dur.inMinutes.abs();
  final hh = _two(totalMinutes ~/ 60);
  final mm = _two(totalMinutes % 60);
  return '$hh:$mm';
}

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

// Move prompt
enum _MoveChoice { cancel, ignore, newDeadline }

Future<_MoveChoice> _showMovePromptDialog({
  required BuildContext context,
  required ent.Task task,
}) async {
  final deadlineLabel =
      task.deadline == null ? 'None' : _formatDeadlineHhmmDdMmYyyy(task.deadline!);

  return (await showDialog<_MoveChoice>(
        context: context,
        builder: (ctx) {
          final textTheme = Theme.of(ctx).textTheme;
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and close
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cancel',
                          onPressed: () => Navigator.pop(ctx, _MoveChoice.cancel),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Deadline: $deadlineLabel',
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(ctx, _MoveChoice.ignore),
                            child: const Text('Ignore'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, _MoveChoice.newDeadline),
                            child: const Text('Change deadline'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )) ??
      _MoveChoice.cancel;
}

// Deadline picker
Future<DateTime?> _pickDeadline(BuildContext context, {DateTime? initial}) async {
  final now = DateTime.now();
  final init = initial ?? now;
  final date = await showDatePicker(
    context: context,
    initialDate: init,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 5),
  );
  if (date == null) return null;
  if (!context.mounted) return null;

  final timeOfDay = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(init),
  );
  if (!context.mounted) return null;

  return timeOfDay == null
      ? DateTime(date.year, date.month, date.day)
      : DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
}
