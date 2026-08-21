import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _planEnsured = false;
  int _achSynced = -1;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final rows = ref.watch(activeLeafRowsProvider);
    final stats = ref.watch(statsProvider);
    final streak = ref.watch(streakProvider);
    final activity = ref.watch(activityProvider).valueOrNull ?? const [];
    final todayPlan = ref.watch(todayPlanProvider).valueOrNull ?? const [];

    // Ensure today's plan exists once data is ready (side-effect, run once).
    if (!_planEnsured && profile != null && rows.isNotEmpty) {
      _planEnsured = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(roadmapRepositoryProvider).ensureTodayPlan(profile, rows);
      });
    }

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
                      const SizedBox(height: AppSpacing.xl),
                      SectionHeader(
                        title: 'Today\'s plan',
                        subtitle: todayPlan.isEmpty
                            ? 'Building your schedule…'
                            : '${todayPlan.where((e) => e.done).length}/${todayPlan.length} done',
                        icon: Icons.today_rounded,
                      ).entrance(index: 3),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              _TodayPlanList(items: todayPlan),
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
        IconButton(
          tooltip: 'Analytics',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AnalyticsScreen())),
          icon: Icon(Icons.insights_rounded, color: theme.colorScheme.primary),
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

class _TodayPlanList extends ConsumerWidget {
  const _TodayPlanList({required this.items});
  final List<DailyPlanItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: AppCard(
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded),
                SizedBox(width: AppSpacing.md),
                Expanded(
                    child: Text(
                        'Your smart daily plan will appear here as you use the app.')),
              ],
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          final cat = PrepCategory.fromName(item.category);
          return AppCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            onTap: () => ref
                .read(roadmapRepositoryProvider)
                .toggleDailyItem(item.id, !item.done),
            child: Row(
              children: [
                _CheckDot(done: item.done, color: cat.color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          item.done ? TextDecoration.lineThrough : null,
                      color: item.done
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
                Text('${item.estimatedMinutes}m',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.done, required this.color});
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: done ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
            color: done ? color : Theme.of(context).colorScheme.outline,
            width: 2),
      ),
      child: done
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
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
                    Text(cp.category.label,
                        style: theme.textTheme.titleSmall),
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
