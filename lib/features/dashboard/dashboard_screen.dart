import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/day_key.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/section_header.dart';
import '../../data/database/database.dart';
import '../../data/models/dtos.dart';
import '../../providers/providers.dart';
import '../achievements/achievements.dart';
import '../analytics/analytics_screen.dart';
import '../contests/contests_screen.dart';
import '../planner/planner_models.dart';
import '../tracker/sheet_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _achSynced = -1;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final stats = ref.watch(statsProvider);
    final streak = ref.watch(streakProvider);
    final activity = ref.watch(activityProvider).valueOrNull ?? const [];
    // Today's plan comes live from the deadline engine — one flat list of
    // targeted items across every subject, paired with its subject.
    final plan = ref.watch(plannerOverviewProvider);
    final todayEntries = <(SubjectPlan, PlanItem)>[
      for (final s in plan.subjects)
        for (final it in s.todayItems) (s, it),
    ];

    // Unlock + celebrate achievements when the earned set grows.
    final achStats = ref.watch(achStatsProvider);
    final earnedKeys = {
      for (final a in kAchievements)
        if (a.earned(achStats)) a.key
    };
    if (_achSynced != earnedKeys.length) {
      _achSynced = earnedKeys.length;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final newly =
            await ref.read(prepRepositoryProvider).syncAchievements(earnedKeys);
        if (newly.isNotEmpty && context.mounted) {
          final a = kAchievements.firstWhere((x) => x.key == newly.first);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🏆 Achievement unlocked: ${a.title}')),
          );
        }
      });
    }

    final today = activity
        .where((a) => a.day == DayKey.today())
        .fold<ActivityDay?>(null, (p, e) => e);
    final solvedToday = today?.problemsSolved ?? 0;
    final goalProblems = profile?.dailyGoalProblems ?? 4;
    final dailyProgress =
        goalProblems == 0 ? 0.0 : (solvedToday / goalProblems).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(activityProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                      AppSpacing.lg, AppSpacing.screenH, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Greeting(name: profile?.name ?? 'there', streak: streak)
                          .entrance(index: 0),
                      const SizedBox(height: AppSpacing.lg),
                      _TodayFocusCard(
                        progress: dailyProgress.toDouble(),
                        solved: solvedToday,
                        goal: goalProblems,
                        minutesToday: today?.minutes ?? 0,
                      ).entrance(index: 1),
                      const SizedBox(height: AppSpacing.lg),
                      _StatRow(stats: stats, streak: streak).entrance(index: 2),
                      const SizedBox(height: AppSpacing.md),
                      _AnalyticsCard(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AnalyticsScreen())),
                      ).entrance(index: 3),
                      const SizedBox(height: AppSpacing.xl),
                      SectionHeader(
                        title: 'Today\'s plan',
                        subtitle: plan.todayTarget == 0
                            ? 'All caught up for today'
                            : '${plan.todayDone}/${plan.todayTarget} done',
                        icon: Icons.today_rounded,
                      ).entrance(index: 3),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              _TodayPlanList(entries: todayEntries),
              const SliverToBoxAdapter(child: _ContestsCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                      AppSpacing.xl, AppSpacing.screenH, 0),
                  child: SectionHeader(
                    title: 'Category progress',
                    icon: Icons.category_rounded,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                      AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
                  child: Column(
                    children: [
                      for (final cp in stats.byCategory)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _CategoryProgressCard(cp: cp),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashboard card for contests — shown only when the user has opted into
/// contest prep. Surfaces today's contest (or the next upcoming one) and links
/// to the full Contests screen.
class _ContestsCard extends ConsumerWidget {
  const _ContestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(contestPrepProvider)) return const SizedBox.shrink();
    final today = ref.watch(todaysContestsProvider);
    final upcoming = ref.watch(upcomingContestsProvider);
    final next = today.isNotEmpty
        ? today.first
        : (upcoming.isNotEmpty ? upcoming.first : null);
    if (next == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isToday = today.isNotEmpty;
    final when = isToday
        ? 'Today · ${TimeOfDay.fromDateTime(next.startIst).format(context)} IST'
        : '${_weekday(next.startIst)} · ${TimeOfDay.fromDateTime(next.startIst).format(context)} IST';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.xl, AppSpacing.screenH, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Contests',
            subtitle: isToday ? 'A contest is scheduled today' : 'Coming up',
            icon: Icons.emoji_events_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            borderColor: isToday ? AppPalette.catCp : null,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ContestsScreen())),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppPalette.catCp.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppPalette.catCp),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${next.platform} · ${next.name}',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(when,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.streak});
  final String name;
  final StreakInfo streak;

  String get _timeGreeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_timeGreeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              Text('$name 👋', style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
        _StreakChip(days: streak.current),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = days > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: active ? AppPalette.sunsetGradient : null,
        color: active ? null : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_rounded,
              size: 18,
              color: active ? Colors.white : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text('$days',
              style: theme.textTheme.titleSmall?.copyWith(
                  color: active ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _TodayFocusCard extends StatelessWidget {
  const _TodayFocusCard({
    required this.progress,
    required this.solved,
    required this.goal,
    required this.minutesToday,
  });
  final double progress;
  final int solved;
  final int goal;
  final int minutesToday;

  @override
  Widget build(BuildContext context) {
    final done = progress >= 1;
    return GradientHeroCard(
      gradient: AppPalette.brandGradient,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done ? 'Daily goal smashed! 🎉' : 'Today\'s goal',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  done ? 'You\'re on a roll' : 'Solve $goal problems',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text('$minutesToday min today',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          ProgressRing(
            value: progress,
            size: 96,
            strokeWidth: 10,
            gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFD6F5EA)]),
            trackColor: Colors.white24,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$solved/$goal',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const Text('solved',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stats, required this.streak});
  final PrepStats stats;
  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.check_circle_rounded,
            color: AppPalette.success,
            value: stats.totalDone,
            label: 'Solved',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MiniStat(
            icon: Icons.local_fire_department_rounded,
            color: AppPalette.warning,
            value: streak.current,
            label: 'Day streak',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MiniStat(
            icon: Icons.refresh_rounded,
            color: AppPalette.info,
            value: stats.needsRevisit,
            label: 'To revisit',
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          AnimatedCounter(
            value: value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppPalette.indigo.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.insights_rounded, color: AppPalette.indigo),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analytics',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('Trends, activity heatmap & category insights',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// Today's target pool, rendered exactly like the tracker: each topic is a full
/// [LeafTile] (tap the status ring to tick/untick, tap the row to open the same
/// detail sheet with notes, quiz, links, status and personal notes). Grouped by
/// subject so the pool stays organised.
class _TodayPlanList extends ConsumerWidget {
  const _TodayPlanList({required this.entries});

  /// Each of today's targeted items paired with the subject it belongs to.
  final List<(SubjectPlan, PlanItem)> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: AppCard(
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppPalette.success),
                SizedBox(width: AppSpacing.md),
                Expanded(
                    child: Text(
                        "You're all caught up. Adjust your targets in the Planner tab.")),
              ],
            ),
          ),
        ),
      );
    }

    // Resolve each planned item to its leaf row, preferring the row from the
    // item's own subject sheet so the tile opens with the right context.
    final byCanon = <String, List<LeafRow>>{};
    for (final r in ref.watch(leafRowsProvider)) {
      (byCanon[r.canon] ??= []).add(r);
    }
    LeafRow? rowFor(SubjectPlan s, PlanItem it) {
      final list = byCanon[it.leaf.canon];
      if (list == null || list.isEmpty) return null;
      for (final r in list) {
        if (r.sheet.id == s.sheetId) return r;
      }
      return list.first;
    }

    final children = <Widget>[];
    String? currentSlug;
    for (final (subject, item) in entries) {
      final row = rowFor(subject, item);
      if (row == null) continue;
      if (currentSlug != subject.slug) {
        currentSlug = subject.slug;
        children.add(Padding(
          padding: EdgeInsets.only(
              top: children.isEmpty ? 0 : AppSpacing.lg,
              bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(subject.category.icon,
                  size: 15, color: subject.category.color),
              const SizedBox(width: 6),
              Text(subject.title,
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ));
      }
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: LeafTile(row: row),
      ));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      sliver: SliverList.list(children: children),
    );
  }
}

class _CategoryProgressCard extends StatelessWidget {
  const _CategoryProgressCard({required this.cp});
  final CategoryProgress cp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cp.category.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(cp.category.icon, color: cp.category.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(cp.category.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${cp.done}/${cp.total}',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: cp.progress),
                    duration: AppMotion.slow,
                    curve: AppMotion.emphasized,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 7,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation(cp.category.color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
