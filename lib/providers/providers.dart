import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/constants/enums.dart';
import '../core/services/notification_service.dart';
import '../core/utils/day_key.dart';
import '../data/database/database.dart';
import '../data/models/dtos.dart';
import '../features/achievements/achievements.dart';
import '../features/leaderboard/leaderboard_backend.dart';
import '../features/leaderboard/leaderboard_models.dart';
import '../features/leaderboard/leaderboard_repository.dart';
import '../data/repositories/prep_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/seed_service.dart';
import '../features/ads/ad_config.dart';
import '../features/ads/rewarded_ad_gate.dart';
import '../features/planner/planner_effort.dart';
import '../features/planner/planner_engine.dart';
import '../features/planner/planner_models.dart';
import '../features/planner/planner_settings.dart';
import '../features/premium/premium_service.dart';
import '../features/study/ad_gate.dart';
import '../features/study/study_models.dart';
import '../features/study/study_repository.dart';
import '../features/timetable/timetable_models.dart';
import '../features/timetable/timetable_repository.dart';

export '../features/contests/contest_prefs.dart'
    show contestPrepProvider, todaysContestsProvider, upcomingContestsProvider;
export '../features/planner/planner_settings.dart'
    show plannerSettingsProvider;
export '../features/premium/premium_service.dart'
    show premiumProvider, premiumProductProvider, kPremiumProductId;
export '../features/study/quiz_results.dart' show quizResultsProvider, QuizResult;

// ---- Infrastructure -------------------------------------------------------

/// The data bucket for the current identity: a per-account key when signed in,
/// otherwise the shared "guest" bucket. Each key maps to its own database file,
/// so switching Google accounts never mixes one user's data into another's.
final dbKeyProvider = Provider<String>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  return user != null ? 'u_${user.id}' : 'guest';
});

final databaseProvider = Provider<AppDatabase>((ref) {
  // Rebuilding on a key change swaps the whole data layer to the new account's
  // database; every dependent provider re-reads from it automatically.
  final key = ref.watch(dbKeyProvider);
  final db = AppDatabase(dbKey: key);
  ref.onDispose(db.close);
  return db;
});

final seedServiceProvider =
    Provider((ref) => SeedService(ref.watch(databaseProvider)));
final profileRepositoryProvider =
    Provider((ref) => ProfileRepository(ref.watch(databaseProvider)));
final prepRepositoryProvider =
    Provider((ref) => PrepRepository(ref.watch(databaseProvider)));

// ---- Study content (notes + MCQs) + ad gate -------------------------------

/// The rewarded-ad gate for premium study actions. A single instance per app
/// session, so unlocks are remembered until the app is closed. Premium ("remove
/// ads") users skip the ad entirely; otherwise real AdMob rewarded ads on
/// device, falling back to the simulated gate elsewhere (desktop, tests).
final adGateProvider = Provider<AdGate>((ref) {
  // No ad when premium, or when ads are switched off entirely — content opens
  // straight away with no ad wall or placeholder.
  if (ref.watch(premiumProvider) || !AdConfig.enabled) return NoAdsGate();
  return RewardedAdGate();
});

/// Loads and caches all authored study packs (notes + MCQs).
final studyContentProvider = FutureProvider<StudyContent>(
    (ref) => const StudyRepository().load());

/// Synchronous view of the loaded study content (empty until it resolves).
final studyByCanonProvider = Provider<StudyContent>((ref) =>
    ref.watch(studyContentProvider).valueOrNull ?? StudyContent.empty);

final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(seedServiceProvider).ensureSeeded();
  // Prime the study content so notes/quiz affordances are ready on first paint.
  await ref.watch(studyContentProvider.future);
  // Load the remembered "browse as guest" choice before the first route is
  // decided, so returning guests don't flash the welcome screen.
  final p = await SharedPreferences.getInstance();
  ref.read(guestModeProvider.notifier).state = p.getBool('guest_mode') ?? false;
});

// ---- Session / auth gate --------------------------------------------------

/// Whether the user chose to browse as a guest (persisted in shared_prefs).
final guestModeProvider = StateProvider<bool>((ref) => false);

/// Persists and updates the guest-mode choice.
Future<void> setGuestMode(WidgetRef ref, bool value) async {
  final p = await SharedPreferences.getInstance();
  await p.setBool('guest_mode', value);
  ref.read(guestModeProvider.notifier).state = value;
}

/// Signs in with Google and clears guest mode. Returns null on success, or a
/// human-readable error message on failure. On success [authUserProvider] flips
/// and the router advances to onboarding (a new account) or the app shell (a
/// returning one). Shared by the welcome screen and the profile tab.
Future<String?> signInWithGoogleFlow(WidgetRef ref) async {
  final auth = ref.read(leaderboardAuthProvider);
  if (auth == null) return 'Google sign-in isn\'t available right now.';
  try {
    await auth.signInWithGoogle();
    await setGuestMode(ref, false);
    return null;
  } catch (e) {
    return 'Could not sign in: $e';
  }
}

/// Permanently deletes the signed-in user's account and ALL their data — cloud
/// (Supabase, via a cascading RPC) and on-device (the account's SQLite bucket +
/// remembered leaderboard identity) — then signs out and returns to the welcome
/// screen. Returns null on success, or a human-readable error (in which case
/// local data is left intact so the user can retry). Satisfies Google Play's
/// in-app account-deletion requirement.
Future<String?> deleteAccountAndData(WidgetRef ref) async {
  final repo = ref.read(leaderboardRepositoryProvider);
  final auth = ref.read(leaderboardAuthProvider);
  final dbKey = ref.read(dbKeyProvider); // 'u_<uid>' while still signed in
  try {
    // 1. Delete the cloud account first; if this fails, keep local data so the
    //    user isn't left half-deleted and can try again.
    if (repo.isLive) await repo.deleteAccount();
    // 2. Wipe local rows on the live connection (content gone even if the file
    //    can't be removed yet on this platform).
    await ref.read(databaseProvider).wipeAllData();
    // 3. Forget the remembered name/college for this account.
    await LbIdentity.clear(scope: dbKey);
    // 4. Sign out → authUser flips to null → the DB bucket switches to guest and
    //    the old connection is disposed (closed).
    await auth?.signOut();
    // 5. Best-effort removal of the now-orphaned on-disk file.
    await deleteDatabaseFileForKey(dbKey);
    // 6. Land on the welcome screen and refresh identity-scoped providers.
    await setGuestMode(ref, false);
    ref.invalidate(lbIdentityProvider);
    ref.invalidate(boardPoolProvider);
    return null;
  } catch (e) {
    return 'Could not delete account: $e';
  }
}

/// Wipes all on-device data for a guest (no cloud account exists) and returns to
/// the welcome screen. The guest bucket is reused and re-seeded on return.
Future<void> deleteGuestData(WidgetRef ref) async {
  final dbKey = ref.read(dbKeyProvider); // 'guest'
  await ref.read(databaseProvider).wipeAllData();
  await LbIdentity.clear(scope: dbKey);
  await setGuestMode(ref, false);
  ref.invalidate(lbIdentityProvider);
  ref.invalidate(boardPoolProvider);
}

/// Silently re-syncs all verified coding platforms in the background (no UI /
/// no toast). Called once per app open when signed in, so stats stay fresh
/// without the user pressing "Re-sync".
Future<void> backgroundSyncPlatforms(WidgetRef ref) async {
  final repo = ref.read(leaderboardRepositoryProvider);
  if (!repo.isLive) return;
  if (ref.read(authUserProvider).valueOrNull == null) return;
  final platforms = await repo.myPlatforms();
  var synced = false;
  for (final p in platforms) {
    if (!p.verified) continue;
    try {
      await repo.verifyPlatform(p.platform, p.handle);
      synced = true;
    } catch (_) {}
  }
  if (synced) {
    ref.invalidate(boardPoolProvider);
    ref.invalidate(myPlatformsProvider);
    ref.invalidate(myEntryProvider);
    ref.invalidate(myContestsProvider);
  }
}

enum SessionState { signedIn, guest, needsAuth }

/// Top-level session state that decides the welcome/app routing.
final sessionStateProvider = Provider<SessionState>((ref) {
  final signedIn = ref.watch(authUserProvider).valueOrNull != null;
  if (signedIn) return SessionState.signedIn;
  final guest = ref.watch(guestModeProvider);
  return guest ? SessionState.guest : SessionState.needsAuth;
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

// ---- Deadline planner -----------------------------------------------------

// ---- Daily timetable ------------------------------------------------------

final timetableRepositoryProvider =
    Provider((ref) => TimetableRepository(ref.watch(databaseProvider)));

/// Every timetable block, ordered by start time.
final timetableProvider = StreamProvider<List<TimetableBlock>>(
    (ref) => ref.watch(timetableRepositoryProvider).watchBlocks());

/// The blocks that run today, in order.
final todayTimetableProvider = Provider<List<TimetableBlock>>((ref) {
  final all = ref.watch(timetableProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  return [
    for (final b in all)
      if (b.enabled && Weekdays.runsOn(b.daysMask, now)) b,
  ];
});

/// Today's block that is either running now or is the next one due.
final currentBlockProvider = Provider<TimetableBlock?>((ref) {
  final today = ref.watch(todayTimetableProvider);
  if (today.isEmpty) return null;
  final now = DateTime.now();
  final minute = now.hour * 60 + now.minute;
  for (final b in today) {
    if (minute < b.startMinute + b.durationMinutes) return b;
  }
  return null;
});

/// Re-schedules every timetable reminder from the current blocks. Call after
/// any edit; safe to call when notifications aren't permitted (it no-ops at the
/// OS level rather than throwing).
Future<void> syncTimetableReminders(WidgetRef ref) async {
  final blocks = await ref.read(timetableRepositoryProvider).allBlocks();
  await NotificationService.instance.syncTimetableReminders(blocks);
}

/// Item count and estimated effort for one sheet.
class SheetEffort {
  const SheetEffort({required this.items, required this.minutes});
  final int items;
  final int minutes;

  double get hours => minutes / 60.0;
}

/// Items + estimated minutes for EVERY sheet, keyed by sheet id.
///
/// Lets the onboarding and sheet pickers show the real cost of a selection
/// ("455 problems · ~202 h") before the user commits to it, instead of
/// discovering months later that the plan never fit.
final sheetEffortProvider = Provider<Map<int, SheetEffort>>((ref) {
  final rows = ref.watch(leafRowsProvider);
  final items = <int, int>{};
  final minutes = <int, int>{};
  for (final r in rows) {
    final id = r.sheet.id;
    items[id] = (items[id] ?? 0) + 1;
    minutes[id] = (minutes[id] ?? 0) +
        PlanEffort.forLeaf(isConcept: r.isConcept, difficulty: r.difficulty);
  }
  return {
    for (final id in items.keys)
      id: SheetEffort(items: items[id]!, minutes: minutes[id]!),
  };
});

/// Each active sheet as a planner "subject", with its leaves flattened into the
/// sheet's real tree (section → sub-section) order so "next in sequence" is
/// correct. Grouped/ordered by the sheet's own order index.
final plannerSubjectsProvider = Provider<List<SubjectInput>>((ref) {
  final nodes = ref.watch(nodesProvider);
  final sheetsById = ref.watch(sheetsByIdProvider);
  final byCanon = ref.watch(progressByCanonProvider);
  final activeIds = ref.watch(activeSheetIdsProvider);
  if (activeIds.isEmpty || nodes.isEmpty) return const [];

  final nodesBySheet = <int, List<Node>>{};
  for (final n in nodes) {
    if (!activeIds.contains(n.sheetId)) continue;
    nodesBySheet.putIfAbsent(n.sheetId, () => []).add(n);
  }

  void flatten(TreeNode t, List<LeafRow> out) {
    if (t.isLeaf) {
      if (t.leaf != null) out.add(t.leaf!);
    } else {
      for (final c in t.children) {
        flatten(c, out);
      }
    }
  }

  final subjects = <SubjectInput>[];
  for (final entry in nodesBySheet.entries) {
    final sheet = sheetsById[entry.key];
    if (sheet == null) continue;
    final tree = PrepRepository.buildSheetTree(entry.value, sheet, byCanon);
    final ordered = <LeafRow>[];
    for (final t in tree) {
      flatten(t, ordered);
    }
    if (ordered.isEmpty) continue;
    subjects.add(SubjectInput(
      slug: sheet.slug,
      title: sheet.title,
      category: PrepCategory.fromName(sheet.category),
      sheetId: sheet.id,
      leaves: [
        for (final r in ordered)
          PlanLeaf(
            canon: r.canon,
            title: r.node.title,
            difficulty: r.difficulty,
            isConcept: r.isConcept,
            isDone: r.isDone,
            solvedAt: r.progress?.solvedAt,
          ),
      ],
    ));
  }
  // Stable, meaningful order: by the sheet's own order index.
  final orderById = {for (final s in sheetsById.values) s.id: s.orderIndex};
  subjects.sort((a, b) =>
      (orderById[a.sheetId] ?? 0).compareTo(orderById[b.sheetId] ?? 0));
  return subjects;
});

/// The live, deadline-driven plan: per-subject pace, projected finish, on-track
/// state and today's targets. Recomputes as progress, sheet selection, the
/// deadline, or a pace override changes.
final plannerOverviewProvider = Provider<PlanOverview>((ref) {
  final subjects = ref.watch(plannerSubjectsProvider);
  final profile = ref.watch(profileProvider).valueOrNull;
  final paces = ref.watch(plannerSettingsProvider);
  final now = DateTime.now();
  final start = profile?.createdAt ?? now;
  final deadline = profile?.targetDate ?? now.add(const Duration(days: 84));
  return PlannerEngine.compute(
    subjects: subjects,
    start: start,
    deadline: deadline,
    now: now,
    plannedPaceFor: (slug) => paces[slug],
    // The daily study budget turns this into an effort-based plan: targets are
    // sized by real minutes of work, not by counting unequal items.
    dailyMinutes: profile?.dailyGoalMinutes ?? 120,
  );
});

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

/// The Supabase client, or null if not configured/initialized.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

/// Live Supabase repository when configured, else the sample-data stub.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client != null
      ? SupabaseLeaderboardRepository(client)
      : StubLeaderboardRepository();
});

final leaderboardAuthProvider = Provider<LeaderboardAuth?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : LeaderboardAuth(client);
});

/// The signed-in user (null when signed out or backend unavailable).
final authUserProvider = StreamProvider<User?>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield null;
    return;
  }
  yield client.auth.currentUser;
  await for (final state in client.auth.onAuthStateChange) {
    yield state.session?.user;
  }
});

/// Locally-remembered leaderboard identity (display name + college), scoped to
/// the current account so it never bleeds across Google logins.
final lbIdentityProvider = FutureProvider<LbIdentity>((ref) async {
  final appName = ref.watch(profileProvider).valueOrNull?.name ?? 'You';
  final scope = ref.watch(dbKeyProvider);
  return LbIdentity.load(appName, scope: scope);
});

/// Saves the leaderboard identity (name + college) for the CURRENT account and
/// refreshes anything that reads it.
Future<void> saveLbIdentity(WidgetRef ref, String name, String? college) async {
  final scope = ref.read(dbKeyProvider);
  await LbIdentity.save(name, college, scope: scope);
  ref.invalidate(lbIdentityProvider);
}

/// The signed-in user's linked coding platforms (with verified stats).
final myPlatformsProvider = FutureProvider<List<PlatformInfo>>((ref) async {
  ref.watch(authUserProvider);
  return ref.watch(leaderboardRepositoryProvider).myPlatforms();
});

/// The signed-in user's own aggregated leaderboard row (score + totals).
final myEntryProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  ref.watch(authUserProvider);
  ref.watch(boardPoolProvider(LeaderboardScope.global)); // refresh after sync
  return ref.watch(leaderboardRepositoryProvider).myEntry();
});

/// The signed-in user's contest history across linked platforms.
final myContestsProvider = FutureProvider<List<ContestEntry>>((ref) async {
  ref.watch(authUserProvider);
  ref.watch(myPlatformsProvider); // refresh after a link/verify
  return ref.watch(leaderboardRepositoryProvider).contests();
});

/// The signed-in user's profile / social links.
final mySocialLinksProvider = FutureProvider<List<SocialLink>>((ref) async {
  ref.watch(authUserProvider);
  return ref.watch(leaderboardRepositoryProvider).socialLinks();
});

/// The signed-in user's portfolio projects.
final myProjectsProvider = FutureProvider<List<ProjectItem>>((ref) async {
  ref.watch(authUserProvider);
  return ref.watch(leaderboardRepositoryProvider).projects();
});

final boardPoolProvider =
    FutureProvider.family<List<LeaderboardEntry>, LeaderboardScope>(
        (ref, scope) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  final me = ref.watch(myStatsProvider);
  ref.watch(authUserProvider); // refresh when auth changes
  final id = await ref.watch(lbIdentityProvider.future);
  return repo.pool(scope, me: me, myName: id.name, myCollege: id.college);
});

/// UI theme mode: 0=system, 1=light, 2=dark.
final themeModeProvider = StateProvider<int>((ref) => 0);
