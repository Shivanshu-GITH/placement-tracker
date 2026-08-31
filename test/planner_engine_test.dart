import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/core/constants/enums.dart';
import 'package:preppilot/features/planner/planner_engine.dart';
import 'package:preppilot/features/planner/planner_models.dart';

/// Builds a subject with [total] leaves where the first [done] are completed.
/// [doneToday] of those completed leaves are marked as solved on [today].
SubjectInput subject(
  String slug, {
  required int total,
  int done = 0,
  int doneToday = 0,
  DateTime? today,
  PrepCategory category = PrepCategory.dsa,
}) {
  final leaves = <PlanLeaf>[];
  for (var i = 0; i < total; i++) {
    final isDone = i < done;
    // The last `doneToday` of the done items carry today's date.
    final solvedToday = isDone && i >= done - doneToday;
    leaves.add(PlanLeaf(
      canon: '$slug:$i',
      title: '$slug item $i',
      difficulty: Difficulty.medium,
      isConcept: false,
      isDone: isDone,
      solvedAt: isDone
          ? (solvedToday ? today : DateTime(2000, 1, 1))
          : null,
    ));
  }
  return SubjectInput(
    slug: slug,
    title: slug.toUpperCase(),
    category: category,
    sheetId: slug.hashCode,
    leaves: leaves,
  );
}

void main() {
  final start = DateTime(2026, 1, 1);
  final today = DateTime(2026, 1, 1);
  final deadline = DateTime(2026, 1, 11); // 10 days out

  group('required pace', () {
    test('is ceil(left / daysToDeadline)', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: start,
        deadline: deadline,
        now: today,
      );
      // 100 items over 10 days => 10/day.
      expect(p.subjects.single.requiredPace, 10);
    });

    test('counts only remaining items', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100, done: 50)],
        start: start,
        deadline: deadline,
        now: today,
      );
      // 50 left over 10 days => 5/day.
      expect(p.subjects.single.requiredPace, 5);
    });

    test('is the whole remainder when the deadline is today or past', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 30, done: 8)],
        start: start,
        deadline: today, // 0 days left
        now: today,
      );
      expect(p.subjects.single.requiredPace, 22);
      expect(p.daysToDeadline, 0);
    });

    test('a completed subject needs no pace and is on track', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 20, done: 20)],
        start: start,
        deadline: deadline,
        now: today,
      );
      final s = p.subjects.single;
      expect(s.requiredPace, 0);
      expect(s.complete, isTrue);
      expect(s.onTrack, isTrue);
      expect(s.dailyTarget, 0);
    });
  });

  group('daily target (catch-up)', () {
    test('auto pace: today target equals the pace needed from today', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: start,
        deadline: deadline,
        now: today, // start == today => 0 elapsed days
      );
      // Auto pace defaults to required (10); no spike.
      expect(p.subjects.single.dailyTarget, 10);
    });

    test('auto pace rises as days are missed rather than spiking today', () {
      // Nothing done after 3 idle days: with 17 of the 20 days left, the auto
      // pace smoothly rises to ceil(100/17)=6 and today's target is just that —
      // no extra catch-up dumped on one day.
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: DateTime(2026, 1, 1),
        deadline: DateTime(2026, 1, 21),
        now: DateTime(2026, 1, 4),
      );
      final s = p.subjects.single;
      expect(s.plannedPace, 6);
      expect(s.dailyTarget, 6);
    });

    test('custom pace: day one shows no carry-over', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: start,
        deadline: deadline,
        now: today, // start == today => 0 elapsed days
        plannedPaceFor: (_) => 5,
      );
      expect(p.subjects.single.dailyTarget, 5); // no deficit on day one
    });

    test('custom pace: adds the deficit for missed days, capped at one day', () {
      // Fixed pace 5, 3 idle days => 15 expected, 0 done => 15 deficit, but
      // catch-up is capped at one extra day (=5), so today's target is 10.
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: DateTime(2026, 1, 1),
        deadline: DateTime(2026, 1, 31),
        now: DateTime(2026, 1, 4), // 3 elapsed days
        plannedPaceFor: (_) => 5,
      );
      final s = p.subjects.single;
      expect(s.plannedPace, 5);
      expect(s.dailyTarget, 10); // 5 base + 5 catch-up (capped)
    });

    test('never exceeds what is left', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 6, done: 4)],
        start: DateTime(2026, 1, 1),
        deadline: DateTime(2026, 1, 3),
        now: DateTime(2026, 1, 2),
      );
      expect(p.subjects.single.dailyTarget, 2); // only 2 remain
    });
  });

  group('planned pace override', () {
    test('a user override drives target and projection', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: start,
        deadline: deadline,
        now: today,
        plannedPaceFor: (slug) => slug == 'dsa' ? 4 : null,
      );
      final s = p.subjects.single;
      expect(s.plannedPace, 4);
      expect(s.isPaceCustom, isTrue);
      // 100 / 4 = 25 days => finishes 2026-01-26, well past the 10-day deadline.
      expect(s.projectedFinish, DateTime(2026, 1, 26));
      expect(s.onTrack, isFalse); // 4/day is too slow for the deadline
      // Required pace is still reported so the UI can warn.
      expect(s.requiredPace, 10);
    });
  });

  group('projection and on-track', () {
    test('on track when projected finish is on or before the deadline', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: start,
        deadline: deadline,
        now: today,
      );
      final s = p.subjects.single;
      // Auto pace (10/day) finishes exactly on the deadline.
      expect(s.projectedFinish, DateTime(2026, 1, 11));
      expect(s.onTrack, isTrue);
      expect(s.slackDays, 0);
    });

    test('overall on-track requires every subject on track', () {
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 100),
          subject('os', total: 100, category: PrepCategory.core),
        ],
        start: start,
        deadline: deadline,
        now: today,
        // Slow one subject below its required pace.
        plannedPaceFor: (slug) => slug == 'os' ? 2 : null,
      );
      expect(p.onTrack, isFalse);
      expect(p.behind.map((s) => s.slug), ['os']);
    });

    test('whole-plan projected finish is the last subject to finish', () {
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 20), // required 2/day => finishes 2026-01-11
          subject('os', total: 100, category: PrepCategory.core),
        ],
        start: start,
        deadline: deadline,
        now: today,
        plannedPaceFor: (slug) => slug == 'dsa' ? 2 : null,
      );
      // dsa: 20/2 = 10 days -> Jan 11; os auto pace 10/day -> Jan 11 too.
      expect(p.projectedFinish, DateTime(2026, 1, 11));
    });
  });

  group("today's list", () {
    test('offers the next unsolved items up to the target', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100, done: 30)],
        start: start,
        deadline: deadline,
        now: today,
      );
      final s = p.subjects.single;
      // 70 left over 10 days => 7/day, none done today => 7 fresh items.
      expect(s.dailyTarget, 7);
      expect(s.todayItems.length, 7);
      expect(s.todayItems.every((i) => !i.doneToday), isTrue);
      // They start right after the last completed item.
      expect(s.todayItems.first.leaf.canon, 'dsa:30');
    });

    test('keeps items finished today visible and counts them toward the target',
        () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100, done: 30, doneToday: 3, today: today)],
        start: start,
        deadline: deadline,
        now: today,
      );
      final s = p.subjects.single;
      expect(s.dailyTarget, 7);
      expect(s.doneTodayCount, 3);
      // 3 shown as done today + 4 fresh = 7 total on the list.
      final doneShown = s.todayItems.where((i) => i.doneToday).length;
      final fresh = s.todayItems.where((i) => !i.doneToday).length;
      expect(doneShown, 3);
      expect(fresh, 4);
      expect(s.todayItems.length, 7);
    });
  });

  group('overview rollups', () {
    test('sums totals and today targets across subjects', () {
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 100, done: 30),
          subject('os', total: 50, done: 10, category: PrepCategory.core),
        ],
        start: start,
        deadline: deadline,
        now: today,
      );
      expect(p.total, 150);
      expect(p.done, 40);
      expect(p.left, 110);
      // dsa 7/day + os ceil(40/10)=4/day.
      expect(p.todayTarget, 11);
      expect(p.categories.length, 2);
    });
  });
}
