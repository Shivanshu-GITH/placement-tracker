import 'contest_models.dart';

/// The known recurring contest series, ported from the reference tracker's
/// schedule. Times are IST; the regularly-scheduled ones get concrete dates,
/// while the "varies" divisions are surfaced as links to check.
/// (Not `const` because the biweekly anchor is a runtime [DateTime].)
final List<ContestSeries> kContestSeries = [
  ContestSeries(
    key: 'lcw',
    platform: 'LeetCode',
    name: 'Weekly Contest',
    weekday: 0, // Sunday
    timeIst: '08:00',
    durationMins: 90,
    cadence: Cadence.weekly,
    url: 'https://leetcode.com/contest/',
    note: 'Sunday morning — the anchor weekly contest.',
  ),
  ContestSeries(
    key: 'lcb',
    platform: 'LeetCode',
    name: 'Biweekly Contest',
    weekday: 6, // Saturday
    timeIst: '20:00',
    durationMins: 90,
    cadence: Cadence.biweekly,
    anchor: _anchor,
    url: 'https://leetcode.com/contest/',
    note: 'Alternate Saturday evenings.',
  ),
  ContestSeries(
    key: 'ccs',
    platform: 'CodeChef',
    name: 'Starters',
    weekday: 3, // Wednesday
    timeIst: '20:00',
    durationMins: 120,
    cadence: Cadence.weekly,
    url: 'https://www.codechef.com/contests',
    note: 'Wednesday evening — rated for most divisions.',
  ),
  ContestSeries(
    key: 'cf4',
    platform: 'Codeforces',
    name: 'Div. 4',
    weekday: null,
    timeIst: '20:05',
    durationMins: 135,
    cadence: Cadence.varies,
    url: 'https://codeforces.com/contests',
    note: 'Easiest division — start here, move up once you clear 5+.',
  ),
  ContestSeries(
    key: 'cf3',
    platform: 'Codeforces',
    name: 'Div. 3',
    weekday: null,
    timeIst: '20:05',
    durationMins: 135,
    cadence: Cadence.varies,
    url: 'https://codeforces.com/contests',
    note: 'Roughly fortnightly — the best beginner rated contest.',
  ),
  ContestSeries(
    key: 'cf2',
    platform: 'Codeforces',
    name: 'Div. 2',
    weekday: null,
    timeIst: '20:05',
    durationMins: 120,
    cadence: Cadence.varies,
    url: 'https://codeforces.com/contests',
    note: 'Step up after Div. 3 feels comfortable.',
  ),
  ContestSeries(
    key: 'abc',
    platform: 'AtCoder',
    name: 'Beginner Contest (ABC)',
    weekday: 6, // Saturday
    timeIst: '17:30',
    durationMins: 100,
    cadence: Cadence.weekly,
    url: 'https://atcoder.jp/contests/',
    note: 'Most Saturday evenings — clean, math-flavoured problems.',
  ),
];

final DateTime _anchor = DateTime(2026, 8, 15); // a known LeetCode biweekly date

/// Computes concrete contest occurrences from the recurring [kContestSeries].
/// Pure and offline — a fixed weekly/biweekly schedule (times approximate, in
/// IST). "varies" series (Codeforces divisions) have no fixed date and are
/// returned by [irregularSeries] instead.
class ContestSchedule {
  const ContestSchedule._();

  static int _dartWeekday(int jsDay) => jsDay == 0 ? 7 : jsDay; // JS→Dart

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// All dated occurrences whose start falls within [days] from [now]
  /// (defaults to now), sorted ascending. IST wall-clock is used.
  static List<ContestOccurrence> upcoming({DateTime? now, int days = 7}) {
    final nowIst = _toIst(now ?? DateTime.now());
    final startDay = _dateOnly(nowIst);
    final out = <ContestOccurrence>[];
    for (var i = 0; i <= days; i++) {
      final day = startDay.add(Duration(days: i));
      for (final s in kContestSeries) {
        if (s.cadence == Cadence.varies || s.weekday == null) continue;
        if (day.weekday != _dartWeekday(s.weekday!)) continue;
        if (s.cadence == Cadence.biweekly && s.anchor != null) {
          final diff = _dateOnly(day).difference(_dateOnly(s.anchor!)).inDays;
          if (diff % 14 != 0) continue;
        }
        final start =
            DateTime(day.year, day.month, day.day, s.istHour, s.istMinute);
        // Only keep occurrences that haven't already ended.
        final end = start.add(Duration(minutes: s.durationMins));
        if (end.isBefore(nowIst)) continue;
        out.add(ContestOccurrence(
            series: s, startIst: start, durationMins: s.durationMins));
      }
    }
    out.sort((a, b) => a.startIst.compareTo(b.startIst));
    return out;
  }

  /// Occurrences that start today (IST).
  static List<ContestOccurrence> today({DateTime? now}) {
    final nowIst = _toIst(now ?? DateTime.now());
    final t = _dateOnly(nowIst);
    return upcoming(now: now, days: 1)
        .where((o) => _dateOnly(o.startIst) == t)
        .toList();
  }

  /// The irregular ("varies") series, for a "check the schedule" list.
  static List<ContestSeries> irregularSeries() =>
      kContestSeries.where((s) => s.cadence == Cadence.varies).toList();

  /// Converts any DateTime to a naive IST wall-clock DateTime (its fields are
  /// the IST values), so it compares consistently with the local DateTimes we
  /// build for occurrences.
  static DateTime _toIst(DateTime d) {
    final u = d.toUtc().add(const Duration(hours: 5, minutes: 30));
    return DateTime(u.year, u.month, u.day, u.hour, u.minute);
  }
}
