import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/day_key.dart';
import '../../../data/database/database.dart';

/// A GitHub-style contribution heatmap of study activity over the last N weeks.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({
    super.key,
    required this.activity,
    this.weeks = 18,
  });

  final List<ActivityDay> activity;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Map day-key -> intensity metric (problems solved).
    final map = {for (final a in activity) a.day: a.problemsSolved};
    final maxVal = map.values.isEmpty
        ? 1
        : map.values.reduce((a, b) => a > b ? a : b).clamp(1, 1000);

    // Build columns (weeks), each with 7 day cells ending today.
    final today = DateTime.now();
    // Align to the end of the current week (Sat) for a clean grid.
    final totalDays = weeks * 7;
    final start = today.subtract(Duration(days: totalDays - 1));

    final columns = <List<DateTime?>>[];
    var cursor = start;
    // Pad so the first column starts on Sunday.
    final leadPad = cursor.weekday % 7; // Sun=0
    var week = <DateTime?>[];
    for (var i = 0; i < leadPad; i++) {
      week.add(null);
    }
    for (var i = 0; i < totalDays; i++) {
      week.add(cursor);
      if (week.length == 7) {
        columns.add(week);
        week = <DateTime?>[];
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(null);
      }
      columns.add(week);
    }

    Color cellColor(int value) {
      if (value <= 0) return scheme.surfaceContainerHighest;
      final t = (value / maxVal).clamp(0.15, 1.0);
      return Color.lerp(
          AppPalette.mint.withValues(alpha: 0.35), AppPalette.mintDark, t)!;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final col in columns)
            Column(
              children: [
                for (final day in col)
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: day == null
                          ? Colors.transparent
                          : cellColor(map[DayKey.fromDate(day)] ?? 0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
