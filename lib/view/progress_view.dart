// Imports/Packages
import 'package:flutter/material.dart';
import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/model/entities.dart' as ent;
import 'package:adhd_todo/viewmodel/progress_view_model.dart';

class ProgressBody extends StatefulWidget {
  final AppModel appModel;
  const ProgressBody({super.key, required this.appModel});

  @override
  State<ProgressBody> createState() => ProgressBodyState();
}

class ProgressBodyState extends State<ProgressBody> {
  late final ProgressViewModel vm;
  late ent.TimeWindow window;
  ent.ListKind _kind = ent.ListKind.today;

  // Initialize view model and window
  @override
  void initState() {
    super.initState();
    vm = ProgressViewModel(widget.appModel);
    window = ent.TimeWindow(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      duration: const Duration(days: 7),
    );
    vm.setContext(kind: _kind, window: window);
  }

  // Refresh progress
  Future<void> refresh() async {
    await vm.refresh();
  }

  // Build progress body
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Range selector
        _PillProgressRangeBar(onSelect: (kind, win) async {
          _kind = kind;
          window = win;
          await vm.setContext(kind: kind, window: win);
        }),
        const Divider(height: 1),
        // Content
        Expanded(
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              final p = vm.current;
              if (p == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final expDen = vm.nextLevelExp == 0 ? 1 : vm.nextLevelExp;
              final expValue = (vm.currentExp / expDen).clamp(0.0, 1.0);

              final taskDen = vm.total == 0 ? 1 : vm.total;
              final taskValue = (vm.completed / taskDen).clamp(0.0, 1.0);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Level header and bar
                  Row(
                    children: [
                      Text(
                        'Level ${vm.currentLevel}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${vm.currentExp} / ${vm.nextLevelExp}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: expValue),
                  const SizedBox(height: 24),

                  // Task header and bar
                  Row(
                    children: [
                      Text(
                        'Tasks',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${vm.completed} / ${vm.total}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: taskValue),
                  const SizedBox(height: 24),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(label: 'Completed', value: '${vm.completed}'),
                      _StatCard(label: 'Planned', value: '${vm.tasksPlanned}'),
                      _StatCard(label: 'Rate', value: vm.rateDisplay),
                      _StatCard(label: 'Streak', value: vm.streakDisplay),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProgressView extends StatelessWidget {
  final AppModel appModel;
  const ProgressView({super.key, required this.appModel});

  // Build standalone progress screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Progress'),
        centerTitle: true,
      ),
      body: ProgressBody(appModel: appModel),
    );
  }
}

class _PillProgressRangeBar extends StatefulWidget {
  final Future<void> Function(ent.ListKind, ent.TimeWindow) onSelect;
  const _PillProgressRangeBar({required this.onSelect});

  @override
  State<_PillProgressRangeBar> createState() => _PillProgressRangeBarState();
}

class _PillProgressRangeBarState extends State<_PillProgressRangeBar> {
  static const _labels = ['Today', 'Week', 'Month', 'All'];
  int _index = 0;

  // Map index to list kind
  ent.ListKind _kindFor(int i) {
    switch (i) {
      case 0:
        return ent.ListKind.today;
      case 1:
        return ent.ListKind.week;
      case 2:
        return ent.ListKind.month;
      default:
        return ent.ListKind.all;
    }
  }

  // Map index to time window
  ent.TimeWindow _windowFor(int i) {
    final now = DateTime.now();
    switch (i) {
      case 0:
        return ent.TimeWindow(
          startDate: DateTime(now.year, now.month, now.day),
          duration: const Duration(days: 1),
        );
      case 1:
        final startOfWeek =
            DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        return ent.TimeWindow(startDate: startOfWeek, duration: const Duration(days: 7));
      case 2:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final nextMonth =
            (now.month == 12) ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
        return ent.TimeWindow(
          startDate: startOfMonth,
          duration: nextMonth.difference(startOfMonth),
        );
      default:
        return ent.TimeWindow(
          startDate: now.subtract(const Duration(days: 365)),
          duration: const Duration(days: 365),
        );
    }
  }

  // Build range selector
  @override
  Widget build(BuildContext context) {
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
          children: List.generate(_labels.length, (i) {
            final selected = _index == i;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  setState(() => _index = i);
                  await widget.onSelect(_kindFor(i), _windowFor(i));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _labels[i],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  // Build small stat card
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ent.AppColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: ent.AppColors.mutedOnSurface(context)),
            ),
          ],
        ),
      ),
    );
  }
}
