import '../../data/models/dtos.dart';
import '../constants/enums.dart';

/// Computes a 0–100 "placement readiness" score from progress signals.
/// Deterministic and explainable — no black box.
class Readiness {
  Readiness._();

  static int score(PrepStats stats, StreakInfo streak) {
    if (stats.totalItems == 0) return 0;

    final progress = stats.overallProgress; // 0..1

    // Hard-problem competence.
    final totalHard = stats.totalByDifficulty[Difficulty.hard] ?? 0;
    final solvedHard = stats.doneByDifficulty[Difficulty.hard] ?? 0;
    final hard = totalHard == 0 ? 0.0 : (solvedHard / totalHard);

    // Breadth: how many categories have meaningful coverage (>=20%).
    final covered = stats.byCategory
        .where((c) => c.total > 0 && c.progress >= 0.2)
        .length;
    final coverage = stats.byCategory.isEmpty
        ? 0.0
        : covered / stats.byCategory.length;

    // Consistency.
    final streakScore = (streak.current / 14).clamp(0.0, 1.0);

    final raw = 0.55 * progress +
        0.15 * hard +
        0.15 * coverage +
        0.15 * streakScore;
    return (raw * 100).round().clamp(0, 100);
  }

  static String label(int score) {
    if (score >= 80) return 'Interview ready';
    if (score >= 60) return 'Almost there';
    if (score >= 35) return 'Building up';
    if (score >= 15) return 'Getting started';
    return 'Just beginning';
  }
}
