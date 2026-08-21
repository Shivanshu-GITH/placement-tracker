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
      out.add(LeaderboardEntry(
        rank: 0,
        userId: 'stub-$i',
        name: _names[i % _names.length],
        college: _colleges[i % _colleges.length],
        solved: solved,
        streak: 1 + r.nextInt(90),
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
      case LeaderboardScope.weekly:
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
