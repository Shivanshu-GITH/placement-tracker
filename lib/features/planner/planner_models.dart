import '../../core/constants/enums.dart';
import 'planner_effort.dart';

/// A single trackable item as the planner sees it — decoupled from Drift so the
/// engine stays pure and unit-testable. The UI maps a `LeafRow` into one of
/// these; [canon] is enough to open it or mark it done.
class PlanLeaf {
  const PlanLeaf({
    required this.canon,
    required this.title,
    required this.difficulty,
    required this.isConcept,
    required this.isDone,
    this.solvedAt,
  });

  final String canon;
  final String title;
  final Difficulty difficulty;

  /// Concepts (theory/aptitude) mark done with `done`; problems with `solved`.
  final bool isConcept;
  final bool isDone;
  final DateTime? solvedAt;

  /// Estimated time this item takes — what the planner budgets the day with.
  int get estimatedMinutes =>
      PlanEffort.forLeaf(isConcept: isConcept, difficulty: difficulty);

  /// The status name to write when the user ticks this item done.
  String get doneStatus => isConcept ? 'done' : 'solved';

  /// The status name to write when the user un-ticks this item.
  String get todoStatus => isConcept ? 'notStarted' : 'todo';
}

/// One subject (an active sheet) with its leaves already in learning order.
class SubjectInput {
  const SubjectInput({
    required this.slug,
    required this.title,
    required this.category,
    required this.sheetId,
    required this.leaves,
  });

  final String slug;
  final String title;
  final PrepCategory category;
  final int sheetId;

  /// Leaves in the sheet's real tree (section → sub-section) order.
  final List<PlanLeaf> leaves;

  /// Estimated minutes of work still remaining in this subject.
  int get minutesLeft => leaves
      .where((l) => !l.isDone)
      .fold(0, (sum, l) => sum + l.estimatedMinutes);
}

/// An item on today's list for a subject.
class PlanItem {
  const PlanItem(this.leaf, {this.doneToday = false});
  final PlanLeaf leaf;

  /// True when this item was already completed today (kept visible until
  /// tomorrow, mirroring the reference engine's `todayList`).
  final bool doneToday;
}

/// The computed plan for one subject: pace, projected finish, on-track state
/// and today's targeted items.
class SubjectPlan {
  const SubjectPlan({
    required this.slug,
    required this.title,
    required this.category,
    required this.sheetId,
    required this.total,
    required this.done,
    required this.doneTodayCount,
    required this.plannedPace,
    required this.requiredPace,
    required this.dailyTarget,
    required this.projectedFinish,
    required this.deadline,
    required this.todayItems,
    required this.isPaceCustom,
    this.minutesLeft = 0,
  });

  final String slug;
  final String title;
  final PrepCategory category;
  final int sheetId;

  final int total;
  final int done;

  /// Items completed today (before capping to the day's target).
  final int doneTodayCount;

  /// The steady per-day target (user-chosen, or the auto pace needed to finish
  /// by the deadline).
  final int plannedPace;

  /// The pace that would still clear the remaining items by the deadline.
  final int requiredPace;

  /// Today's actual target = planned pace plus any catch-up for days missed,
  /// capped at one extra day and at whatever is left.
  final int dailyTarget;

  /// When the subject finishes at the planned pace; null if it can't (pace 0
  /// with items remaining) or is already complete.
  final DateTime? projectedFinish;
  final DateTime deadline;

  /// Whether [plannedPace] came from a user override rather than the auto pace.
  final bool isPaceCustom;

  /// Today's list: items done today first, then the next unsolved items up to
  /// the day's target.
  final List<PlanItem> todayItems;

  /// Estimated minutes of work still remaining in this subject.
  final int minutesLeft;

  /// Estimated minutes for the items still to do on today's list.
  int get todayMinutes => todayItems
      .where((i) => !i.doneToday)
      .fold(0, (sum, i) => sum + i.leaf.estimatedMinutes);

  int get left => total - done;
  bool get complete => left == 0;
  double get progress => total == 0 ? 0 : done / total;

  /// Done today, but never counted beyond the day's target (for tidy "x/y").
  int get todayDone =>
      doneTodayCount > dailyTarget ? dailyTarget : doneTodayCount;

  bool get onTrack =>
      complete ||
      (projectedFinish != null && !projectedFinish!.isAfter(deadline));

  /// Days by which the projected finish beats (negative) or misses (positive)
  /// the deadline. Null when it never finishes or is complete.
  int? get slackDays => projectedFinish?.difference(deadline).inDays;
}

/// A category rollup over its subjects.
class CategoryPlan {
  const CategoryPlan({required this.category, required this.subjects});
  final PrepCategory category;
  final List<SubjectPlan> subjects;

  int get total => subjects.fold(0, (s, e) => s + e.total);
  int get done => subjects.fold(0, (s, e) => s + e.done);
  int get left => total - done;
  int get dailyTarget => subjects.fold(0, (s, e) => s + e.dailyTarget);
  int get todayDone => subjects.fold(0, (s, e) => s + e.todayDone);
  double get progress => total == 0 ? 0 : done / total;
  bool get onTrack => subjects.every((s) => s.onTrack);
}

/// The whole plan: subjects + category rollups + campaign-level totals.
class PlanOverview {
  const PlanOverview({
    required this.start,
    required this.deadline,
    required this.today,
    required this.daysToDeadline,
    required this.subjects,
    required this.categories,
    required this.projectedFinish,
    required this.canFinish,
    this.capacityMinutes = 0,
    this.requiredMinutesPerDay = 0,
    this.todayBudgetMinutes = 0,
  });

  final DateTime start;
  final DateTime deadline;
  final DateTime today;

  /// Whole days from today to the deadline (never negative).
  final int daysToDeadline;

  final List<SubjectPlan> subjects;
  final List<CategoryPlan> categories;

  /// The last subject's projected finish — when everything is done at the
  /// planned pace. Null when some subject can never finish at its pace.
  final DateTime? projectedFinish;

  /// False when at least one subject has items left but a zero pace.
  final bool canFinish;

  /// The user's daily study capacity in minutes (0 when the plan was computed
  /// without a time budget).
  final int capacityMinutes;

  /// Minutes per day genuinely needed to clear everything by the deadline.
  final int requiredMinutesPerDay;

  /// Minutes actually budgeted for today = min(capacity, required).
  final int todayBudgetMinutes;

  bool get isEmpty => subjects.isEmpty;

  /// Estimated minutes of work left across every subject.
  int get minutesLeft => subjects.fold(0, (s, e) => s + e.minutesLeft);

  /// Estimated minutes for what is still to do on today's list.
  int get todayMinutes => subjects.fold(0, (s, e) => s + e.todayMinutes);

  /// Whether the deadline is reachable at the user's stated daily capacity.
  /// Always true when no capacity was supplied (nothing to judge against).
  bool get feasible =>
      capacityMinutes <= 0 || requiredMinutesPerDay <= capacityMinutes;

  /// Days of work left at full capacity — the earliest realistic finish.
  int get daysAtCapacity => capacityMinutes <= 0 || minutesLeft <= 0
      ? 0
      : (minutesLeft / capacityMinutes).ceil();

  /// The soonest deadline that is actually achievable at the current capacity.
  /// Use this to offer "extend my deadline to X" when the plan can't fit.
  DateTime? get suggestedDeadline => capacityMinutes <= 0 || minutesLeft <= 0
      ? null
      : DateTime(today.year, today.month, today.day + daysAtCapacity);

  /// Hours per day that would clear everything by the deadline.
  double get requiredHoursPerDay => requiredMinutesPerDay / 60.0;

  int get total => subjects.fold(0, (s, e) => s + e.total);
  int get done => subjects.fold(0, (s, e) => s + e.done);
  int get left => total - done;
  double get progress => total == 0 ? 0 : done / total;

  int get todayTarget => subjects.fold(0, (s, e) => s + e.dailyTarget);
  int get todayDone => subjects.fold(0, (s, e) => s + e.todayDone);

  /// True when every subject will finish on time (or is already done).
  bool get onTrack => canFinish && subjects.every((s) => s.onTrack);

  /// Subjects that are behind (won't finish by the deadline). Empty when all
  /// on track.
  List<SubjectPlan> get behind =>
      subjects.where((s) => !s.complete && !s.onTrack).toList();
}
