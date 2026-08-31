import 'dart:math';

import 'leaderboard_models.dart';

/// Backend-agnostic leaderboard access. Swap [StubLeaderboardRepository] for a
/// Supabase-backed one once the project keys are wired.
abstract class LeaderboardRepository {
  bool get isLive;

  /// The pool of people for a scope (including the current user), unranked.
  Future<List<LeaderboardEntry>> pool(
    LeaderboardScope scope, {
    required MyStats me,
    required String myName,
    String? myCollege,
  });

  Future<void> syncMyStats(MyStats stats,
      {required String name, String? college});

  /// Searches other users by display name (for adding friends).
  Future<List<LeaderboardEntry>> searchUsers(String query);

  /// The set of user ids the current user follows.
  Future<Set<String>> followingIds();

  /// Follow / unfollow another user.
  Future<void> follow(String userId);
  Future<void> unfollow(String userId);

  /// The current user's own aggregated leaderboard row (score + verified totals).
  Future<LeaderboardEntry?> myEntry();

  /// Any user's aggregated leaderboard row (for public profiles).
  Future<LeaderboardEntry?> entryOf(String userId);

  /// The current user's linked coding platforms (with verified stats).
  Future<List<PlatformInfo>> myPlatforms();

  /// Any user's linked platforms (for public profiles).
  Future<List<PlatformInfo>> platformsOf(String userId);

  /// Contest history across the given user's platforms (default: current user).
  Future<List<ContestEntry>> contests([String? userId]);

  /// Profile / social links (default: current user).
  Future<List<SocialLink>> socialLinks([String? userId]);
  Future<void> setSocialLink(String kind, String url);
  Future<void> removeSocialLink(String kind);

  /// Portfolio projects (default: current user).
  Future<List<ProjectItem>> projects([String? userId]);
  Future<void> addProject(ProjectItem p);
  Future<void> updateProject(ProjectItem p);
  Future<void> deleteProject(String id);

  /// Count a profile view (no-op for your own profile).
  Future<void> incrementProfileView(String userId);

  /// Claims a handle and returns a one-time token to place in the platform
  /// profile to prove ownership.
  Future<String> linkPlatform(String platform, String handle);

  /// Verifies ownership + fetches stats via the server-side Edge Function.
  Future<PlatformVerifyResult> verifyPlatform(String platform, String handle);

  /// Removes a linked platform and its verified stats.
  Future<void> unlinkPlatform(String platform);

  /// Permanently deletes the signed-in user's account and ALL associated cloud
  /// data. Throws on failure so callers can keep local data for a retry.
  Future<void> deleteAccount();
}

/// Sample data so the leaderboard looks and feels real before the backend
/// exists. Deterministic (seeded) so it doesn't jump around.
class StubLeaderboardRepository implements LeaderboardRepository {
  @override
  bool get isLive => false;

  static const _names = [
    'Aarav Sharma', 'Diya Patel', 'Vivaan Reddy', 'Ananya Iyer', 'Aditya Nair',
    'Ishaan Gupta', 'Saanvi Rao', 'Kabir Mehta', 'Myra Joshi', 'Reyansh Das',
    'Aadhya Menon', 'Arjun Verma', 'Kiara Shah', 'Vihaan Kulkarni', 'Anika Bose',
    'Rohan Pillai', 'Navya Chauhan', 'Krishna Yadav', 'Sara Fernandes',
    'Dhruv Malhotra', 'Aisha Khan', 'Yash Agarwal', 'Tara Nanda', 'Neil Kapoor',
    'Riya Sen', 'Om Prakash', 'Zoya Ansari', 'Advait Rege', 'Meera Pillai',
    'Kabir Singh',
  ];
  static const _colleges = [
    'IIT Delhi', 'NIT Trichy', 'BITS Pilani', 'VIT Vellore', 'IIIT Hyderabad',
  ];

  List<LeaderboardEntry> _base(int count, int seed) {
    final r = Random(seed);
    final out = <LeaderboardEntry>[];
    for (var i = 0; i < count; i++) {
      final solved = 40 + r.nextInt(560);
      final rating = 900 + r.nextInt(2100);
      final streak = 1 + r.nextInt(90);
      out.add(LeaderboardEntry(
        rank: 0,
        userId: 'stub-$i',
        name: _names[i % _names.length],
        college: _colleges[i % _colleges.length],
        verifiedSolved: solved,
        rating: rating,
        extStreak: streak,
        verifiedPlatforms: 1 + r.nextInt(2),
        prepScore: ((solved / 1000).clamp(0, 1) * 50 +
                (rating / 3000).clamp(0, 1) * 50)
            .round(),
        solved: solved,
        streak: streak,
        xp: solved * 10 + r.nextInt(200),
        weeklySolved: r.nextInt(45),
      ));
    }
    return out;
  }

  LeaderboardEntry _meEntry(MyStats me, String myName, String? myCollege) =>
      LeaderboardEntry(
        rank: 0,
        userId: 'me',
        name: myName,
        college: myCollege,
        solved: me.totalSolved,
        streak: me.currentStreak,
        xp: me.xp,
        weeklySolved: me.weeklySolved,
        isMe: true,
      );

  @override
  Future<List<LeaderboardEntry>> pool(
    LeaderboardScope scope, {
    required MyStats me,
    required String myName,
    String? myCollege,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250)); // feel real
    final meEntry = _meEntry(me, myName, myCollege);
    switch (scope) {
      case LeaderboardScope.global:
        return [..._base(60, 1), meEntry];
      case LeaderboardScope.country:
        return [..._base(40, 2), meEntry];
      case LeaderboardScope.friends:
        return [..._base(7, 3), meEntry];
      case LeaderboardScope.college:
        final peers = _base(18, 4)
            .map((e) => LeaderboardEntry(
                  rank: 0, userId: e.userId, name: e.name,
                  college: myCollege ?? 'Your College',
                  solved: e.solved, streak: e.streak, xp: e.xp,
                  weeklySolved: e.weeklySolved,
                ))
            .toList();
        return [...peers, meEntry];
    }
  }

  @override
  Future<void> syncMyStats(MyStats stats,
      {required String name, String? college}) async {
    // no-op in stub
  }

  @override
  Future<List<LeaderboardEntry>> searchUsers(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _base(26, 7)
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Set<String>> followingIds() async => <String>{};

  @override
  Future<void> follow(String userId) async {}

  @override
  Future<void> unfollow(String userId) async {}

  @override
  Future<LeaderboardEntry?> myEntry() async => null;

  @override
  Future<LeaderboardEntry?> entryOf(String userId) async => null;

  @override
  Future<List<PlatformInfo>> myPlatforms() async => const [];

  @override
  Future<List<PlatformInfo>> platformsOf(String userId) async => const [];

  @override
  Future<List<ContestEntry>> contests([String? userId]) async => const [];

  @override
  Future<List<SocialLink>> socialLinks([String? userId]) async => const [];

  @override
  Future<void> setSocialLink(String kind, String url) async {}

  @override
  Future<void> removeSocialLink(String kind) async {}

  @override
  Future<List<ProjectItem>> projects([String? userId]) async => const [];

  @override
  Future<void> addProject(ProjectItem p) async {}

  @override
  Future<void> updateProject(ProjectItem p) async {}

  @override
  Future<void> deleteProject(String id) async {}

  @override
  Future<void> incrementProfileView(String userId) async {}

  @override
  Future<String> linkPlatform(String platform, String handle) async =>
      'prep-demo';

  @override
  Future<PlatformVerifyResult> verifyPlatform(
          String platform, String handle) async =>
      const PlatformVerifyResult(
          verified: false, error: 'Connect the backend to verify.');

  @override
  Future<void> unlinkPlatform(String platform) async {}

  @override
  Future<void> deleteAccount() async {}
}

/// Ranks a pool by the chosen metric and assigns 1-based ranks.
List<LeaderboardEntry> rankPool(
    List<LeaderboardEntry> pool, LeaderboardMetric metric) {
  final sorted = [...pool]
    ..sort((a, b) => b.metricValue(metric).compareTo(a.metricValue(metric)));
  return [
    for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(rank: i + 1),
  ];
}
