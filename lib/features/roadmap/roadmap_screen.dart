import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phases = ref.watch(phasesProvider).valueOrNull ?? const [];
    final tasks = ref.watch(roadmapTasksProvider).valueOrNull ?? const [];

    final tasksByPhase = <int, List<RoadmapTask>>{};
    for (final t in tasks) {
      tasksByPhase.putIfAbsent(t.phaseId, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadmap'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        actions: [
          IconButton(
            tooltip: 'Regenerate',
            onPressed: () => _confirmRegenerate(context, ref),
            icon: const Icon(Icons.autorenew_rounded),
          ),
        ],
      ),
      body: phases.isEmpty
          ? EmptyState(
              icon: Icons.map_rounded,
              title: 'No roadmap yet',
              message: 'Generate a personalized plan based on your goals.',
              actionLabel: 'Generate roadmap',
              onAction: () => _regenerate(ref),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
              itemCount: phases.length,
              itemBuilder: (context, i) {
                final phase = phases[i];
                return _PhaseCard(
                  phase: phase,
                  tasks: tasksByPhase[phase.id] ?? const [],
                  index: i,
                  isLast: i == phases.length - 1,
                ).entrance(index: i);
              },
            ),
    );
  }

  Future<void> _confirmRegenerate(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Regenerate roadmap?'),
        content: const Text(
            'This rebuilds your phases and weekly plan from your current goals. Your problem progress is kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Regenerate')),
        ],
      ),
    );
    if (ok == true) _regenerate(ref);
  }

  Future<void> _regenerate(WidgetRef ref) async {
    final profile = await ref.read(profileRepositoryProvider).get();
    await ref.read(roadmapRepositoryProvider).generate(profile);
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
    required this.tasks,
    required this.index,
    required this.isLast,
  });
  final RoadmapPhase phase;
  final List<RoadmapTask> tasks;
  final int index;
  final bool isLast;

  static const _gradients = [
    AppPalette.brandGradient,
    AppPalette.progressGradient,
    AppPalette.sunsetGradient,
    LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('d MMM');
    final done = tasks.where((t) => t.done).length;
    final now = DateTime.now();
    final active = now.isAfter(phase.startDate) && now.isBefore(phase.endDate);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail.
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: _gradients[index % _gradients.length],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: AppCard(
                borderColor: active ? theme.colorScheme.primary : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(phase.title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Text('NOW',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                    Text(phase.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                            '${df.format(phase.startDate)} – ${df.format(phase.endDate)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const Spacer(),
                        Text('$done/${tasks.length} weeks',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final t in tasks) _TaskRow(task: t),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});
  final RoadmapTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () =>
          ref.read(roadmapRepositoryProvider).toggleTask(task.id, !task.done),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              task.done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: task.done
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: task.done ? TextDecoration.lineThrough : null,
                  color: task.done ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            Text('${task.targetProblems}q',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
