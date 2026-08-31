import 'dart:math' as math;

import '../../core/constants/enums.dart';
import 'planner_models.dart';

/// The deadline-driven planning engine.
///
/// Given the user's active subjects (each an ordered list of leaves), a start
/// date and a target deadline, it computes for every subject: the pace needed
/// to finish on time, today's target (with automatic catch-up for missed days,
/// capped at one extra day), the projected finish date, whether it is on track,
/// and today's concrete list of items.
///
/// It is a pure function of its inputs — no I/O, no Drift — so it recomputes
/// live as progress changes and is trivially unit-testable. The design mirrors
/// the reference "Unnati" tracker's `plan.ts` (dailyTarget / todayList /
/// trackStats), adapted to PrepPilot's per-sheet, canon-keyed data model.
class PlannerEngine {
  const PlannerEngine._();

  /// Normalises a timestamp to midnight so all arithmetic is in whole days.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Whole calendar days from [a] to [b] (b - a).
  static int diffDays(DateTime a, DateTime b) =>
      dateOnly(b).difference(dateOnly(a)).inDays;

  static DateTime addDays(DateTime d, int n) =>
      dateOnly(d).add(Duration(days: n));

  static bool _sameDay(DateTime? a, DateTime b) =>
      a != null && dateOnly(a) == dateOnly(b);

  /// Computes the full plan.
  ///
  /// [plannedPaceFor] returns a user's per-day override for a subject (by slug),
  /// or null to use the auto pace (whatever is needed to finish by the
  /// deadline). [now] defaults to [DateTime.now].
  static PlanOverview compute({
    required List<SubjectInput> subjects,
    required DateTime start,
    required DateTime deadline,
    int? Function(String slug)? plannedPaceFor,
    DateTime? now,
  }) {
    final today = dateOnly(now ?? DateTime.now());
    final startD = dateOnly(start);
    final deadlineD = dateOnly(deadline);

    // Fully-elapsed days since the start (day one shows no carry-over), and days
    // remaining to the deadline (never negative).
    final closed = math.max(0, diffDays(startD, today));
    final daysToDeadline = math.max(0, diffDays(today, deadlineD));

    final plans = <SubjectPlan>[];
    for (final s in subjects) {
      final total = s.leaves.length;
      final done = s.leaves.where((l) => l.isDone).length;
      final left = total - done;

      // Pace needed to still clear what's left by the deadline.
      final int requiredPace;
      if (left == 0) {
        requiredPace = 0;
      } else if (daysToDeadline <= 0) {
        requiredPace = left; // deadline is here — everything is due now
      } else {
        requiredPace = math.max(1, (left / daysToDeadline).ceil());
      }

      // Planned steady pace: a user override wins, else the auto (required) pace
      // so a fresh plan sits exactly on schedule.
      final override = plannedPaceFor?.call(s.slug);
      final isCustom = override != null && override >= 1;
      final int plannedPace = left == 0
          ? 0
          : isCustom
              ? override
              : math.max(1, requiredPace);

      // Today's target = planned pace plus catch-up for days missed, capped at
      // one extra day and never more than what's left. Catch-up applies only to
      // a fixed custom pace; the auto pace already absorbs lost time by rising
      // as fewer days remain, so it needs no extra spike.
      final int deficit =
          isCustom ? math.max(0, plannedPace * closed - done) : 0;
      int dailyTarget = plannedPace + math.min(deficit, plannedPace);
      if (dailyTarget > left) dailyTarget = left;
      if (left == 0) dailyTarget = 0;

      // Projection at the planned pace.
      final DateTime? projected = left == 0
          ? null
          : plannedPace > 0
              ? addDays(today, (left / plannedPace).ceil())
              : null;

      // Today's list: done-today first, then next unsolved up to the target.
      final doneToday = <PlanItem>[];
      for (final l in s.leaves) {
        if (l.isDone && _sameDay(l.solvedAt, today)) {
          doneToday.add(PlanItem(l, doneToday: true));
        }
      }
      final need = math.max(0, dailyTarget - doneToday.length);
      final next = <PlanItem>[];
      for (final l in s.leaves) {
        if (l.isDone) continue;
        next.add(PlanItem(l));
        if (next.length >= need) break;
      }

      plans.add(SubjectPlan(
        slug: s.slug,
        title: s.title,
        category: s.category,
        sheetId: s.sheetId,
        total: total,
        done: done,
        doneTodayCount: doneToday.length,
        plannedPace: plannedPace,
        requiredPace: requiredPace,
        dailyTarget: dailyTarget,
        projectedFinish: projected,
        deadline: deadlineD,
        todayItems: [...doneToday, ...next],
        isPaceCustom: isCustom,
      ));
    }

    // Category rollups, preserving PrepCategory declaration order.
    final byCat = <PrepCategory, List<SubjectPlan>>{};
    for (final p in plans) {
      byCat.putIfAbsent(p.category, () => []).add(p);
    }
    final categories = <CategoryPlan>[];
    for (final c in PrepCategory.values) {
      final subs = byCat[c];
      if (subs != null && subs.isNotEmpty) {
        categories.add(CategoryPlan(category: c, subjects: subs));
      }
    }

    // Whole-plan projection: the last subject to finish. If any unfinished
    // subject can never finish (pace 0), the plan as a whole can't either.
    DateTime? projectedFinish;
    var canFinish = true;
    for (final p in plans) {
      if (p.complete) continue;
      if (p.projectedFinish == null) {
        canFinish = false;
        projectedFinish = null;
        break;
      }
      if (projectedFinish == null || p.projectedFinish!.isAfter(projectedFinish)) {
        projectedFinish = p.projectedFinish;
      }
    }

    return PlanOverview(
      start: startD,
      deadline: deadlineD,
      today: today,
      daysToDeadline: daysToDeadline,
      subjects: plans,
      categories: categories,
      projectedFinish: projectedFinish,
      canFinish: canFinish,
    );
  }
}
