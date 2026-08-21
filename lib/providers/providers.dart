import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/enums.dart';
import '../core/utils/day_key.dart';
import '../data/database/database.dart';
import '../data/models/dtos.dart';
import '../features/achievements/achievements.dart';
import '../features/leaderboard/leaderboard_models.dart';
import '../features/leaderboard/leaderboard_repository.dart';
import '../data/repositories/prep_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/roadmap_repository.dart';
import '../data/repositories/seed_service.dart';

// ---- Infrastructure -------------------------------------------------------

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final seedServiceProvider =
    Provider((ref) => SeedService(ref.watch(databaseProvider)));
final profileRepositoryProvider =
    Provider((ref) => ProfileRepository(ref.watch(databaseProvider)));
final prepRepositoryProvider =
    Provider((ref) => PrepRepository(ref.watch(databaseProvider)));
final roadmapRepositoryProvider =
    Provider((ref) => RoadmapRepository(ref.watch(databaseProvider)));

final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(seedServiceProvider).ensureSeeded();
});

// ---- Profile --------------------------------------------------------------

final profileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(profileRepositoryProvider).watch();
});

// ---- Raw content streams --------------------------------------------------

final _nodesProvider = StreamProvider<List<Node>>(
    (ref) => ref.watch(prepRepositoryProvider).watchNodes());
final sheetsProvider = StreamProvider<List<Sheet>>(
    (ref) => ref.watch(prepRepositoryProvider).watchSheets());
final _progressProvider = StreamProvider<List<LeafProgressData>>(
    (ref) => ref.watch(prepRepositoryProvider).watchProgress());
final userSheetsProvider = StreamProvider<List<UserSheet>>(
    (ref) => ref.watch(prepRepositoryProvider).watchUserSheets());

final sheetsByIdProvider = Provider<Map<int, Sheet>>((ref) {
  final sheets = ref.watch(sheetsProvider).valueOrNull ?? const [];
  return {for (final s in sheets) s.id: s};
});

final nodesProvider = Provider<List<Node>>(
    (ref) => ref.watch(_nodesProvider).valueOrNull ?? const []);

final progressByCanonProvider = Provider<Map<String, LeafProgressData>>((ref) {
  final p = ref.watch(_progressProvider).valueOrNull ?? const [];
  return {for (final x in p) x.canon: x};
});

final activeSheetIdsProvider = Provider<Set<int>>((ref) {
  final us = ref.watch(userSheetsProvider).valueOrNull ?? const [];
  return us.where((u) => u.active).map((u) => u.sheetId).toSet();
});

/// All leaf rows (every sheet), joined with sheet + section + progress.
final leafRowsProvider = Provider<List<LeafRow>>((ref) {
  final nodes = ref.watch(_nodesProvider).valueOrNull ?? const [];
  final sheetsById = ref.watch(sheetsByIdProvider);
  final progress = ref.watch(_progressProvider).valueOrNull ?? const [];
  final byCanon = {for (final p in progress) p.canon: p};
  return PrepRepository.leafRowsFrom(nodes, sheetsById, byCanon);
});

/// Leaf rows restricted to the user's active sheets.
final activeLeafRowsProvider = Provider<List<LeafRow>>((ref) {
  final rows = ref.watch(leafRowsProvider);
  final active = ref.watch(activeSheetIdsProvider);
  if (active.isEmpty) return rows; // before selection exists, show all
  return rows.where((r) => active.contains(r.sheet.id)).toList();
});

// ---- Derived --------------------------------------------------------------

final sheetSummariesProvider = Provider<List<SheetSummary>>((ref) {
  final rows = ref.watch(leafRowsProvider);
  final active = ref.watch(activeSheetIdsProvider);
  return PrepRepository.summariesFrom(rows, active);
});

final statsProvider = Provider<PrepStats>((ref) {
  return PrepRepository.statsFrom(ref.watch(activeLeafRowsProvider));
});

final dueForReviewProvider = Provider<List<LeafRow>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(activeLeafRowsProvider)
      .where((r) =>
          r.progress?.nextReviewAt != null &&
          !r.progress!.nextReviewAt!.isAfter(now))
      .toList();
});

// ---- Activity, streak, sessions ------------------------------------------

final activityProvider = StreamProvider<List<ActivityDay>>(
    (ref) => ref.watch(prepRepositoryProvider).watchActivity());

final streakProvider = Provider<StreakInfo>((ref) {
  final activity = ref.watch(activityProvider).valueOrNull ?? const [];
  return PrepRepository.streakFrom(activity);
});

final recentSessionsProvider = StreamProvider<List<StudySession>>(
    (ref) => ref.watch(prepRepositoryProvider).watchRecentSessions());

// ---- Roadmap + daily plan -------------------------------------------------

final phasesProvider = StreamProvider<List<RoadmapPhase>>(
    (ref) => ref.watch(roadmapRepositoryProvider).watchPhases());
final roadmapTasksProvider = StreamProvider<List<RoadmapTask>>(
    (ref) => ref.watch(roadmapRepositoryProvider).watchTasks());
final todayPlanProvider = StreamProvider<List<DailyPlanItem>>(
    (ref) => ref.watch(roadmapRepositoryProvider).watchTodayPlan());

final resourcesProvider = StreamProvider<List<Resource>>(
    (ref) => ref.watch(prepRepositoryProvider).watchResources());

/// Company → number of tagged problems, across active sheets.
final companyCountsProvider = Provider<Map<String, int>>((ref) {
  final rows = ref.watch(activeLeafRowsProvider);
  final m = <String, int>{};
  for (final r in rows) {
    final c = r.node.companies;
    if (c.isEmpty) continue;
    for (final raw in c.split(',')) {
      final name = raw.trim();
      if (name.length < 2) continue;
      m.update(name, (v) => v + 1, ifAbsent: () => 1);
    }
  }
  return m;
});

final achStatsProvider = Provider<AchStats>((ref) {
  final stats = ref.watch(statsProvider);
  final streak = ref.watch(streakProvider);
  final activity = ref.watch(activityProvider).valueOrNull ?? const [];
  return AchStats(
    solved: stats.totalDone,
    hardSolved: stats.doneByDifficulty[Difficulty.hard] ?? 0,
    categoriesCovered: stats.byCategory.where((c) => c.done > 0).length,
    longestStreak: streak.longest,
    goalDays: activity.where((a) => a.goalMet).length,
    totalMinutes: activity.fold<int>(0, (s, a) => s + a.minutes),
  );
});

// ---- Leaderboard ----------------------------------------------------------

final myStatsProvider = Provider<MyStats>((ref) {
  final stats = ref.watch(statsProvider);
  final streak = ref.watch(streakProvider);
  final activity = ref.watch(activityProvider).valueOrNull ?? const [];
  final profile = ref.watch(profileProvider).valueOrNull;
  final now = DateTime.now();
  final weekStart =
      DayKey.fromDate(now.subtract(Duration(days: now.weekday - 1)));
  var wSolved = 0, wMin = 0;
  for (final a in activity) {
    if (a.day >= weekStart) {
      wSolved += a.problemsSolved;
      wMin += a.minutes;
    }
  }
  return MyStats(
    totalSolved: stats.totalDone,
    currentStreak: streak.current,
    longestStreak: streak.longest,
    xp: profile?.xp ?? 0,
    weeklySolved: wSolved,
    weeklyMinutes: wMin,
  );
});

/// Swap this for a Supabase-backed repository once the project keys are wired.
final leaderboardRepositoryProvider =
    Provider<LeaderboardRepository>((ref) => StubLeaderboardRepository());

final boardPoolProvider =
    FutureProvider.family<List<LeaderboardEntry>, LeaderboardScope>(
        (ref, scope) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  final me = ref.watch(myStatsProvider);
  final name = ref.watch(profileProvider).valueOrNull?.name ?? 'You';
  return repo.pool(scope, me: me, myName: name, myCollege: null);
});

/// UI theme mode: 0=system, 1=light, 2=dark.
final themeModeProvider = StateProvider<int>((ref) => 0);
