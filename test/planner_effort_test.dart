import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/core/constants/enums.dart';
import 'package:preppilot/features/planner/planner_effort.dart';
import 'package:preppilot/features/planner/planner_engine.dart';
import 'package:preppilot/features/planner/planner_models.dart';

/// Builds a subject of [total] identical leaves, the first [done] completed.
SubjectInput subject(
  String slug, {
  required int total,
  int done = 0,
  bool isConcept = false,
  Difficulty difficulty = Difficulty.medium,
  PrepCategory category = PrepCategory.dsa,
  int doneToday = 0,
  DateTime? today,
}) {
  final leaves = <PlanLeaf>[];
  for (var i = 0; i < total; i++) {
    final isDone = i < done;
    final solvedToday = isDone && i >= done - doneToday;
    leaves.add(PlanLeaf(
      canon: '$slug:$i',
      title: '$slug item $i',
      difficulty: difficulty,
      isConcept: isConcept,
      isDone: isDone,
      solvedAt: isDone ? (solvedToday ? today : DateTime(2000)) : null,
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

  group('effort model', () {
    test('costs concepts and problems by difficulty', () {
      expect(
          PlanEffort.forLeaf(isConcept: true, difficulty: Difficulty.hard), 8);
      expect(
          PlanEffort.forLeaf(isConcept: false, difficulty: Difficulty.easy), 15);
      expect(PlanEffort.forLeaf(isConcept: false, difficulty: Difficulty.medium),
          25);
      expect(
          PlanEffort.forLeaf(isConcept: false, difficulty: Difficulty.hard), 40);
    });

    test('a subject reports the minutes of work it has left', () {
      // 10 medium problems, 4 already done => 6 * 25 = 150 min left.
      final s = subject('dsa', total: 10, done: 4);
      expect(s.minutesLeft, 150);
    });

    test('formats minutes the way the UI shows them', () {
      expect(PlanEffort.format(45), '45 min');
      expect(PlanEffort.format(60), '1h');
      expect(PlanEffort.format(150), '2h 30m');
    });
  });

  group('effort-based daily target', () {
    test('asks only for what the deadline needs when capacity is ample', () {
      // 10 medium problems = 250 min over 10 days => 25 min/day, and the user
      // has 120. The day's ask should be the 25 min the deadline needs (1 item),
      // not everything that would fit in two hours.
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 10)],
        start: start,
        deadline: DateTime(2026, 1, 11),
        now: today,
        dailyMinutes: 120,
      );
      expect(p.requiredMinutesPerDay, 25);
      expect(p.todayBudgetMinutes, 25);
      expect(p.subjects.single.dailyTarget, 1);
      expect(p.feasible, isTrue);
      expect(p.onTrack, isTrue);
    });

    test('caps the day at the user\'s capacity when the deadline is tight', () {
      // 250 min of work but only 2 days => needs 125 min/day, user has 120.
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 10)],
        start: start,
        deadline: DateTime(2026, 1, 3),
        now: today,
        dailyMinutes: 120,
      );
      expect(p.requiredMinutesPerDay, 125);
      expect(p.feasible, isFalse); // honest: 2 days is not enough
      expect(p.todayBudgetMinutes, 120); // never asks for more than they have
      // Four 25-min problems fit in 120 min; a fifth would not.
      expect(p.subjects.single.dailyTarget, 4);
    });

    test('never promises more minutes than the budget allows', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 40, difficulty: Difficulty.hard)],
        start: start,
        deadline: DateTime(2026, 1, 31),
        now: today,
        dailyMinutes: 120,
      );
      expect(p.todayMinutes, lessThanOrEqualTo(p.todayBudgetMinutes));
    });
  });

  group('splitting the day across subjects', () {
    test('gives each subject a share proportional to the work it has left', () {
      // DSA: 10 hard = 400 min. Aptitude: 10 concepts = 80 min. Total 480 over
      // 8 days => 60 min/day. DSA should get ~5/6 of that, aptitude ~1/6.
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 10, difficulty: Difficulty.hard),
          subject('apt',
              total: 10, isConcept: true, category: PrepCategory.aptitude),
        ],
        start: start,
        deadline: DateTime(2026, 1, 9),
        now: today,
        dailyMinutes: 120,
      );
      expect(p.requiredMinutesPerDay, 60);
      final dsa = p.subjects.firstWhere((s) => s.slug == 'dsa');
      final apt = p.subjects.firstWhere((s) => s.slug == 'apt');
      // Both subjects advance every day — neither is starved.
      expect(dsa.dailyTarget, greaterThan(0));
      expect(apt.dailyTarget, greaterThan(0));
      // DSA carries far more work, so it gets the larger slice of minutes.
      expect(dsa.todayMinutes, greaterThan(apt.todayMinutes));
    });

    test('a subject whose next item is bigger than its slice still advances',
        () {
      // Aptitude dwarfs DSA in item count, so DSA's proportional slice is tiny —
      // but it must not stall at zero forever.
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 2, difficulty: Difficulty.hard),
          subject('apt',
              total: 400, isConcept: true, category: PrepCategory.aptitude),
        ],
        start: start,
        deadline: DateTime(2026, 6, 1),
        now: today,
        dailyMinutes: 60,
      );
      expect(p.subjects.firstWhere((s) => s.slug == 'dsa').dailyTarget,
          greaterThanOrEqualTo(1));
    });

    test('every incomplete subject still gets work with many subjects and a '
        'small budget', () {
      // The realistic shape of a real plan: one huge DSA sheet plus nine small
      // theory subjects, on a modest daily budget. No subject may be dropped.
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 455, difficulty: Difficulty.medium),
          for (var i = 0; i < 9; i++)
            subject('sub$i',
                total: 60, isConcept: true, category: PrepCategory.core),
        ],
        start: start,
        deadline: DateTime(2026, 4, 1),
        now: today,
        dailyMinutes: 120,
      );
      for (final s in p.subjects) {
        expect(s.dailyTarget, greaterThanOrEqualTo(1),
            reason: '${s.slug} was starved');
      }
    });

    test('subjects finish together rather than one starving the others', () {
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 20),
          subject('os',
              total: 40, isConcept: true, category: PrepCategory.core),
        ],
        start: start,
        deadline: DateTime(2026, 3, 1),
        now: today,
        dailyMinutes: 120,
      );
      final finishes =
          p.subjects.map((s) => s.projectedFinish).toSet();
      expect(finishes.length, 1); // same projected finish for both
    });
  });

  group('feasibility and re-planning', () {
    test('flags an impossible plan and suggests a deadline that works', () {
      // 100 hard problems = 4000 min. 10 days at 2h/day = 1200 min. Impossible.
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100, difficulty: Difficulty.hard)],
        start: start,
        deadline: DateTime(2026, 1, 11),
        now: today,
        dailyMinutes: 120,
      );
      expect(p.feasible, isFalse);
      expect(p.minutesLeft, 4000);
      // 4000 / 120 = 33.3 => 34 days of work at full capacity.
      expect(p.daysAtCapacity, 34);
      expect(p.suggestedDeadline, DateTime(2026, 2, 4));
      expect(p.onTrack, isFalse);
    });

    test('a reachable plan is feasible and needs no new deadline', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 10)],
        start: start,
        deadline: DateTime(2026, 2, 1),
        now: today,
        dailyMinutes: 120,
      );
      expect(p.feasible, isTrue);
      expect(p.onTrack, isTrue);
    });

    test('adding a new subject re-plans automatically', () {
      // Same deadline and capacity, but a second subject appears: the day's
      // required minutes rise and the new subject immediately gets work.
      final before = PlannerEngine.compute(
        subjects: [subject('dsa', total: 10)],
        start: start,
        deadline: DateTime(2026, 2, 1),
        now: today,
        dailyMinutes: 120,
      );
      final after = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 10),
          subject('web',
              total: 100, isConcept: true, category: PrepCategory.webdev),
        ],
        start: start,
        deadline: DateTime(2026, 2, 1),
        now: today,
        dailyMinutes: 120,
      );
      expect(after.requiredMinutesPerDay,
          greaterThan(before.requiredMinutesPerDay));
      expect(after.subjects.firstWhere((s) => s.slug == 'web').dailyTarget,
          greaterThan(0));
    });

    test('finished subjects stop consuming the day\'s budget', () {
      final p = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 10, done: 10),
          subject('os', total: 20, isConcept: true, category: PrepCategory.core),
        ],
        start: start,
        deadline: DateTime(2026, 2, 1),
        now: today,
        dailyMinutes: 120,
      );
      final dsa = p.subjects.firstWhere((s) => s.slug == 'dsa');
      expect(dsa.dailyTarget, 0);
      expect(dsa.minutesLeft, 0);
      // The remaining subject carries the whole plan.
      expect(p.minutesLeft, 160);
    });
  });

  group('work already done today', () {
    test('counts toward the day and shrinks what is still asked for', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 20, done: 4, doneToday: 4, today: today)],
        start: start,
        deadline: DateTime(2026, 1, 11),
        now: today,
        dailyMinutes: 120,
      );
      final s = p.subjects.single;
      expect(s.doneTodayCount, 4);
      // Those 4 (100 min) already cover the day's budget, so nothing new is
      // pushed and the day reads as complete.
      expect(s.todayMinutes, 0);
      expect(s.todayDone, s.dailyTarget);
    });
  });

  group('backwards compatibility', () {
    test('without a time budget the engine stays purely count-based', () {
      final p = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100)],
        start: start,
        deadline: DateTime(2026, 1, 11),
        now: today,
      );
      expect(p.capacityMinutes, 0);
      expect(p.feasible, isTrue); // nothing to judge against
      expect(p.subjects.single.dailyTarget, 10); // 100 items / 10 days
    });
  });
}
