import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/providers.dart';
import '../tracker/sheet_detail_screen.dart';
import 'planner_effort.dart';
import 'planner_engine.dart';
import 'planner_models.dart';

/// The deadline-driven planner: pick a target date, see per-subject pace and
/// deadlines, today's targets with catch-up, and whether you're on track.
class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(plannerOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        actions: [
          IconButton(
            tooltip: 'Set target date',
            onPressed: () => _editDeadline(context, ref, plan.deadline),
            icon: const Icon(Icons.event_rounded),
          ),
        ],
      ),
      body: plan.isEmpty
          ? EmptyState(
              icon: Icons.flag_rounded,
              title: 'No subjects to plan yet',
              message:
                  'Activate the sheets you want to prepare in My Sheets, then set a target date to get per-subject deadlines and daily targets.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
              children: [
                _DeadlineHeader(
                  plan: plan,
                  onEdit: () => _editDeadline(context, ref, plan.deadline),
                ).entrance(index: 0),
                // Only shown when the maths doesn't work — with the two fixes
                // that actually resolve it.
                if (!plan.feasible) ...[
                  const SizedBox(height: AppSpacing.md),
                  _FeasibilityCard(
                    plan: plan,
                    onExtend: () async {
                      final d = plan.suggestedDeadline;
                      if (d == null) return;
                      await ref.read(profileRepositoryProvider).setTargetDate(d);
                    },
                    onEditHours: () => _editDailyHours(context, ref, plan),
                  ).entrance(index: 0),
                ],
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: "Today's targets",
                  subtitle: plan.todayTarget == 0
                      ? 'Nothing scheduled — you\'re all caught up'
                      : '${plan.todayDone}/${plan.todayTarget} done',
                  icon: Icons.today_rounded,
                ).entrance(index: 1),
                const SizedBox(height: AppSpacing.md),
                for (final s in plan.subjects)
                  if (s.todayItems.isNotEmpty)
                    _TodaySubjectCard(subject: s).entrance(index: 2),
                if (plan.subjects.every((s) => s.todayItems.isEmpty))
                  _AllCaughtUp().entrance(index: 2),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: 'Timeline',
                  subtitle: 'Projected finish per subject vs your deadline',
                  icon: Icons.timeline_rounded,
                ).entrance(index: 3),
                const SizedBox(height: AppSpacing.md),
                _Timeline(plan: plan).entrance(index: 3),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: 'Subjects',
                  subtitle: '${plan.subjects.length} in your plan',
                  icon: Icons.menu_book_rounded,
                ).entrance(index: 4),
                const SizedBox(height: AppSpacing.md),
                for (final s in plan.subjects)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _SubjectCard(subject: s).entrance(index: 4),
                  ),
              ],
            ),
    );
  }

  Future<void> _editDeadline(
      BuildContext context, WidgetRef ref, DateTime current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: 'Target / placement deadline',
    );
    if (picked != null) {
      await ref.read(profileRepositoryProvider).setTargetDate(picked);
    }
  }

  /// Lets the user raise their daily study time until the plan fits.
  Future<void> _editDailyHours(
      BuildContext context, WidgetRef ref, PlanOverview plan) async {
    var hours = (plan.capacityMinutes / 60).clamp(1, 12).round();
    final needed = plan.requiredHoursPerDay;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily study time',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'You need about ${needed.toStringAsFixed(1)} h/day to finish '
                'everything by your target date.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('$hours ${hours == 1 ? 'hour' : 'hours'} a day',
                  style: Theme.of(ctx).textTheme.titleMedium),
              Slider(
                value: hours.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$hours h',
                onChanged: (v) => setSheet(() => hours = v.round()),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(profileRepositoryProvider)
                        .updateGoals(minutes: hours * 60, problems: hours * 2);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the plan cannot fit: states the gap plainly and offers the only
/// two things that actually fix it — more time per day, or a later deadline.
class _FeasibilityCard extends StatelessWidget {
  const _FeasibilityCard({
    required this.plan,
    required this.onExtend,
    required this.onEditHours,
  });
  final PlanOverview plan;
  final Future<void> Function() onExtend;
  final VoidCallback onEditHours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('d MMM yyyy');
    final have = (plan.capacityMinutes / 60);
    final need = plan.requiredHoursPerDay;
    final suggested = plan.suggestedDeadline;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppPalette.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text("This plan doesn't fit",
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${PlanEffort.format(plan.minutesLeft)} of work is left. Finishing '
            'by ${df.format(plan.deadline)} needs ${need.toStringAsFixed(1)} h/day, '
            'but you planned for ${have.toStringAsFixed(1)} h/day.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: onEditHours,
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: const Text('Study more per day'),
              ),
              if (suggested != null)
                FilledButton.tonalIcon(
                  onPressed: onExtend,
                  icon: const Icon(Icons.event_repeat_rounded, size: 18),
                  label: Text('Move to ${df.format(suggested)}'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gradient header: deadline, days left, overall on-track status and progress.
class _DeadlineHeader extends StatelessWidget {
  const _DeadlineHeader({required this.plan, required this.onEdit});
  final PlanOverview plan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('d MMM yyyy');
    final onTrack = plan.onTrack;

    return GradientHeroCard(
      gradient:
          onTrack ? AppPalette.brandGradient : AppPalette.sunsetGradient,
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Target: ${df.format(plan.deadline)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const Spacer(),
              const Icon(Icons.edit_rounded, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            plan.daysToDeadline == 0
                ? 'Deadline is today or passed'
                : '${plan.daysToDeadline} days to go',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Overall progress.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text('${plan.done}/${plan.total} items',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white70)),
              const Spacer(),
              Text('${(plan.progress * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  onTrack
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _statusLine(plan),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLine(PlanOverview plan) {
    if (plan.total == 0) return 'Nothing to plan yet';
    if (plan.left == 0) return 'All done — every subject complete!';
    if (!plan.canFinish) {
      return "Some subjects have a pace of 0 — they won't finish. Raise a pace.";
    }
    if (plan.onTrack) {
      final proj = plan.projectedFinish;
      if (proj == null) return 'On track for your deadline';
      final df = DateFormat('d MMM');
      return 'On track — finishing around ${df.format(proj)}';
    }
    final n = plan.behind.length;
    return '$n subject${n == 1 ? '' : 's'} behind — tap a subject to raise its pace';
  }
}

/// A per-subject block on today's list, with tickable items.
class _TodaySubjectCard extends ConsumerWidget {
  const _TodaySubjectCard({required this.subject});
  final SubjectPlan subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = subject.category.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(subject.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                Text('${subject.todayDone}/${subject.dailyTarget}',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in subject.todayItems)
              _PlanItemRow(item: item, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _PlanItemRow extends ConsumerWidget {
  const _PlanItemRow({required this.item, required this.accent});
  final PlanItem item;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final done = item.doneToday;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () {
        final repo = ref.read(prepRepositoryProvider);
        repo.setLeafStatus(
          item.leaf.canon,
          done ? item.leaf.todoStatus : item.leaf.doneStatus,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: done ? AppPalette.success : theme.colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                item.leaf.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            if (!item.leaf.isConcept)
              Text(item.leaf.difficulty.label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: item.leaf.difficulty.color)),
          ],
        ),
      ),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppPalette.success, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              "You've hit today's targets across every subject. Nice work.",
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A subject's full stats card: progress, pace (planned vs required), projected
/// finish and on-track chip. Tapping opens the subject in the tracker.
class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({required this.subject});
  final SubjectPlan subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = subject.category.color;
    final df = DateFormat('d MMM');
    final onTrack = subject.onTrack;

    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SheetDetailScreen(sheetId: subject.sheetId))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(subject.category.icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(subject.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              _StatusChip(
                complete: subject.complete,
                onTrack: onTrack,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: subject.progress,
              minHeight: 7,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('${subject.done}/${subject.total} done',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.md),
          if (subject.complete)
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 16, color: AppPalette.success),
                const SizedBox(width: AppSpacing.sm),
                Text('Completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: AppPalette.success,
                        fontWeight: FontWeight.w600)),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _MetricPill(
                    label: 'Per day',
                    value: '${subject.dailyTarget}',
                    // In effort mode the target is sized by minutes, so a
                    // count-based "need N" would contradict it — show the time
                    // this actually costs instead.
                    hint: subject.isPaceCustom
                        ? 'custom'
                        : '~${PlanEffort.format(subject.todayMinutes)}',
                    accent: accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricPill(
                    label: 'Finish by',
                    value: subject.projectedFinish == null
                        ? '—'
                        : df.format(subject.projectedFinish!),
                    hint: _slackHint(subject),
                    accent: onTrack ? AppPalette.success : AppPalette.warning,
                  ),
                ),
              ],
            ),
          if (!subject.complete) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _editPace(context, ref, subject),
                icon: const Icon(Icons.speed_rounded, size: 18),
                label: Text(subject.isPaceCustom
                    ? 'Pace: ${subject.plannedPace}/day (custom)'
                    : 'Adjust daily pace'),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _slackHint(SubjectPlan s) {
    final slack = s.slackDays;
    if (slack == null) return 'never at this pace';
    if (slack <= 0) return '${-slack}d of buffer';
    return '$slack days late';
  }

  Future<void> _editPace(
      BuildContext context, WidgetRef ref, SubjectPlan s) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _PaceSheet(subject: s),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.complete, required this.onTrack});
  final bool complete;
  final bool onTrack;

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = complete
        ? (AppPalette.success, 'Done', Icons.check_rounded)
        : onTrack
            ? (AppPalette.success, 'On track', Icons.trending_up_rounded)
            : (AppPalette.warning, 'Behind', Icons.trending_down_rounded);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.hint,
    required this.accent,
  });
  final String label;
  final String value;
  final String hint;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: accent)),
          Text(hint,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Bottom sheet to set or clear a subject's daily pace.
class _PaceSheet extends ConsumerStatefulWidget {
  const _PaceSheet({required this.subject});
  final SubjectPlan subject;

  @override
  ConsumerState<_PaceSheet> createState() => _PaceSheetState();
}

class _PaceSheetState extends ConsumerState<_PaceSheet> {
  late int _pace = widget.subject.plannedPace < 1 ? 1 : widget.subject.plannedPace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = widget.subject;
    final df = DateFormat('d MMM yyyy');
    final projected = _pace > 0
        ? PlannerEngine.addDays(
            DateTime.now(), (s.left / _pace).ceil())
        : null;
    final onTime = projected != null && !projected.isAfter(s.deadline);

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl,
          AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily pace — ${s.title}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          Text('${s.left} items left • about '
              '${PlanEffort.format(s.minutesLeft)} of work',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _pace > 1 ? () => setState(() => _pace--) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: AppSpacing.xl),
              Column(
                children: [
                  Text('$_pace',
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text('per day', style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              IconButton.filledTonal(
                onPressed: () => setState(() => _pace++),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: (onTime ? AppPalette.success : AppPalette.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              projected == null
                  ? 'Set a pace of at least 1 per day.'
                  : onTime
                      ? 'Finishes around ${df.format(projected)} — on time.'
                      : 'Finishes around ${df.format(projected)} — after your deadline.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: onTime ? AppPalette.success : AppPalette.warning,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(plannerSettingsProvider.notifier)
                      .setPace(s.slug, _pace);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Set pace'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(plannerSettingsProvider.notifier)
                      .clearPace(s.slug);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Reset to auto (needed pace)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact Gantt-style timeline: a bar per subject from today to its projected
/// finish, with a marker for the deadline.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.plan});
  final PlanOverview plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = plan.today;
    // Span the axis from today to the furthest of the deadline / any projection.
    var end = plan.deadline;
    for (final s in plan.subjects) {
      final p = s.projectedFinish;
      if (p != null && p.isAfter(end)) end = p;
    }
    final spanDays = PlannerEngine.diffDays(today, end).clamp(1, 1 << 30);
    final deadlineFrac =
        (PlannerEngine.diffDays(today, plan.deadline) / spanDays)
            .clamp(0.0, 1.0)
            .toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in plan.subjects) ...[
            _TimelineRow(
              subject: s,
              today: today,
              spanDays: spanDays,
              deadlineFrac: deadlineFrac,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Container(width: 2, height: 14, color: theme.colorScheme.onSurface),
              const SizedBox(width: 6),
              Text('deadline',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.subject,
    required this.today,
    required this.spanDays,
    required this.deadlineFrac,
  });
  final SubjectPlan subject;
  final DateTime today;
  final int spanDays;
  final double deadlineFrac;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = subject.category.color;
    final proj = subject.projectedFinish;

    // Fraction of the axis (today→furthest) at which this subject finishes.
    // A completed subject or one that never finishes just fills the bar.
    final double fillFrac = subject.complete
        ? 1.0
        : proj == null
            ? 1.0
            : (PlannerEngine.diffDays(today, proj) / spanDays)
                .clamp(0.05, 1.0)
                .toDouble();

    final onTime = subject.onTrack;
    final barColor = subject.complete
        ? AppPalette.success
        : onTime
            ? accent
            : AppPalette.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subject.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track.
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  // Progress-to-finish bar.
                  Container(
                    width: w * fillFrac,
                    height: 14,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  // Deadline marker.
                  Positioned(
                    left: (w * deadlineFrac).clamp(0.0, w - 2),
                    top: -3,
                    bottom: -3,
                    child: Container(
                        width: 2, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
