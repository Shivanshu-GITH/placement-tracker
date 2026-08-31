import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/day_key.dart';
import '../../core/utils/readiness.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/dtos.dart';
import '../../providers/providers.dart';
import 'widgets/heatmap_calendar.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final streak = ref.watch(streakProvider);
    final activity = ref.watch(activityProvider).valueOrNull ?? const [];
    final score = Readiness.score(stats, streak);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          _ReadinessCard(score: score, stats: stats).entrance(index: 0),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
                  title: 'Consistency', icon: Icons.local_fire_department_rounded)
              .entrance(index: 1),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniLabel('Current', '${streak.current}d'),
                    _MiniLabel('Longest', '${streak.longest}d'),
                    _MiniLabel(
                        'Active days',
                        '${activity.where((a) => a.problemsSolved > 0 || a.minutes > 0).length}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                HeatmapCalendar(activity: activity),
              ],
            ),
          ).entrance(index: 2),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
                  title: 'This week', icon: Icons.bar_chart_rounded)
              .entrance(index: 3),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: SizedBox(
                height: 180, child: _WeeklyBars(activity: activity)),
          ).entrance(index: 4),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
                  title: 'Strengths & gaps', icon: Icons.radar_rounded)
              .entrance(index: 5),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: SizedBox(
                height: 260, child: _CategoryRadar(byCategory: stats.byCategory)),
          ).entrance(index: 6),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
                  title: 'Difficulty mix', icon: Icons.donut_large_rounded)
              .entrance(index: 7),
          const SizedBox(height: AppSpacing.md),
          AppCard(child: _DifficultyDonut(stats: stats)).entrance(index: 8),
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.score, required this.stats});
  final int score;
  final PrepStats stats;

  @override
  Widget build(BuildContext context) {
    return GradientHeroCard(
      gradient: AppPalette.brandGradient,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Placement readiness',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(Readiness.label(score),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                Text('${stats.totalDone} of ${stats.totalItems} done',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ProgressRing(
            value: score / 100,
            size: 100,
            strokeWidth: 11,
            gradient:
                const LinearGradient(colors: [Colors.white, Color(0xFFD6F5EA)]),
            trackColor: Colors.white24,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const Text('/ 100',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.activity});
  final List<dynamic> activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byDay = {for (final a in activity) a.day as int: a.minutes as int};
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1)); // Monday

    final bars = <BarChartGroupData>[];
    var maxY = 60.0;
    for (var i = 0; i < 7; i++) {
      final d = DateTime(start.year, start.month, start.day + i);
      final mins = (byDay[DayKey.fromDate(d)] ?? 0).toDouble();
      if (mins > maxY) maxY = mins;
      bars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: mins,
          width: 18,
          borderRadius: BorderRadius.circular(6),
          gradient: AppPalette.brandGradient,
        ),
      ]));
    }

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 3).ceilToDouble().clamp(10, 1e6),
          getDrawingHorizontalLine: (v) => FlLine(
              color: theme.colorScheme.outlineVariant, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[value.toInt() % 7],
                    style: theme.textTheme.labelSmall),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${rod.toY.toInt()} min',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        barGroups: bars,
      ),
    );
  }
}

/// Short radar-axis labels so long category names (e.g. "Competitive Prog")
/// don't get clipped at the chart's edges.
String _radarShort(PrepCategory c) => switch (c) {
      PrepCategory.dsa => 'DSA',
      PrepCategory.core => 'Core',
      PrepCategory.aptitude => 'Apti',
      PrepCategory.system => 'Sys Des',
      PrepCategory.webdev => 'Web',
      PrepCategory.cp => 'CP',
      PrepCategory.interview => 'HR',
    };

class _CategoryRadar extends StatelessWidget {
  const _CategoryRadar({required this.byCategory});
  final List<CategoryProgress> byCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (byCategory.length < 3) {
      return Center(
        child: Text('Solve a few problems to see your strengths.',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
      );
    }
    final entries = byCategory
        .map((c) => RadarEntry(value: (c.progress * 100).clamp(2, 100)))
        .toList();

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          RadarDataSet(
            dataEntries: entries,
            fillColor: AppPalette.indigo.withValues(alpha: 0.25),
            borderColor: AppPalette.indigo,
            borderWidth: 2,
            entryRadius: 3,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        radarBorderData:
            BorderSide(color: theme.colorScheme.outlineVariant),
        gridBorderData:
            BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        tickBorderData:
            BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
        tickCount: 4,
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, angle) => RadarChartTitle(
          text: _radarShort(byCategory[index % byCategory.length].category),
        ),
        titleTextStyle: theme.textTheme.labelSmall,
      ),
    );
  }
}

class _DifficultyDonut extends StatelessWidget {
  const _DifficultyDonut({required this.stats});
  final PrepStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = [
      (Difficulty.easy, stats.doneByDifficulty[Difficulty.easy] ?? 0),
      (Difficulty.medium, stats.doneByDifficulty[Difficulty.medium] ?? 0),
      (Difficulty.hard, stats.doneByDifficulty[Difficulty.hard] ?? 0),
    ];
    final total = data.fold<int>(0, (s, e) => s + e.$2);

    if (total == 0) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text('No problems solved yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 38,
              sections: [
                for (final d in data)
                  if (d.$2 > 0)
                    PieChartSectionData(
                      value: d.$2.toDouble(),
                      color: d.$1.color,
                      title: '${d.$2}',
                      radius: 26,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final d in data)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: d.$1.color,
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 8),
                      Text(d.$1.label, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text('${d.$2}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
