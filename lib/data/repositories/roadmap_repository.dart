import 'package:drift/drift.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/day_key.dart';
import '../database/database.dart';
import '../models/dtos.dart';

/// Generates and stores a personalized, rule-based roadmap and daily plan.
///
/// The roadmap follows the user's PRIMARY DSA sheet's real learning order
/// (its section → sub-pattern sequence), paced to finish by the target date and
/// adjusted for skill level. Theory is interleaved from the active sheets.
/// No AI/API cost.
class RoadmapRepository {
  RoadmapRepository(this._db);
  final AppDatabase _db;

  Stream<List<RoadmapPhase>> watchPhases() {
    return (_db.select(_db.roadmapPhases)
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .watch();
  }

  Stream<List<RoadmapTask>> watchTasks() {
    return (_db.select(_db.roadmapTasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.weekIndex),
            (t) => OrderingTerm(expression: t.orderIndex),
          ]))
        .watch();
  }

  Future<bool> hasRoadmap() async {
    final count = await _db.roadmapPhases.count().getSingle();
    return count > 0;
  }

  Future<void> toggleTask(int taskId, bool done) async {
    await (_db.update(_db.roadmapTasks)..where((t) => t.id.equals(taskId)))
        .write(RoadmapTasksCompanion(done: Value(done)));
  }

  // ---- Roadmap generation -------------------------------------------------

  static const _phaseDefs = <(String, String, double)>[
    ('Foundation', 'Fundamentals & momentum', 0.30),
    ('Core Mastery', 'Core patterns & theory', 0.35),
    ('Advanced', 'Hard problems & depth', 0.20),
    ('Mock & Revision', 'Revise, mocks & interviews', 0.15),
  ];

  /// (Re)generates the roadmap for the given profile, clearing any prior one.
  Future<void> generate(UserProfile profile) async {
    final now = DateTime.now();
    final targetDate = profile.targetDate ?? now.add(const Duration(days: 84));
    final totalWeeks =
        ((targetDate.difference(now).inDays).clamp(21, 365) / 7).ceil().clamp(3, 52);
    final skill = SkillLevel.fromName(profile.skillLevel);
    final skillFactor = switch (skill) {
      SkillLevel.beginner => 0.8,
      SkillLevel.intermediate => 1.0,
      SkillLevel.advanced => 1.25,
    };

    final dsaSections = await _leafBearingSections(await _primarySheetIds());
    final theorySections = await _leafBearingSections(await _activeTheoryIds());

    await _db.transaction(() async {
      await _db.delete(_db.roadmapTasks).go();
      await _db.delete(_db.roadmapPhases).go();

      // Pace: cover the whole primary sheet across the timeline. Skill nudges the
      // comfortable weekly capacity, and the actual per-week target is whichever
      // is larger — so a tight timeline honestly shows a heavier weekly load.
      final totalDsa = dsaSections.fold<int>(0, (s, e) => s + e.count);
      final comfortWeekly = (profile.dailyGoalProblems * 6 * skillFactor).round();
      final neededWeekly =
          totalWeeks == 0 ? totalDsa : (totalDsa / totalWeeks).ceil();
      final dsaPerWeek =
          (comfortWeekly > neededWeekly ? comfortWeekly : neededWeekly)
              .clamp(1, 1 << 30);

      // Pack sections into weeks by problem count.
      final weeks = <List<_Sec>>[];
      var cur = <_Sec>[];
      var curCount = 0;
      for (final sec in dsaSections) {
        cur.add(sec);
        curCount += sec.count;
        if (curCount >= dsaPerWeek) {
          weeks.add(cur);
          cur = [];
          curCount = 0;
        }
      }
      if (cur.isNotEmpty) weeks.add(cur);
      if (weeks.isEmpty) weeks.add(<_Sec>[]);
      final nWeeks = weeks.length;

      // Phase week counts (last phase absorbs the remainder).
      final phaseWeekCounts = <int>[];
      var assigned = 0;
      for (var p = 0; p < _phaseDefs.length; p++) {
        final c = p == _phaseDefs.length - 1
            ? nWeeks - assigned
            : (nWeeks * _phaseDefs[p].$3).round();
        final cc = c.clamp(0, nWeeks - assigned);
        phaseWeekCounts.add(cc);
        assigned += cc;
      }

      // Create phases and record which phase each week belongs to.
      final weekPhaseId = List<int>.filled(nWeeks, 0);
      var wk = 0;
      var cursor = now;
      for (var p = 0; p < _phaseDefs.length; p++) {
        final c = phaseWeekCounts[p];
        if (c == 0) continue;
        final start = cursor;
        final end = cursor.add(Duration(days: c * 7));
        cursor = end;
        final phaseId = await _db.into(_db.roadmapPhases).insert(
              RoadmapPhasesCompanion.insert(
                title: _phaseDefs[p].$1,
                subtitle: Value(_phaseDefs[p].$2),
                orderIndex: Value(p),
                startDate: start,
                endDate: end,
              ),
            );
        for (var k = 0; k < c && wk < nWeeks; k++) {
          weekPhaseId[wk] = phaseId;
          wk++;
        }
      }

      // Weekly tasks: a DSA chunk from the primary sheet + one theory item.
      for (var i = 0; i < nWeeks; i++) {
        final secs = weeks[i];
        final count = secs.fold<int>(0, (s, e) => s + e.count);
        final label = secs.isEmpty
            ? 'Revision & mock interviews'
            : secs.length <= 2
                ? secs.map((s) => s.title).join(' + ')
                : '${secs.first.title} → ${secs.last.title}';
        await _db.into(_db.roadmapTasks).insert(RoadmapTasksCompanion.insert(
              phaseId: weekPhaseId[i],
              weekIndex: Value(i),
              title: 'Week ${i + 1}: $label',
              category: const Value('dsa'),
              targetProblems: Value(count),
              targetMinutes: Value(count * 30),
              orderIndex: const Value(0),
            ));

        if (theorySections.isNotEmpty) {
          final t = theorySections[i % theorySections.length];
          await _db.into(_db.roadmapTasks).insert(RoadmapTasksCompanion.insert(
                phaseId: weekPhaseId[i],
                weekIndex: Value(i),
                title: 'Theory: ${t.title}',
                category: Value(t.category),
                targetProblems: Value(t.count),
                targetMinutes: Value(t.count * 12),
                orderIndex: const Value(1),
              ));
        }
      }
    });
  }

  Future<List<int>> _primarySheetIds() async {
    final userSheets = await _db.select(_db.userSheets).get();
    final primary = userSheets.where((u) => u.isPrimary).firstOrNull;
    if (primary != null) return [primary.sheetId];
    // Fallback: first active DSA sheet.
    final sheets = await (_db.select(_db.sheets)
          ..where((t) => t.category.equals('dsa'))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();
    final activeIds = userSheets.where((u) => u.active).map((u) => u.sheetId).toSet();
    final firstActive =
        sheets.where((s) => activeIds.contains(s.id)).firstOrNull ??
            sheets.firstOrNull;
    return firstActive == null ? [] : [firstActive.id];
  }

  Future<List<int>> _activeTheoryIds() async {
    final userSheets = await _db.select(_db.userSheets).get();
    final activeIds =
        userSheets.where((u) => u.active).map((u) => u.sheetId).toSet();
    final sheets = await (_db.select(_db.sheets)
          ..where((t) => t.category.isNotValue('dsa'))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();
    return sheets.where((s) => activeIds.contains(s.id)).map((s) => s.id).toList();
  }

  /// Returns the deepest (leaf-bearing) sections of the given sheets, in tree
  /// order, each with its direct-leaf count and category.
  Future<List<_Sec>> _leafBearingSections(List<int> sheetIds) async {
    final result = <_Sec>[];
    for (final sheetId in sheetIds) {
      final sheet = await (_db.select(_db.sheets)
            ..where((t) => t.id.equals(sheetId)))
          .getSingleOrNull();
      if (sheet == null) continue;
      final nodes = await (_db.select(_db.nodes)
            ..where((t) => t.sheetId.equals(sheetId)))
          .get();
      final byParent = <int?, List<Node>>{};
      for (final n in nodes) {
        byParent.putIfAbsent(n.parentId, () => []).add(n);
      }
      for (final list in byParent.values) {
        list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      }
      void dfs(Node node, String? parentTitle) {
        final children = byParent[node.id] ?? const [];
        final directLeaves = children.where((c) => c.kind == 'leaf').length;
        if (directLeaves > 0) {
          result.add(_Sec(
            title: parentTitle == null
                ? node.title
                : '$parentTitle · ${node.title}',
            count: directLeaves,
            category: sheet.category,
          ));
        }
        for (final c in children.where((c) => c.kind == 'section')) {
          dfs(c, node.title);
        }
      }

      for (final root in byParent[null] ?? const []) {
        dfs(root, null);
      }
    }
    return result;
  }

  // ---- Daily plan ---------------------------------------------------------

  Stream<List<DailyPlanItem>> watchTodayPlan() {
    final today = DayKey.today();
    return (_db.select(_db.dailyPlanItems)
          ..where((t) => t.day.equals(today))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .watch();
  }

  Future<void> toggleDailyItem(int id, bool done) async {
    await (_db.update(_db.dailyPlanItems)..where((t) => t.id.equals(id)))
        .write(DailyPlanItemsCompanion(done: Value(done)));
  }

  /// Builds today's plan if absent: due reviews + next unsolved from the primary
  /// sheet + one theory item, sized to the daily goal.
  Future<void> ensureTodayPlan(UserProfile profile, List<LeafRow> rows) async {
    final today = DayKey.today();
    final existing = await (_db.select(_db.dailyPlanItems)
          ..where((t) => t.day.equals(today)))
        .get();
    if (existing.isNotEmpty) return;

    final primaryIds = await _primarySheetIds();
    final primaryId = primaryIds.firstOrNull;

    final items = <DailyPlanItemsCompanion>[];
    var order = 0;
    final now = DateTime.now();

    final due = rows
        .where((r) =>
            r.progress?.nextReviewAt != null &&
            !r.progress!.nextReviewAt!.isAfter(now))
        .take(2);
    for (final r in due) {
      items.add(DailyPlanItemsCompanion.insert(
        day: today,
        title: 'Revise: ${r.node.title}',
        category: Value(r.category.name),
        estimatedMinutes: const Value(15),
        orderIndex: Value(order++),
      ));
    }

    final dsaTodo = rows.where((r) => r.category == PrepCategory.dsa && !r.isDone);
    final primaryDsa =
        primaryId == null ? dsaTodo : dsaTodo.where((r) => r.sheet.id == primaryId);
    final pick =
        (primaryDsa.isNotEmpty ? primaryDsa : dsaTodo).take(profile.dailyGoalProblems);
    for (final r in pick) {
      items.add(DailyPlanItemsCompanion.insert(
        day: today,
        title: 'Solve: ${r.node.title}',
        category: Value(PrepCategory.dsa.name),
        estimatedMinutes: Value(_estimateMinutes(r.difficulty)),
        orderIndex: Value(order++),
      ));
    }

    LeafRow? theory;
    for (final r in rows) {
      if ((r.category == PrepCategory.core ||
              r.category == PrepCategory.aptitude) &&
          !r.isDone) {
        theory = r;
        break;
      }
    }
    if (theory != null) {
      items.add(DailyPlanItemsCompanion.insert(
        day: today,
        title: 'Study: ${theory.node.title}',
        category: Value(theory.category.name),
        estimatedMinutes: const Value(25),
        orderIndex: Value(order++),
      ));
    }

    if (items.isEmpty) return;
    await _db.batch((b) => b.insertAll(_db.dailyPlanItems, items));
  }

  int _estimateMinutes(Difficulty d) => switch (d) {
        Difficulty.easy => 20,
        Difficulty.medium => 35,
        Difficulty.hard => 50,
      };
}

class _Sec {
  const _Sec({required this.title, required this.count, required this.category});
  final String title;
  final int count;
  final String category;
}
