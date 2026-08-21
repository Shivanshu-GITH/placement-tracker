import 'package:drift/drift.dart';

/// Single-row user profile / preferences. Always id = 1.
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('Aspirant'))();
  TextColumn get targetRole => text().withDefault(const Constant('product'))();
  TextColumn get targetCompanies => text().withDefault(const Constant(''))(); // csv
  TextColumn get skillLevel => text().withDefault(const Constant('beginner'))();
  IntColumn get dailyGoalMinutes => integer().withDefault(const Constant(120))();
  IntColumn get dailyGoalProblems => integer().withDefault(const Constant(4))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A curated study sheet / track (e.g. Striver A2Z, Operating Systems).
class Sheets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get slug => text().unique()();
  TextColumn get title => text()();
  TextColumn get category => text()(); // PrepCategory.name
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant(''))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(true))();
}

/// A node in the generic content tree. A node is either a `section` (has
/// children) or a `leaf` (a trackable item — a coding `problem` or a
/// `concept`). Arbitrary depth is supported via [parentId].
class Nodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sheetId =>
      integer().references(Sheets, #id, onDelete: KeyAction.cascade)();
  IntColumn get parentId => integer().nullable()(); // self-ref (nullable = root)
  TextColumn get slug => text().unique()();
  TextColumn get title => text()();
  TextColumn get kind => text().withDefault(const Constant('leaf'))(); // section|leaf
  TextColumn get leafType => text().withDefault(const Constant('problem'))(); // problem|concept
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get platform => text().withDefault(const Constant(''))();
  TextColumn get resourceUrl => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get companies => text().withDefault(const Constant(''))();
  /// Canonical dedup key for leaves (e.g. `lc:two-sum`); `u:slug` when unique.
  TextColumn get canon => text().withDefault(const Constant(''))();
  IntColumn get depth => integer().withDefault(const Constant(0))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

/// Which sheets the user has chosen to actively work on, and which single DSA
/// sheet is the "primary" one that drives the roadmap ordering.
class UserSheets extends Table {
  IntColumn get sheetId =>
      integer().references(Sheets, #id, onDelete: KeyAction.cascade)();
  BoolColumn get active => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {sheetId};
}

/// User progress, keyed by the canonical leaf key so solving a problem once
/// counts for every leaf that shares the same reliable key (dedup).
class LeafProgress extends Table {
  TextColumn get canon => text()();
  TextColumn get status => text().withDefault(const Constant('todo'))();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get timeSpentMinutes => integer().withDefault(const Constant(0))();
  BoolColumn get bookmarked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get solvedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  IntColumn get reviewInterval => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {canon};
}

/// A logged study session (focus timer or manual log).
class StudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get category => text().withDefault(const Constant('dsa'))();
  IntColumn get problemsSolved => integer().withDefault(const Constant(0))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
}

/// Denormalized per-day activity, keyed by yyyymmdd.
class ActivityDays extends Table {
  IntColumn get day => integer()();
  IntColumn get minutes => integer().withDefault(const Constant(0))();
  IntColumn get problemsSolved => integer().withDefault(const Constant(0))();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  BoolColumn get goalMet => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {day};
}

/// A phase of the generated roadmap.
class RoadmapPhases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get focusAreas => text().withDefault(const Constant(''))();
}

/// A weekly objective inside a phase.
class RoadmapTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get phaseId =>
      integer().references(RoadmapPhases, #id, onDelete: KeyAction.cascade)();
  IntColumn get weekIndex => integer().withDefault(const Constant(0))();
  TextColumn get title => text()();
  TextColumn get category => text().withDefault(const Constant('dsa'))();
  IntColumn get targetProblems => integer().withDefault(const Constant(0))();
  IntColumn get targetMinutes => integer().withDefault(const Constant(0))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

/// Auto-generated daily schedule items.
class DailyPlanItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get day => integer()();
  TextColumn get title => text()();
  TextColumn get category => text().withDefault(const Constant('dsa'))();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(30))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

/// A curated external resource (free or paid). Paid entries carry an optional
/// [affiliateUrl] the owner fills in; the app prefers it over [url] when set.
class Resources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get slug => text().unique()();
  TextColumn get title => text()();
  TextColumn get provider => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get affiliateUrl => text().withDefault(const Constant(''))();
  TextColumn get type => text().withDefault(const Constant('link'))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get tier => text().withDefault(const Constant('free'))(); // free|paid
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

/// Unlocked achievements/badges.
class Achievements extends Table {
  TextColumn get key => text()();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
