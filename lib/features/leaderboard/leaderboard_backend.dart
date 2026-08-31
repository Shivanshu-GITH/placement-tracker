import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import 'leaderboard_models.dart';
import 'leaderboard_repository.dart';

/// yyyyww key used to scope the weekly board so it resets each week.
int weekKeyOf(DateTime d) {
  final startOfYear = DateTime(d.year, 1, 1);
  final days = d.difference(startOfYear).inDays;
  final week = ((days + startOfYear.weekday - 1) / 7).floor() + 1;
  return d.year * 100 + week;
}

/// Locally-remembered leaderboard identity (display name + college).
class LbIdentity {
  const LbIdentity({required this.name, this.college});
  final String name;
  final String? college;

  /// The [scope] namespaces the stored identity per account (e.g. the account
  /// key), so switching Google accounts doesn't show the previous user's name
  /// or college. Omit for the legacy/global identity.
  static Future<LbIdentity> load(String fallbackName, {String? scope}) async {
    final p = await SharedPreferences.getInstance();
    final s = _suffix(scope);
    return LbIdentity(
      name: p.getString('lb_name$s') ?? fallbackName,
      college: p.getString('lb_college$s'),
    );
  }

  static Future<void> save(String name, String? college, {String? scope}) async {
    final p = await SharedPreferences.getInstance();
    final s = _suffix(scope);
    await p.setString('lb_name$s', name);
    if (college == null || college.isEmpty) {
      await p.remove('lb_college$s');
    } else {
      await p.setString('lb_college$s', college);
    }
  }

  /// Forgets the remembered name + college for a [scope] (used when deleting an
  /// account or wiping guest data).
  static Future<void> clear({String? scope}) async {
    final p = await SharedPreferences.getInstance();
    final s = _suffix(scope);
    await p.remove('lb_name$s');
    await p.remove('lb_college$s');
  }

  static String _suffix(String? scope) =>
      (scope == null || scope.isEmpty) ? '' : '_$scope';
}

/// Thin wrapper over Supabase auth for the leaderboard, backed by Google
/// Sign-In (native ID-token flow — no web redirect).
class LeaderboardAuth {
  LeaderboardAuth(this._sb);
  final SupabaseClient _sb;

  // GoogleSignIn.initialize() must run exactly once per process.
  static bool _googleReady = false;

  User? get user => _sb.auth.currentUser;
  bool get isSignedIn => user != null;

  /// Signs in with Google and exchanges the returned ID token for a Supabase
  /// session. Returns the Google display name (if any) so the caller can
  /// prefill it. Throws with a readable message on failure.
  Future<String?> signInWithGoogle() async {
    final serverClientId = AppConfig.googleServerClientId;
    if (serverClientId.isEmpty) {
      throw 'Google Sign-In is not configured yet.';
    }
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: serverClientId);
      _googleReady = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw 'Google did not return an ID token.';
    }
    await _sb.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    return account.displayName;
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _sb.auth.signOut();
  }
}

/// Live leaderboard backed by Supabase (reads the `leaderboard` view, upserts
/// the signed-in user's own profile + stats).
class SupabaseLeaderboardRepository implements LeaderboardRepository {
  SupabaseLeaderboardRepository(this._sb);
  final SupabaseClient _sb;

  @override
  bool get isLive => true;

  String? get _uid => _sb.auth.currentUser?.id;

  LeaderboardEntry _fromRow(Map<String, dynamic> r, String? uid) =>
      LeaderboardEntry(
        rank: 0,
        userId: r['id'] as String,
        name: (r['name'] ?? 'Aspirant') as String,
        avatarUrl: r['avatar_url'] as String?,
        college: r['college'] as String?,
        prepScore: (r['prep_score'] ?? 0) as int,
        verifiedSolved: (r['verified_solved'] ?? 0) as int,
        rating: (r['rating'] ?? 0) as int,
        extStreak: (r['ext_streak'] ?? 0) as int,
        verifiedPlatforms: (r['verified_platforms'] ?? 0) as int,
        solved: (r['app_solved'] ?? 0) as int,
        streak: (r['current_streak'] ?? 0) as int,
        xp: (r['xp'] ?? 0) as int,
        weeklySolved: (r['weekly_solved'] ?? 0) as int,
        profileViews: (r['profile_views'] ?? 0) as int,
        country: r['country'] as String?,
        platformRatings: {
          if (((r['leetcode_rating'] ?? 0) as int) > 0)
            'leetcode': r['leetcode_rating'] as int,
          if (((r['codeforces_rating'] ?? 0) as int) > 0)
            'codeforces': r['codeforces_rating'] as int,
          if (((r['codechef_rating'] ?? 0) as int) > 0)
            'codechef': r['codechef_rating'] as int,
          if (((r['atcoder_rating'] ?? 0) as int) > 0)
            'atcoder': r['atcoder_rating'] as int,
        },
        isMe: r['id'] == uid,
      );

  @override
  Future<List<LeaderboardEntry>> pool(
    LeaderboardScope scope, {
    required MyStats me,
    required String myName,
    String? myCollege,
  }) async {
    final uid = _uid;
    List<Map<String, dynamic>> rows = const [];
    try {
      switch (scope) {
        case LeaderboardScope.global:
          rows = await _sb
              .from('leaderboard')
              .select()
              .order('prep_score', ascending: false)
              .limit(200);
        case LeaderboardScope.country:
          String country = 'India';
          if (uid != null) {
            try {
              final my = await _sb
                  .from('profiles')
                  .select('country')
                  .eq('id', uid)
                  .maybeSingle();
              country = (my?['country'] as String?) ?? 'India';
            } catch (_) {}
          }
          rows = await _sb
              .from('leaderboard')
              .select()
              .eq('country', country)
              .order('prep_score', ascending: false)
              .limit(200);
        case LeaderboardScope.college:
          if (myCollege == null || myCollege.isEmpty) {
            rows = const [];
          } else {
            rows = await _sb
                .from('leaderboard')
                .select()
                .eq('college', myCollege)
                .order('prep_score', ascending: false)
                .limit(200);
          }
        case LeaderboardScope.friends:
          if (uid == null) {
            rows = const [];
          } else {
            final f = await _sb
                .from('follows')
                .select('following_id')
                .eq('follower_id', uid);
            final ids = [for (final x in (f as List)) x['following_id'] as String, uid];
            rows = await _sb.from('leaderboard').select().inFilter('id', ids);
          }
      }
    } catch (_) {
      rows = const [];
    }

    final entries = [for (final r in rows) _fromRow(r, uid)];
    // Show the current user (using local stats if the server row isn't synced
    // yet) ONLY when signed in. Guests can browse the board but never appear.
    if (uid != null && !entries.any((e) => e.isMe)) {
      entries.add(LeaderboardEntry(
        rank: 0,
        userId: uid,
        name: myName,
        college: myCollege,
        solved: me.totalSolved,
        streak: me.currentStreak,
        xp: me.xp,
        weeklySolved: me.weeklySolved,
        isMe: true,
      ));
    }
    return entries;
  }

  @override
  Future<List<LeaderboardEntry>> searchUsers(String query) async {
    final uid = _uid;
    final q = query.trim();
    if (q.isEmpty) return const [];
    try {
      final rows = await _sb
          .from('leaderboard')
          .select()
          .ilike('name', '%$q%')
          .limit(30);
      return [
        for (final r in rows)
          if (r['id'] != uid) _fromRow(r, uid),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Set<String>> followingIds() async {
    final uid = _uid;
    if (uid == null) return <String>{};
    try {
      final rows =
          await _sb.from('follows').select('following_id').eq('follower_id', uid);
      return {for (final r in (rows as List)) r['following_id'] as String};
    } catch (_) {
      return <String>{};
    }
  }

  @override
  Future<void> follow(String userId) async {
    final uid = _uid;
    if (uid == null || userId == uid) return;
    await _sb.from('follows').upsert({
      'follower_id': uid,
      'following_id': userId,
    });
  }

  @override
  Future<void> unfollow(String userId) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb
        .from('follows')
        .delete()
        .eq('follower_id', uid)
        .eq('following_id', userId);
  }

  @override
  Future<void> syncMyStats(MyStats stats,
      {required String name, String? college}) async {
    final uid = _uid;
    if (uid == null) return;
    // Note: country isn't set here — the profiles.country column defaults to
    // 'India' (see the ratings/country migration), so new rows get it for free
    // and this upsert stays resilient before that migration is applied.
    await _sb.from('profiles').upsert({
      'id': uid,
      'name': name,
      if (college != null && college.isNotEmpty) 'college': college,
    });
    await _sb.from('stats').upsert({
      'user_id': uid,
      'total_solved': stats.totalSolved,
      'current_streak': stats.currentStreak,
      'longest_streak': stats.longestStreak,
      'xp': stats.xp,
      'weekly_solved': stats.weeklySolved,
      'weekly_minutes': stats.weeklyMinutes,
      'week_key': weekKeyOf(DateTime.now()),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<LeaderboardEntry?> myEntry() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final row = await _sb.from('leaderboard').select().eq('id', uid).maybeSingle();
      if (row == null) return null;
      return _fromRow(row, uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PlatformInfo>> myPlatforms() async {
    final uid = _uid;
    if (uid == null) return const [];
    return _platformsFor(uid);
  }

  @override
  Future<List<PlatformInfo>> platformsOf(String userId) => _platformsFor(userId);

  static Map<String, int> _intMap(dynamic v) {
    if (v is Map) {
      return {for (final e in v.entries) e.key.toString(): (e.value as num).toInt()};
    }
    return const {};
  }

  Future<List<PlatformInfo>> _platformsFor(String uid) async {
    try {
      final links =
          await _sb.from('platform_links').select('platform, handle').eq('user_id', uid);
      final stats = await _sb
          .from('platform_stats')
          .select('platform, verified, solved, rating, streak')
          .eq('user_id', uid);
      final byPlatform = {
        for (final s in (stats as List)) s['platform'] as String: s,
      };
      // Two extra tiers, each guarded so platforms still load before the
      // GitHub / portfolio migrations have been applied.
      Map<String, dynamic> dev1 = {}; // GitHub migration columns
      try {
        final r = await _sb
            .from('platform_stats')
            .select('platform, repos, stars, contributions')
            .eq('user_id', uid);
        dev1 = {for (final s in (r as List)) s['platform'] as String: s};
      } catch (_) {}
      Map<String, dynamic> dev2 = {}; // portfolio migration columns
      try {
        final r = await _sb
            .from('platform_stats')
            .select(
                'platform, commits, prs, issues, active_days, max_streak, daily, languages')
            .eq('user_id', uid);
        dev2 = {for (final s in (r as List)) s['platform'] as String: s};
      } catch (_) {}
      return [
        for (final l in (links as List))
          () {
            final p = l['platform'] as String;
            final s = byPlatform[p];
            final a = dev1[p];
            final b = dev2[p];
            return PlatformInfo(
              platform: p,
              handle: (l['handle'] ?? '') as String,
              verified: (s?['verified'] ?? false) as bool,
              solved: (s?['solved'] ?? 0) as int,
              rating: (s?['rating'] ?? 0) as int,
              streak: (s?['streak'] ?? 0) as int,
              maxStreak: (b?['max_streak'] ?? 0) as int,
              activeDays: (b?['active_days'] ?? 0) as int,
              daily: _intMap(b?['daily']),
              repos: (a?['repos'] ?? 0) as int,
              stars: (a?['stars'] ?? 0) as int,
              contributions: (a?['contributions'] ?? 0) as int,
              commits: (b?['commits'] ?? 0) as int,
              prs: (b?['prs'] ?? 0) as int,
              issues: (b?['issues'] ?? 0) as int,
              languages: _intMap(b?['languages']),
            );
          }(),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<LeaderboardEntry?> entryOf(String userId) async {
    try {
      final row =
          await _sb.from('leaderboard').select().eq('id', userId).maybeSingle();
      if (row == null) return null;
      return _fromRow(row, _uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ContestEntry>> contests([String? userId]) async {
    final uid = userId ?? _uid;
    if (uid == null) return const [];
    try {
      final rows = await _sb
          .from('contest_history')
          .select('platform, contest, rank, rating, held_at')
          .eq('user_id', uid)
          .order('held_at', ascending: true);
      return [
        for (final r in (rows as List))
          ContestEntry(
            platform: r['platform'] as String,
            contest: (r['contest'] ?? '') as String,
            rank: r['rank'] as int?,
            rating: r['rating'] as int?,
            heldAt: r['held_at'] != null
                ? DateTime.tryParse(r['held_at'] as String)
                : null,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<SocialLink>> socialLinks([String? userId]) async {
    final uid = userId ?? _uid;
    if (uid == null) return const [];
    try {
      final rows = await _sb
          .from('social_links')
          .select('kind, url')
          .eq('user_id', uid);
      return [
        for (final r in (rows as List))
          SocialLink(kind: r['kind'] as String, url: (r['url'] ?? '') as String),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> setSocialLink(String kind, String url) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.from('social_links').upsert({'user_id': uid, 'kind': kind, 'url': url});
  }

  @override
  Future<void> removeSocialLink(String kind) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.from('social_links').delete().eq('user_id', uid).eq('kind', kind);
  }

  @override
  Future<List<ProjectItem>> projects([String? userId]) async {
    final uid = userId ?? _uid;
    if (uid == null) return const [];
    try {
      final rows = await _sb
          .from('projects')
          .select()
          .eq('user_id', uid)
          .order('order_index', ascending: true);
      return [
        for (final r in (rows as List))
          ProjectItem(
            id: r['id'] as String,
            title: (r['title'] ?? '') as String,
            description: r['description'] as String?,
            repoUrl: r['repo_url'] as String?,
            demoUrl: r['demo_url'] as String?,
            imageUrl: r['image_url'] as String?,
            tech: r['tech'] as String?,
            orderIndex: (r['order_index'] ?? 0) as int,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> addProject(ProjectItem p) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.from('projects').insert({
      'user_id': uid,
      'title': p.title,
      'description': p.description,
      'repo_url': p.repoUrl,
      'demo_url': p.demoUrl,
      'image_url': p.imageUrl,
      'tech': p.tech,
      'order_index': p.orderIndex,
    });
  }

  @override
  Future<void> updateProject(ProjectItem p) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.from('projects').update({
      'title': p.title,
      'description': p.description,
      'repo_url': p.repoUrl,
      'demo_url': p.demoUrl,
      'image_url': p.imageUrl,
      'tech': p.tech,
      'order_index': p.orderIndex,
    }).eq('id', p.id).eq('user_id', uid);
  }

  @override
  Future<void> deleteProject(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.from('projects').delete().eq('id', id).eq('user_id', uid);
  }

  @override
  Future<void> incrementProfileView(String userId) async {
    try {
      await _sb.rpc('increment_profile_views', params: {'target': userId});
    } catch (_) {}
  }

  @override
  Future<String> linkPlatform(String platform, String handle) async {
    final uid = _uid;
    if (uid == null) throw 'Not signed in';
    final token = _genToken();
    await _sb.from('platform_links').upsert({
      'user_id': uid,
      'platform': platform,
      'handle': handle.trim(),
      'verify_token': token,
    });
    return token;
  }

  @override
  Future<PlatformVerifyResult> verifyPlatform(
      String platform, String handle) async {
    try {
      final res = await _sb.functions.invoke('verify-platform',
          body: {'platform': platform, 'handle': handle.trim()});
      final data = (res.data as Map).cast<String, dynamic>();
      return PlatformVerifyResult(
        verified: (data['verified'] ?? false) as bool,
        solved: (data['solved'] ?? 0) as int,
        rating: (data['rating'] ?? 0) as int,
        streak: (data['streak'] ?? 0) as int,
        error: data['error'] as String?,
      );
    } catch (e) {
      return PlatformVerifyResult(verified: false, error: '$e');
    }
  }

  @override
  Future<void> unlinkPlatform(String platform) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb
        .from('platform_links')
        .delete()
        .eq('user_id', uid)
        .eq('platform', platform);
    try {
      await _sb
          .from('platform_stats')
          .delete()
          .eq('user_id', uid)
          .eq('platform', platform);
    } catch (_) {
      // stats row may be absent; ignore.
    }
  }

  @override
  Future<void> deleteAccount() async {
    if (_uid == null) return;
    // Deletes the auth.users row via a SECURITY DEFINER RPC; every user table
    // cascades from it, so this removes the account and all cloud data at once.
    // See docs/supabase_migration_account_deletion.sql.
    await _sb.rpc('delete_account');
  }

  String _genToken() {
    final rnd = Random();
    const chars = 'abcdefghijkmnpqrstuvwxyz23456789';
    return 'prep-${List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join()}';
  }
}
