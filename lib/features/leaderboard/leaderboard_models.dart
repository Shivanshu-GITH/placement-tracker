/// Which board is being shown.
enum LeaderboardScope { global, weekly, friends, college }

extension LeaderboardScopeX on LeaderboardScope {
  String get label => switch (this) {
        LeaderboardScope.global => 'Global',
        LeaderboardScope.weekly => 'Weekly',
        LeaderboardScope.friends => 'Friends',
        LeaderboardScope.college => 'College',
      };
}

/// What we rank by.
enum LeaderboardMetric { solved, streak, xp, weeklySolved }

extension LeaderboardMetricX on LeaderboardMetric {
  String get label => switch (this) {
        LeaderboardMetric.solved => 'Solved',
        LeaderboardMetric.streak => 'Streak',
        LeaderboardMetric.xp => 'XP',
        LeaderboardMetric.weeklySolved => 'This week',
      };

  String get unit => switch (this) {
        LeaderboardMetric.streak => 'days',
        LeaderboardMetric.xp => 'XP',
        _ => 'solved',
      };
}

/// A person's aggregate stats, synced to the leaderboard backend.
class MyStats {
  const MyStats({
    required this.totalSolved,
    required this.currentStreak,
    required this.longestStreak,
    required this.xp,
    required this.weeklySolved,
    required this.weeklyMinutes,
  });

  final int totalSolved;
  final int currentStreak;
  final int longestStreak;
  final int xp;
  final int weeklySolved;
  final int weeklyMinutes;

  static const empty = MyStats(
    totalSolved: 0,
    currentStreak: 0,
    longestStreak: 0,
    xp: 0,
    weeklySolved: 0,
    weeklyMinutes: 0,
  );
}

/// One ranked row on a leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.college,
    required this.solved,
    required this.streak,
    required this.xp,
    required this.weeklySolved,
    this.isMe = false,
  });

  final int rank;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? college;
  final int solved;
  final int streak;
  final int xp;
  final int weeklySolved;
  final bool isMe;

  int metricValue(LeaderboardMetric m) => switch (m) {
        LeaderboardMetric.solved => solved,
        LeaderboardMetric.streak => streak,
        LeaderboardMetric.xp => xp,
        LeaderboardMetric.weeklySolved => weeklySolved,
      };

  LeaderboardEntry copyWith({int? rank}) => LeaderboardEntry(
        rank: rank ?? this.rank,
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
        college: college,
        solved: solved,
        streak: streak,
        xp: xp,
        weeklySolved: weeklySolved,
        isMe: isMe,
      );
}
