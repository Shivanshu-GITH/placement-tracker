import '../../core/constants/enums.dart';

/// Weekday helpers for the timetable's day bitmask.
///
/// Bit 0 = Monday … bit 6 = Sunday, matching `DateTime.weekday` (1 = Monday)
/// minus one. Storing the repeat pattern as a single int keeps the schema
/// simple and makes "does this block run today?" a one-line check.
class Weekdays {
  const Weekdays._();

  static const int all = 127; // 1111111
  static const int weekdays = 31; // Mon–Fri
  static const int weekend = 96; // Sat+Sun

  static const List<String> shortLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  /// Bit index (0–6) for a `DateTime.weekday` value (1–7).
  static int indexOf(DateTime date) => date.weekday - 1;

  static bool runsOn(int mask, DateTime date) =>
      (mask & (1 << indexOf(date))) != 0;

  static bool hasDay(int mask, int dayIndex) => (mask & (1 << dayIndex)) != 0;

  static int toggle(int mask, int dayIndex) => mask ^ (1 << dayIndex);

  /// A compact human label: "Every day", "Mon–Fri", "Weekends", or a list.
  static String label(int mask) {
    if (mask == all) return 'Every day';
    if (mask == weekdays) return 'Mon–Fri';
    if (mask == weekend) return 'Weekends';
    if (mask == 0) return 'Never';
    return [
      for (var i = 0; i < 7; i++)
        if (hasDay(mask, i)) shortLabels[i],
    ].join(', ');
  }
}

/// Formats minutes-from-midnight as a 12-hour clock time ("7:30 AM").
String formatMinuteOfDay(int minuteOfDay) {
  final h24 = (minuteOfDay ~/ 60) % 24;
  final m = minuteOfDay % 60;
  final period = h24 < 12 ? 'AM' : 'PM';
  final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}

/// The category a block is tied to, or null for a free-form habit block.
PrepCategory? categoryFromName(String name) {
  if (name.isEmpty) return null;
  for (final c in PrepCategory.values) {
    if (c.name == name) return c;
  }
  return null;
}
