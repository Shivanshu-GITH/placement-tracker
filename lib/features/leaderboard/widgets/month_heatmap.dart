import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_palette.dart';

/// A GitHub-style contribution heatmap from a {"YYYY-MM-DD": count} map.
/// Shows the last [weeks] weeks as columns (7 rows = days), with month labels.
class MonthHeatmap extends StatelessWidget {
  const MonthHeatmap({super.key, required this.daily, this.weeks = 53});
  final Map<String, int> daily;
  final int weeks;

  static const _cell = 13.0;
  static const _gap = 3.0;
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Column 0 starts on the Sunday on/just before (today - weeks*7).
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: (weeks - 1) * 7 + today.weekday % 7));

    int maxCount = 1;
    for (final v in daily.values) {
      if (v > maxCount) maxCount = v;
    }

    Color colorFor(int c) {
      if (c <= 0) return theme.colorScheme.surfaceContainerHighest;
      final t = (c / maxCount).clamp(0.15, 1.0);
      return Color.lerp(
          AppPalette.mint.withValues(alpha: 0.35), AppPalette.success, t)!;
    }

    // Build columns.
    final columns = <Widget>[];
    final monthLabels = <Widget>[];
    var lastMonth = -1;
    for (var w = 0; w < weeks; w++) {
      final colDays = <Widget>[];
      final colStart = start.add(Duration(days: w * 7));
      for (var d = 0; d < 7; d++) {
        final day = colStart.add(Duration(days: d));
        final future = day.isAfter(today);
        final count = daily[_key(day)] ?? 0;
        colDays.add(Container(
          width: _cell,
          height: _cell,
          margin: const EdgeInsets.all(_gap / 2),
          decoration: BoxDecoration(
            color: future ? Colors.transparent : colorFor(count),
            borderRadius: BorderRadius.circular(3),
          ),
        ));
      }
      columns.add(Column(children: colDays));
      // Month label when the first day of this column crosses into a new month.
      final m = colStart.month;
      if (m != lastMonth) {
        lastMonth = m;
        monthLabels.add(SizedBox(
          width: _cell + _gap,
          child: Text(_months[m - 1],
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
        ));
      } else {
        monthLabels.add(SizedBox(width: _cell + _gap));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // show most-recent weeks first
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: monthLabels),
          const SizedBox(height: 2),
          Row(children: columns),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Less',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 4),
              for (final c in [0, 1, 2, 3, 4])
                Container(
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: colorFor(c == 0 ? 0 : (maxCount * c / 4).round()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 4),
              Text('More',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
