import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/features/contests/contest_models.dart';
import 'package:preppilot/features/contests/contest_schedule.dart';

// Helper: build a UTC instant that represents the given IST wall-clock time,
// so the schedule engine (which converts device time → IST) sees exactly it.
DateTime istNow(int y, int mo, int d, int h, int mi) =>
    DateTime.utc(y, mo, d, h, mi).subtract(const Duration(hours: 5, minutes: 30));

void main() {
  group('today()', () {
    test('lists CodeChef Starters on a Wednesday morning', () {
      final t = ContestSchedule.today(now: istNow(2026, 8, 19, 6, 0)); // Wed
      expect(t.any((o) => o.platform == 'CodeChef' && o.startIst.hour == 20),
          isTrue);
    });

    test('lists LeetCode Weekly on a Sunday morning', () {
      final t = ContestSchedule.today(now: istNow(2026, 8, 16, 6, 0)); // Sun
      expect(
          t.any((o) => o.platform == 'LeetCode' && o.name.contains('Weekly')),
          isTrue);
    });

    test('excludes a contest that has already ended today', () {
      // Wed 22:30 IST — CodeChef (20:00 + 120m = 22:00) is over.
      final t = ContestSchedule.today(now: istNow(2026, 8, 19, 22, 30));
      expect(t.any((o) => o.platform == 'CodeChef'), isFalse);
    });
  });

  group('biweekly phasing', () {
    test('LeetCode Biweekly falls on the anchor + 14 days, not + 7', () {
      final list =
          ContestSchedule.upcoming(now: istNow(2026, 8, 16, 6, 0), days: 20);
      final biweeklies = list
          .where((o) => o.platform == 'LeetCode' && o.name.contains('Biweekly'))
          .map((o) => o.startIst)
          .toList();
      // Aug 29 (anchor 15 + 14) is in range; Aug 22 (anchor + 7) is not.
      expect(biweeklies.any((d) => d.month == 8 && d.day == 29), isTrue);
      expect(biweeklies.any((d) => d.month == 8 && d.day == 22), isFalse);
    });
  });

  group('upcoming()', () {
    test('is sorted ascending by start time', () {
      final list =
          ContestSchedule.upcoming(now: istNow(2026, 8, 16, 6, 0), days: 14);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].startIst.isBefore(list[i - 1].startIst), isFalse);
      }
    });

    test('startUtc is the IST wall-clock minus 5:30', () {
      final list = ContestSchedule.upcoming(now: istNow(2026, 8, 16, 6, 0), days: 1);
      final o = list.firstWhere((o) => o.name.contains('Weekly'));
      // Sun 08:00 IST => 02:30 UTC.
      expect(o.startUtc, DateTime.utc(2026, 8, 16, 2, 30));
    });
  });

  test('irregularSeries returns the Codeforces divisions', () {
    final v = ContestSchedule.irregularSeries();
    expect(v.every((s) => s.cadence == Cadence.varies), isTrue);
    expect(v.any((s) => s.platform == 'Codeforces' && s.name == 'Div. 3'), isTrue);
  });
}
