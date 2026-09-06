import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/core/constants/enums.dart';
import 'package:preppilot/features/planner/planner_effort.dart';
import 'package:preppilot/features/planner/planner_engine.dart';
import 'package:preppilot/features/planner/planner_models.dart';

/// Effort-based ("time-aware") planning — the mode the app ALWAYS runs in,
/// since plannerOverviewProvider always passes the profile's daily budget. It
/// had no coverage at all, which is how a subject card came to print three
/// numbers computed from three unrelated models: a pace from the count needed
/// to hit the deadline, a daily target from a share of the minutes budget, and
/// a finish date from the aggregate time all auto subjects needed together.
/// "1 per day, 50 left, finishes in six months" was self-contradictory, yet
/// each part was individually defensible.
///
/// The invariant these tests pin down: for every subject, at the pace the card
/// reports, the items it has left take exactly as long as its projected finish
/// claims.
SubjectInput subject(
  String slug, {
  required int total,
  int done = 0,
  bool concepts = false,
  Difficulty difficulty = Difficulty.medium,
}) {
  return SubjectInput(
    slug: slug,
    title: slug.toUpperCase(),
    category: PrepCategory.dsa,
    sheetId: slug.hashCode,
    leaves: [
      for (var i = 0; i < total; i++)
        PlanLeaf(
          canon: '$slug:$i',
          title: '$slug item $i',
          difficulty: difficulty,
          isConcept: concepts,
          isDone: i < done,
          solvedAt: i < done ? DateTime(2000) : null,
        ),
    ],
  );
}

void main() {
  final start = DateTime(2026, 1, 1);
  final today = DateTime(2026, 1, 1);
  final deadline = DateTime(2026, 7, 1); // 181 days out

  /// Days from today to a subject's projected finish.
  int projectedDays(SubjectPlan s) =>
      PlannerEngine.diffDays(today, s.projectedFinish!);

  group('a subject card reconciles with itself', () {
    test('projected finish is exactly ceil(left / pace) days away', () {
      final plan = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 455),
          subject('oop', total: 50, concepts: true),
          subject('sysd', total: 59, concepts: true),
        ],
        start: start,
        deadline: deadline,
        now: today,
        dailyMinutes: 120,
      );

      for (final s in plan.subjects) {
        expect(s.plannedPace, greaterThan(0), reason: '${s.slug} has a pace');
        expect(projectedDays(s), (s.left / s.plannedPace).ceil(),
            reason: '${s.slug}: ${s.left} left at ${s.plannedPace}/day must '
                'finish when the card says it does');
      }
    });

    test('a small subject is not dragged out to the whole plan finish date',
        () {
      final plan = PlannerEngine.compute(
        subjects: [
          subject('dsa', total: 455),
          subject('oop', total: 50, concepts: true),
        ],
        start: start,
        deadline: deadline,
        now: today,
        dailyMinutes: 120,
      );
      final dsa = plan.subjects.firstWhere((s) => s.slug == 'dsa');
      final oop = plan.subjects.firstWhere((s) => s.slug == 'oop');

      // 50 items finish sooner than 455 do. Previously every auto subject was
      // handed the same aggregate date regardless of its size.
      expect(projectedDays(oop), lessThan(projectedDays(dsa)));
    });

    test('every unfinished subject advances at least one item a day', () {
      // Eight subjects sharing a small budget: none may stall at zero, or it
      // would be projected never to finish while still listed as active.
      final plan = PlannerEngine.compute(
        subjects: [for (var i = 0; i < 8; i++) subject('s$i', total: 40)],
        start: start,
        deadline: deadline,
        now: today,
        dailyMinutes: 60,
      );
      for (final s in plan.subjects) {
        expect(s.plannedPace, greaterThanOrEqualTo(1), reason: s.slug);
        expect(s.dailyTarget, greaterThanOrEqualTo(1), reason: s.slug);
        expect(s.projectedFinish, isNotNull, reason: s.slug);
      }
    });
  });

  group('a pinned pace is honoured', () {
    test('the pace shown is the pace set, and drives the projection', () {
      final plan = PlannerEngine.compute(
        subjects: [subject('dsa', total: 455), subject('oop', total: 50)],
        start: start,
        deadline: deadline,
        now: today,
        dailyMinutes: 120,
        plannedPaceFor: (slug) => slug == 'dsa' ? 1 : null,
      );
      final dsa = plan.subjects.firstWhere((s) => s.slug == 'dsa');

      expect(dsa.isPaceCustom, isTrue);
      expect(dsa.plannedPace, 1, reason: 'the number the user pinned');
      expect(projectedDays(dsa), 455, reason: '455 items at 1 a day');
    });

    test('excess in the daily target is catch-up, and is nameable', () {
      // 30 days into a plan with nothing done: the user is behind, so today
      // asks for more than the steady pace. The card labels that difference
      // rather than showing it as a second, contradictory pace.
      final plan = PlannerEngine.compute(
        subjects: [subject('dsa', total: 455)],
        start: start,
        deadline: deadline,
        now: start.add(const Duration(days: 30)),
        dailyMinutes: 120,
        plannedPaceFor: (_) => 1,
      );
      final dsa = plan.subjects.single;

      expect(dsa.plannedPace, 1);
      expect(dsa.dailyTarget, 2, reason: '1 planned + 1 capped catch-up');
      expect(dsa.dailyTarget - dsa.plannedPace, 1,
          reason: 'what the card names as catch-up');
    });

    test('a pace kept up shows no catch-up', () {
      // 30 days elapsed, 30 items done at a pinned pace of 1: nothing owed.
      final plan = PlannerEngine.compute(
        subjects: [subject('dsa', total: 455, done: 30)],
        start: start,
        deadline: deadline,
        now: start.add(const Duration(days: 30)),
        dailyMinutes: 120,
        plannedPaceFor: (_) => 1,
      );
      final dsa = plan.subjects.single;
      expect(dsa.dailyTarget, dsa.plannedPace,
          reason: 'target equals the pace when the user is up to date');
    });
  });

  group('the day never over-promises', () {
    test('the budget is capped by capacity, not by the deadline alone', () {
      final plan = PlannerEngine.compute(
        subjects: [subject('dsa', total: 1000, difficulty: Difficulty.hard)],
        start: start,
        deadline: deadline,
        now: today,
        dailyMinutes: 120,
      );
      expect(plan.todayBudgetMinutes, lessThanOrEqualTo(120));
      expect(plan.feasible, isFalse,
          reason: '1000 hard problems in 181 days needs far more than 2h/day');
      expect(plan.suggestedDeadline, isNotNull);
    });

    test('capacity and the effort table agree on what a day holds', () {
      final plan = PlannerEngine.compute(
        subjects: [subject('dsa', total: 100, difficulty: Difficulty.easy)],
        start: start,
        deadline: start.add(const Duration(days: 25)), // forces 4/day
        now: today,
        dailyMinutes: 60,
      );
      final dsa = plan.subjects.single;
      expect(dsa.todayMinutes, lessThanOrEqualTo(60));
      expect(
          dsa.todayMinutes, dsa.dailyTarget * PlanEffort.easyProblemMinutes);
    });
  });
}
