import 'package:drift/drift.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/day_key.dart';
import '../database/database.dart';
import '../models/dtos.dart';

/// Central repository for content (the node tree), progress (keyed by canonical
/// key for dedup), sheet selection, sessions, streaks and derived statistics.
class PrepRepository {
  PrepRepository(this._db);
  final AppDatabase _db;

  static const List<int> _reviewIntervals = [1, 3, 7, 16, 35];
  static const _doneStatuses = {'solved', 'done'};

  // ---- Reactive sources ---------------------------------------------------

  Stream<List<Node>> watchNodes() => _db.select(_db.nodes).watch();
  Stream<List<Sheet>> watchSheets() => (_db.select(_db.sheets)
        ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
      .watch();
  Stream<List<LeafProgressData>> watchProgress() =>
      _db.select(_db.leafProgress).watch();
  Stream<List<Resource>> watchResources() => (_db.select(_db.resources)
        ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
      .watch();
  Stream<List<UserSheet>> watchUserSheets() =>
      _db.select(_db.userSheets).watch();

  // ---- Pure derivations ---------------------------------------------------

  /// Builds leaf rows: each leaf joined with its sheet, top-level section and
  /// progress (matched by canonical key).
  static List<LeafRow> leafRowsFrom(
    List<Node> nodes,
    Map<int, Sheet> sheetsById,
    Map<String, LeafProgressData> progressByCanon,
  ) {
    final byId = {for (final n in nodes) n.id: n};
    final rows = <LeafRow>[];
    for (final n in nodes) {
      if (n.kind != 'leaf') continue;
      final sheet = sheetsById[n.sheetId];
      if (sheet == null) continue;
      var top = n;
      while (top.parentId != null && byId[top.parentId!] != null) {
        top = byId[top.parentId!]!;
      }
      rows.add(LeafRow(
        node: n,
        sheet: sheet,
        sectionId: top.id,
        sectionTitle: identical(top, n) ? sheet.title : top.title,
        progress: progressByCanon[n.canon],
      ));
    }
    return rows;
  }

  /// Builds the renderable tree for one sheet from its nodes + progress, with
  /// rolled-up done/total counts on every section.
  static List<TreeNode> buildSheetTree(
    List<Node> sheetNodes,
    Sheet sheet,
    Map<String, LeafProgressData> progressByCanon,
  ) {
    final byParent = <int?, List<Node>>{};
    for (final n in sheetNodes) {
      byParent.putIfAbsent(n.parentId, () => []).add(n);
    }
    for (final list in byParent.values) {
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    List<TreeNode> build(int? parentId) {
      final out = <TreeNode>[];
      for (final n in byParent[parentId] ?? const []) {
        if (n.kind == 'leaf') {
          final row = LeafRow(
            node: n,
            sheet: sheet,
            sectionId: parentId ?? -1,
            sectionTitle: '',
            progress: progressByCanon[n.canon],
          );
          out.add(TreeNode.leaf(n, row, 1, row.isDone ? 1 : 0));
        } else {
          final kids = build(n.id);
          var total = 0, done = 0;
          for (final k in kids) {
            total += k.total;
            done += k.done;
          }
          out.add(TreeNode.section(n, kids, total, done));
        }
      }
      return out;
    }

    return build(null);
  }

  static List<SheetSummary> summariesFrom(
      List<LeafRow> allRows, Set<int> activeSheetIds) {
    final bySheet = <int, List<LeafRow>>{};
    for (final r in allRows) {
      bySheet.putIfAbsent(r.sheet.id, () => []).add(r);
    }
    final result = bySheet.values.map((items) {
      final sheet = items.first.sheet;
      var done = 0, revisit = 0;
      for (final r in items) {
        if (r.isDone) done++;
        if (r.needsRevisit) revisit++;
      }
      return SheetSummary(
        sheet: sheet,
        total: items.length,
        done: done,
        revisit: revisit,
        active: activeSheetIds.contains(sheet.id),
      );
    }).toList()
      ..sort((a, b) => a.sheet.orderIndex.compareTo(b.sheet.orderIndex));
    return result;
  }

  /// Stats over the given rows, deduped by canonical key (solve-once semantics).
  static PrepStats statsFrom(List<LeafRow> rows) {
    final seen = <String, LeafRow>{};
    for (final r in rows) {
      seen.putIfAbsent(r.canon, () => r);
    }
    final byCatTotal = <PrepCategory, int>{};
    final byCatDone = <PrepCategory, int>{};
    final doneByDiff = <Difficulty, int>{};
    final totalByDiff = <Difficulty, int>{};
    var totalDone = 0, bookmarked = 0, revisit = 0;

    for (final r in seen.values) {
      byCatTotal.update(r.category, (v) => v + 1, ifAbsent: () => 1);
      totalByDiff.update(r.difficulty, (v) => v + 1, ifAbsent: () => 1);
      if (r.isDone) {
        totalDone++;
        byCatDone.update(r.category, (v) => v + 1, ifAbsent: () => 1);
        doneByDiff.update(r.difficulty, (v) => v + 1, ifAbsent: () => 1);
      }
      if (r.isBookmarked) bookmarked++;
      if (r.needsRevisit) revisit++;
    }

    final byCategory = byCatTotal.entries
        .map((e) => CategoryProgress(
            category: e.key, total: e.value, done: byCatDone[e.key] ?? 0))
        .toList()
      ..sort((a, b) => a.category.index.compareTo(b.category.index));

    return PrepStats(
      totalItems: seen.length,
      totalDone: totalDone,
      byCategory: byCategory,
      doneByDifficulty: doneByDiff,
      totalByDifficulty: totalByDiff,
      bookmarked: bookmarked,
      needsRevisit: revisit,
    );
  }

  // ---- Mutations: progress ------------------------------------------------

  Future<int> setLeafStatus(String canon, String statusName) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.leafProgress)
            ..where((t) => t.canon.equals(canon)))
          .getSingleOrNull();
      final was = _doneStatuses.contains(existing?.status);
      final now = _doneStatuses.contains(statusName);
      final dt = DateTime.now();

      var interval = existing?.reviewInterval ?? 0;
      DateTime? nextReview = existing?.nextReviewAt;
      if (statusName == 'solved') {
        final idx = interval == 0
            ? 0
            : (_reviewIntervals.indexOf(interval) + 1)
                .clamp(0, _reviewIntervals.length - 1);
        interval = _reviewIntervals[idx];
        nextReview = dt.add(Duration(days: interval));
      }

      await _db.into(_db.leafProgress).insertOnConflictUpdate(
            LeafProgressCompanion(
              canon: Value(canon),
              status: Value(statusName),
              note: Value(existing?.note ?? ''),
              timeSpentMinutes: Value(existing?.timeSpentMinutes ?? 0),
              bookmarked: Value(existing?.bookmarked ?? false),
              solvedAt: Value(now ? dt : existing?.solvedAt),
              nextReviewAt: Value(nextReview),
              reviewInterval: Value(interval),
              updatedAt: Value(dt),
            ),
          );

      var xp = 0;
      if (now && !was) {
        xp = 10;
        await _bumpActivity(problemsDelta: 1, xpDelta: xp);
      } else if (!now && was) {
        await _bumpActivity(problemsDelta: -1, xpDelta: 0);
      }
      return xp;
    });
  }

  Future<void> toggleBookmark(String canon) async {
    final existing = await (_db.select(_db.leafProgress)
          ..where((t) => t.canon.equals(canon)))
        .getSingleOrNull();
    await _db.into(_db.leafProgress).insertOnConflictUpdate(
          LeafProgressCompanion(
            canon: Value(canon),
            status: Value(existing?.status ?? 'todo'),
            note: Value(existing?.note ?? ''),
            bookmarked: Value(!(existing?.bookmarked ?? false)),
            timeSpentMinutes: Value(existing?.timeSpentMinutes ?? 0),
            solvedAt: Value(existing?.solvedAt),
            nextReviewAt: Value(existing?.nextReviewAt),
            reviewInterval: Value(existing?.reviewInterval ?? 0),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> saveNote(String canon, String note) async {
    final existing = await (_db.select(_db.leafProgress)
          ..where((t) => t.canon.equals(canon)))
        .getSingleOrNull();
    await _db.into(_db.leafProgress).insertOnConflictUpdate(
          LeafProgressCompanion(
            canon: Value(canon),
            status: Value(existing?.status ?? 'todo'),
            note: Value(note),
            bookmarked: Value(existing?.bookmarked ?? false),
            timeSpentMinutes: Value(existing?.timeSpentMinutes ?? 0),
            solvedAt: Value(existing?.solvedAt),
            nextReviewAt: Value(existing?.nextReviewAt),
            reviewInterval: Value(existing?.reviewInterval ?? 0),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  // ---- Mutations: sheet selection ----------------------------------------

  Future<void> setSheetActive(int sheetId, bool active) async {
    await _db.into(_db.userSheets).insertOnConflictUpdate(
          UserSheetsCompanion(sheetId: Value(sheetId), active: Value(active)),
        );
  }

  Future<void> setPrimarySheet(int sheetId) async {
    await _db.transaction(() async {
      await (_db.update(_db.userSheets))
          .write(const UserSheetsCompanion(isPrimary: Value(false)));
      await _db.into(_db.userSheets).insertOnConflictUpdate(UserSheetsCompanion(
          sheetId: Value(sheetId),
          isPrimary: const Value(true),
          active: const Value(true)));
    });
  }

  // ---- Achievements -------------------------------------------------------

  /// Persists any newly-earned achievement keys and returns the new ones
  /// (so the UI can celebrate). Idempotent.
  Future<List<String>> syncAchievements(Set<String> earnedKeys) async {
    final existing =
        (await _db.select(_db.achievements).get()).map((a) => a.key).toSet();
    final newly = earnedKeys.difference(existing).toList();
    if (newly.isNotEmpty) {
      await _db.batch((b) => b.insertAll(
            _db.achievements,
            newly.map((k) => AchievementsCompanion.insert(key: k)),
            mode: InsertMode.insertOrIgnore,
          ));
    }
    return newly;
  }

  // ---- Study sessions -----------------------------------------------------

  Future<void> logSession({
    required int minutes,
    required PrepCategory category,
    int problemsSolved = 0,
    String source = 'manual',
    String note = '',
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.studySessions).insert(StudySessionsCompanion.insert(
        startedAt: DateTime.now(),
        durationMinutes: minutes,
        category: Value(category.name),
        problemsSolved: Value(problemsSolved),
        source: Value(source),
        note: Value(note),
      ));
      await _bumpActivity(minutesDelta: minutes, xpDelta: minutes ~/ 6);
    });
  }

  Stream<List<StudySession>> watchRecentSessions({int limit = 20}) {
    return (_db.select(_db.studySessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .watch();
  }

  // ---- Activity + streak --------------------------------------------------

  Future<void> _bumpActivity({
    int problemsDelta = 0,
    int minutesDelta = 0,
    int xpDelta = 0,
  }) async {
    final today = DayKey.today();
    final existing = await (_db.select(_db.activityDays)
          ..where((t) => t.day.equals(today)))
        .getSingleOrNull();
    final profile =
        await (_db.select(_db.userProfiles)..limit(1)).getSingleOrNull();
    final goalMin = profile?.dailyGoalMinutes ?? 120;

    final problems =
        ((existing?.problemsSolved ?? 0) + problemsDelta).clamp(0, 1 << 30);
    final minutes = ((existing?.minutes ?? 0) + minutesDelta).clamp(0, 1 << 30);
    final xp = ((existing?.xpEarned ?? 0) + xpDelta).clamp(0, 1 << 30);
    // A day counts once the user has put in their planned study time. The old
    // "or N problems" arm is gone with the retired problems goal — items differ
    // too much in effort for a raw count to mean anything.
    final goalMet = minutes >= goalMin;

    await _db.into(_db.activityDays).insertOnConflictUpdate(ActivityDaysCompanion(
      day: Value(today),
      problemsSolved: Value(problems),
      minutes: Value(minutes),
      xpEarned: Value(xp),
      goalMet: Value(goalMet),
    ));

    if (xpDelta > 0 && profile != null) {
      await (_db.update(_db.userProfiles)
            ..where((t) => t.id.equals(profile.id)))
          .write(UserProfilesCompanion(xp: Value(profile.xp + xpDelta)));
    }
  }

  Stream<List<ActivityDay>> watchActivity({int days = 180}) {
    final since =
        DayKey.fromDate(DateTime.now().subtract(Duration(days: days)));
    return (_db.select(_db.activityDays)
          ..where((t) => t.day.isBiggerOrEqualValue(since))
          ..orderBy([(t) => OrderingTerm(expression: t.day)]))
        .watch();
  }

  static StreakInfo streakFrom(List<ActivityDay> activity) {
    final activeDays = activity
        .where((a) => a.problemsSolved > 0 || a.minutes > 0)
        .map((a) => a.day)
        .toSet();
    if (activeDays.isEmpty) return StreakInfo.empty;

    int current = 0;
    var cursor = DateTime.now();
    if (!activeDays.contains(DayKey.fromDate(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (activeDays.contains(DayKey.fromDate(cursor))) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final sorted = activeDays.toList()..sort();
    int longest = 1, run = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (DayKey.diffDays(sorted[i - 1], sorted[i]) == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
    }
    return StreakInfo(current: current, longest: longest);
  }
}
