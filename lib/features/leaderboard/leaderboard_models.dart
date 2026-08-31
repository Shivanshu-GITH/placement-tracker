/// Which board is being shown.
enum LeaderboardScope { global, country, college, friends }

extension LeaderboardScopeX on LeaderboardScope {
  String get label => switch (this) {
        LeaderboardScope.global => 'Global',
        LeaderboardScope.country => 'Country',
        LeaderboardScope.college => 'College',
        LeaderboardScope.friends => 'Friends',
      };
}

/// What we rank by.
///  • prepScore      — combined PrepPilot Score (50% verified external + 50% in-app)
///  • verifiedSolved — real solved count from linked coding platforms
///  • rating         — best contest rating from linked platforms
///  • streak         — external coding streak (from linked platforms)
enum LeaderboardMetric { prepScore, verifiedSolved, rating, streak }

extension LeaderboardMetricX on LeaderboardMetric {
  String get label => switch (this) {
        LeaderboardMetric.prepScore => 'Overall',
        LeaderboardMetric.verifiedSolved => 'Solved',
        LeaderboardMetric.rating => 'Rating',
        LeaderboardMetric.streak => 'Streak',
      };

  String get unit => switch (this) {
        LeaderboardMetric.prepScore => 'pts',
        LeaderboardMetric.verifiedSolved => 'solved',
        LeaderboardMetric.rating => 'rating',
        LeaderboardMetric.streak => 'days',
      };
}

/// A linked coding platform and its verified stats (if verified yet).
class PlatformInfo {
  const PlatformInfo({
    required this.platform,
    required this.handle,
    this.verified = false,
    this.solved = 0,
    this.rating = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.activeDays = 0,
    this.daily = const {},
    this.repos = 0,
    this.stars = 0,
    this.contributions = 0,
    this.commits = 0,
    this.prs = 0,
    this.issues = 0,
    this.languages = const {},
  });
  final String platform; // 'leetcode' | 'codeforces' | ... | 'github'
  final String handle;
  final bool verified;
  final int solved;
  final int rating;
  final int streak;
  final int maxStreak;
  final int activeDays;
  final Map<String, int> daily; // "YYYY-MM-DD" -> count
  // Development stats (GitHub only).
  final int repos;
  final int stars;
  final int contributions;
  final int commits;
  final int prs;
  final int issues;
  final Map<String, int> languages;

  /// True for development platforms (GitHub) vs problem-solving ones.
  bool get isDev => platform == 'github';

  String get label => switch (platform) {
        'leetcode' => 'LeetCode',
        'codeforces' => 'Codeforces',
        'atcoder' => 'AtCoder',
        'geeksforgeeks' => 'GeeksforGeeks',
        'github' => 'GitHub',
        'codechef' => 'CodeChef',
        _ => platform,
      };
}

/// Result of a verify/sync round-trip to the Edge Function.
class PlatformVerifyResult {
  const PlatformVerifyResult({
    required this.verified,
    this.solved = 0,
    this.rating = 0,
    this.streak = 0,
    this.error,
  });
  final bool verified;
  final int solved;
  final int rating;
  final int streak;
  final String? error;
}

/// A person's in-app aggregate stats, synced to the leaderboard backend.
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

/// One ranked row on a leaderboard. Carries both the verified external metrics
/// and the in-app stats (the score blends them).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.college,
    this.prepScore = 0,
    this.verifiedSolved = 0,
    this.rating = 0,
    this.extStreak = 0,
    this.verifiedPlatforms = 0,
    this.solved = 0, // in-app tracker solved
    this.streak = 0, // in-app study streak
    this.xp = 0,
    this.weeklySolved = 0,
    this.profileViews = 0,
    this.country,
    this.platformRatings = const {},
    this.isMe = false,
  });

  final int rank;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? college;

  // Verified external (from linked coding platforms).
  final int prepScore;
  final int verifiedSolved;
  final int rating;
  final int extStreak;
  final int verifiedPlatforms;

  // In-app.
  final int solved;
  final int streak;
  final int xp;
  final int weeklySolved;

  final int profileViews;
  final String? country;

  /// Per-contest-platform rating: {'leetcode': 1800, 'codeforces': 1500, ...}
  final Map<String, int> platformRatings;

  final bool isMe;

  bool get isVerified => verifiedPlatforms > 0;

  int metricValue(LeaderboardMetric m) => switch (m) {
        LeaderboardMetric.prepScore => prepScore,
        LeaderboardMetric.verifiedSolved => verifiedSolved,
        LeaderboardMetric.rating => rating,
        LeaderboardMetric.streak => extStreak,
      };

  LeaderboardEntry copyWith({int? rank}) => LeaderboardEntry(
        rank: rank ?? this.rank,
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
        college: college,
        prepScore: prepScore,
        verifiedSolved: verifiedSolved,
        rating: rating,
        extStreak: extStreak,
        verifiedPlatforms: verifiedPlatforms,
        solved: solved,
        streak: streak,
        xp: xp,
        weeklySolved: weeklySolved,
        profileViews: profileViews,
        country: country,
        platformRatings: platformRatings,
        isMe: isMe,
      );
}

/// One contest a user attended on a linked platform.
class ContestEntry {
  const ContestEntry({
    required this.platform,
    required this.contest,
    this.rank,
    this.rating,
    this.heldAt,
  });
  final String platform;
  final String contest;
  final int? rank;
  final int? rating;
  final DateTime? heldAt;

  String get platformLabel => switch (platform) {
        'leetcode' => 'LeetCode',
        'codeforces' => 'Codeforces',
        'atcoder' => 'AtCoder',
        'codechef' => 'CodeChef',
        _ => platform,
      };
}

/// A profile / social link (github, linkedin, x, website, email).
class SocialLink {
  const SocialLink({required this.kind, required this.url});
  final String kind;
  final String url;

  String get label => switch (kind) {
        'github' => 'GitHub',
        'linkedin' => 'LinkedIn',
        'x' => 'X',
        'website' => 'Website',
        'email' => 'Email',
        _ => kind,
      };
}

/// A portfolio project (added from GitHub or manually).
class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.title,
    this.description,
    this.repoUrl,
    this.demoUrl,
    this.imageUrl,
    this.tech,
    this.orderIndex = 0,
  });
  final String id;
  final String title;
  final String? description;
  final String? repoUrl;
  final String? demoUrl;
  final String? imageUrl;
  final String? tech;
  final int orderIndex;

  List<String> get techList =>
      (tech ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
