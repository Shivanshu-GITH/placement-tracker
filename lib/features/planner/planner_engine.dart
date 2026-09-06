import 'dart:math' as math;

import '../../core/constants/enums.dart';
import 'planner_models.dart';

/// The deadline-driven planning engine.
///
/// Given the user's active subjects (each an ordered list of leaves), a start
/// date, a target deadline and — crucially — how many minutes a day they can
/// actually study, it computes for every subject: the pace needed to finish on
/// time, today's target, the projected finish date, whether it is on track, and
/// today's concrete list of items.
///
/// ## Why effort, not item counts
/// Planning by item count alone is what makes a roadmap lie: 20 aptitude
/// concepts and 20 hard DSA problems are both "20 items" but differ ~5x in real
/// work. When [compute] is given a [dailyMinutes] budget it switches to
/// EFFORT-BASED planning:
///
///  * every remaining item is costed in minutes (see `PlanEffort`),
///  * the day's budget is `min(capacity, minutes needed per day to hit the
///    deadline)` — so the user is never asked for more than they said they have,
///    and never padded beyond what the deadline requires,
///  * that budget is split across subjects **in proportion to the work each has
///    left**, so every subject advances together instead of one starving the
///    others,
///  * each subject's projected finish is then `ceil(left / its sustained rate)`
///    — the SAME rate reported as its pace — so pace, daily target and finish
///    date always describe one plan rather than three,
///  * plan-level capacity is what makes `feasible` / `suggestedDeadline` on
///    [PlanOverview] trustworthy.
///
/// Omitting [dailyMinutes] keeps the original count-based behaviour.
///
/// It is a pure function of its inputs — no I/O, no Drift — so it recomputes
/// live as progress changes and is trivially unit-testable. Because it derives
/// everything from the CURRENT set of active subjects and what is left in them,
/// adding or finishing sheets re-plans automatically with no extra bookkeeping.
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
  /// or null to use the auto pace. [dailyMinutes] is the user's daily study
  /// capacity; supplying it enables effort-based planning (see the class doc).
  /// [now] defaults to [DateTime.now].
  static PlanOverview compute({
    required List<SubjectInput> subjects,
    required DateTime start,
    required DateTime deadline,
    int? Function(String slug)? plannedPaceFor,
    DateTime? now,
    int? dailyMinutes,
  }) {
    final today = dateOnly(now ?? DateTime.now());
    final startD = dateOnly(start);
    final deadlineD = dateOnly(deadline);

    // Fully-elapsed days since the start (day one shows no carry-over), and days
    // remaining to the deadline (never negative).
    final closed = math.max(0, diffDays(startD, today));
    final daysToDeadline = math.max(0, diffDays(today, deadlineD));

    final capacity = (dailyMinutes != null && dailyMinutes > 0) ? dailyMinutes : 0;
    final timeAware = capacity > 0;

    // ---- Pass 1: per-subject facts, required/planned pace, work done today.
    final facts = <_Facts>[];
    for (final s in subjects) {
      final total = s.leaves.length;
      final done = s.leaves.where((l) => l.isDone).length;
      final left = total - done;

      final int requiredPace;
      if (left == 0) {
        requiredPace = 0;
      } else if (daysToDeadline <= 0) {
        requiredPace = left; // deadline is here — everything is due now
      } else {
        requiredPace = math.max(1, (left / daysToDeadline).ceil());
      }

      final override = plannedPaceFor?.call(s.slug);
      final isCustom = override != null && override >= 1;
      final plannedPace = left == 0
          ? 0
          : isCustom
              ? override
              : math.max(1, requiredPace);

      final doneToday = <PlanItem>[
        for (final l in s.leaves)
          if (l.isDone && _sameDay(l.solvedAt, today)) PlanItem(l, doneToday: true),
      ];

      facts.add(_Facts(
        input: s,
        total: total,
        done: done,
        left: left,
        minutesLeft: s.minutesLeft,
        requiredPace: requiredPace,
        plannedPace: plannedPace,
        isCustom: isCustom,
        doneToday: doneToday,
      ));
    }

    // ---- Pass 2: today's target for each subject.
    final totalMinutesLeft = facts.fold(0, (s, f) => s + f.minutesLeft);
    final requiredMinutesPerDay = totalMinutesLeft == 0
        ? 0
        : daysToDeadline <= 0
            ? totalMinutesLeft
            : (totalMinutesLeft / daysToDeadline).ceil();
    // Never ask for more than the user has, nor more than the deadline needs.
    final todayBudget =
        timeAware ? math.min(capacity, requiredMinutesPerDay) : 0;

    // Count-based catch-up target, used for custom-pace subjects in both modes
    // and for every subject when no time budget was supplied.
    int countTarget(_Facts f) {
      final deficit =
          f.isCustom ? math.max(0, f.plannedPace * closed - f.done) : 0;
      var t = f.plannedPace + math.min<int>(deficit, f.plannedPace);
      if (t > f.left) t = f.left;
      if (f.left == 0) t = 0;
      return t;
    }

    // How many of a subject's next undone items fit inside [budgetMinutes].
    // Only whole items that actually fit are counted, so the day is never
    // over-promised — with one exception: when [floorOne] is set an unfinished
    // subject always gets at least one item, otherwise a subject whose next
    // item costs more than its slice of the budget would stall forever.
    int fitCount(_Facts f, double budgetMinutes, {required bool floorOne}) {
      var used = 0.0;
      var count = 0;
      if (budgetMinutes > 0) {
        for (final l in f.input.leaves) {
          if (l.isDone) continue;
          if (used + l.estimatedMinutes > budgetMinutes) break;
          used += l.estimatedMinutes;
          count++;
        }
      }
      if (count == 0 && floorOne && f.left > 0) return 1;
      return count;
    }

    final targets = <int>[];
    // The rate each subject sustains from tomorrow on. Today's target can be
    // higher (catch-up) or lower (some of it already done), so the projection
    // has to come from THIS, not from the target — otherwise a card can print
    // "1 per day, 50 left" next to a finish date six months out.
    final steadyPace = <int>[];
    int autoBudget = 0;
    int autoMinutesLeft = 0;

    if (!timeAware) {
      for (final f in facts) {
        targets.add(countTarget(f));
        steadyPace.add(f.plannedPace);
      }
    } else {
      // Custom-pace subjects keep their pinned pace and consume their share of
      // the day's budget first; the rest is shared by the auto subjects.
      var customMinutes = 0;
      for (final f in facts) {
        if (!f.isCustom) continue;
        final t = countTarget(f);
        var m = 0, taken = 0;
        for (final l in f.input.leaves) {
          if (l.isDone) continue;
          if (taken >= t) break;
          m += l.estimatedMinutes;
          taken++;
        }
        customMinutes += m;
      }
      autoBudget = math.max(0, todayBudget - customMinutes);
      autoMinutesLeft = facts
          .where((f) => !f.isCustom)
          .fold(0, (s, f) => s + f.minutesLeft);

      for (final f in facts) {
        if (f.isCustom) {
          targets.add(countTarget(f));
          steadyPace.add(f.plannedPace);
          continue;
        }
        if (f.left == 0 || autoMinutesLeft == 0) {
          targets.add(0);
          steadyPace.add(0);
          continue;
        }
        // This subject's steady slice of the day: its share of the auto budget,
        // in proportion to the work it has left.
        final slice = autoBudget * (f.minutesLeft / autoMinutesLeft);
        // The rate it advances at every day. This is what "pace" means for an
        // auto-paced subject, and the projection is derived from it, so the
        // pace, the daily target and the finish date all describe one plan.
        steadyPace.add(fitCount(f, slice, floorOne: true));
        // Today's target is that same slice, minus whatever the user already
        // completed in this subject today.
        final doneMinutes = f.doneToday
            .fold<int>(0, (s, i) => s + i.leaf.estimatedMinutes);
        targets.add(f.doneToday.length +
            fitCount(f, slice - doneMinutes, floorOne: f.doneToday.isEmpty));
      }
    }

    // ---- Pass 3: today's list + projection per subject.
    final plans = <SubjectPlan>[];
    for (var i = 0; i < facts.length; i++) {
      final f = facts[i];
      final dailyTarget = targets[i];
      final pace = steadyPace[i];

      final need = math.max(0, dailyTarget - f.doneToday.length);
      final next = <PlanItem>[];
      for (final l in f.input.leaves) {
        if (l.isDone) continue;
        if (next.length >= need) break;
        next.add(PlanItem(l));
      }

      // One rule for every subject: at [pace] a day, [left] items take
      // ceil(left / pace) days. A card can now be read straight through.
      final DateTime? projected = f.left == 0
          ? null // complete
          : pace > 0
              ? addDays(today, (f.left / pace).ceil())
              : null;

      plans.add(SubjectPlan(
        slug: f.input.slug,
        title: f.input.title,
        category: f.input.category,
        sheetId: f.input.sheetId,
        total: f.total,
        done: f.done,
        doneTodayCount: f.doneToday.length,
        plannedPace: pace,
        requiredPace: f.requiredPace,
        dailyTarget: dailyTarget,
        projectedFinish: projected,
        deadline: deadlineD,
        todayItems: [...f.doneToday, ...next],
        isPaceCustom: f.isCustom,
        minutesLeft: f.minutesLeft,
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
      if (projectedFinish == null ||
          p.projectedFinish!.isAfter(projectedFinish)) {
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
      capacityMinutes: capacity,
      requiredMinutesPerDay: requiredMinutesPerDay,
      todayBudgetMinutes: todayBudget,
    );
  }
}

/// Per-subject working values shared between the engine's passes.
class _Facts {
  _Facts({
    required this.input,
    required this.total,
    required this.done,
    required this.left,
    required this.minutesLeft,
    required this.requiredPace,
    required this.plannedPace,
    required this.isCustom,
    required this.doneToday,
  });

  final SubjectInput input;
  final int total;
  final int done;
  final int left;
  final int minutesLeft;
  final int requiredPace;
  final int plannedPace;
  final bool isCustom;
  final List<PlanItem> doneToday;
}
