import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_palette.dart';
import '../leaderboard_models.dart';

const _platformColors = {
  'leetcode': Color(0xFFFFA116),
  'codeforces': Color(0xFF1F8ACB),
  'atcoder': Color(0xFF9AA0A6),
  'codechef': Color(0xFF7B5E3B),
};

/// Rating-over-time line chart, one line per platform with contest ratings.
class ContestRatingGraph extends StatelessWidget {
  const ContestRatingGraph({super.key, required this.contests});
  final List<ContestEntry> contests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Group rated contests by platform, ordered by date.
    final byPlatform = <String, List<ContestEntry>>{};
    for (final c in contests) {
      if (c.rating == null) continue;
      byPlatform.putIfAbsent(c.platform, () => []).add(c);
    }
    for (final list in byPlatform.values) {
      list.sort((a, b) =>
          (a.heldAt ?? DateTime(0)).compareTo(b.heldAt ?? DateTime(0)));
    }
    if (byPlatform.isEmpty) {
      return const SizedBox.shrink();
    }

    double minY = double.infinity, maxY = -double.infinity;
    final bars = <LineChartBarData>[];
    for (final entry in byPlatform.entries) {
      final spots = <FlSpot>[];
      for (var i = 0; i < entry.value.length; i++) {
        final r = entry.value[i].rating!.toDouble();
        spots.add(FlSpot(i.toDouble(), r));
        if (r < minY) minY = r;
        if (r > maxY) maxY = r;
      }
      final color = _platformColors[entry.key] ?? AppPalette.indigo;
      bars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        barWidth: 2.5,
        color: color,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
            show: true, color: color.withValues(alpha: 0.10)),
      ));
    }
    if (minY == double.infinity) return const SizedBox.shrink();
    final pad = ((maxY - minY) * 0.15).clamp(50, 500);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 170,
          child: LineChart(LineChartData(
            minY: minY - pad,
            maxY: maxY + pad,
            lineBarsData: bars,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: ((maxY - minY + 2 * pad) / 3).ceilToDouble(),
              getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: (v, meta) => Text('${v.toInt()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
          )),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          children: [
            for (final p in byPlatform.keys)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: _platformColors[p] ?? AppPalette.indigo,
                        shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                    ContestEntry(platform: p, contest: '').platformLabel,
                    style: theme.textTheme.labelSmall),
              ]),
          ],
        ),
      ],
    );
  }
}

/// Horizontal-bar breakdown of GitHub languages by repo count.
class LanguagesChart extends StatelessWidget {
  const LanguagesChart({super.key, required this.languages});
  final Map<String, int> languages;

  static const _palette = [
    AppPalette.indigo, AppPalette.mint, AppPalette.violet, AppPalette.info,
    AppPalette.warning, AppPalette.catAptitude, AppPalette.catInterview,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (languages.isEmpty) return const SizedBox.shrink();
    final entries = languages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    final total = top.fold<int>(0, (s, e) => s + e.value);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stacked proportion bar.
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Row(
            children: [
              for (var i = 0; i < top.length; i++)
                Expanded(
                  flex: top[i].value,
                  child: Container(
                      height: 10, color: _palette[i % _palette.length]),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < top.length; i++)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: _palette[i % _palette.length],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 5),
                Text(
                    '${top[i].key}  ${(top[i].value / total * 100).round()}%',
                    style: theme.textTheme.labelSmall),
              ]),
          ],
        ),
      ],
    );
  }
}
