/// Utilities for the integer `yyyymmdd` day-key used by ActivityDays and
/// DailyPlanItems. Using an int key keeps day-grouped queries fast and avoids
/// timezone ambiguity from storing raw DateTimes.
class DayKey {
  DayKey._();

  static int fromDate(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static int today() => fromDate(DateTime.now());

  static DateTime toDate(int key) {
    final y = key ~/ 10000;
    final m = (key % 10000) ~/ 100;
    final d = key % 100;
    return DateTime(y, m, d);
  }

  /// Number of calendar days between two keys (b - a).
  static int diffDays(int a, int b) =>
      toDate(b).difference(toDate(a)).inDays;
}
