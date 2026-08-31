import '../../core/constants/enums.dart';

/// How much time one item typically costs.
///
/// The planner used to treat every item as equal, which is why a plan could look
/// achievable on paper and be impossible in practice: 20 aptitude concepts and
/// 20 hard DSA problems are both "20 items", but the second is roughly five
/// times the work. Estimating effort in MINUTES is what lets the planner answer
/// the questions that actually matter — "can I finish this by my deadline at N
/// hours a day?" and "what is a realistic amount to do today?".
///
/// The numbers are deliberate, conservative averages for someone preparing for
/// placements (reading the note + attempting the problem/quiz), not stopwatch
/// truth. They are constants in one place so they stay tunable.
class PlanEffort {
  const PlanEffort._();

  /// A theory/aptitude topic: read the note, take the 3-question quiz.
  static const int conceptMinutes = 8;

  /// A coding problem, by difficulty: understand, solve, verify.
  static const int easyProblemMinutes = 15;
  static const int mediumProblemMinutes = 25;
  static const int hardProblemMinutes = 40;

  /// Estimated minutes for a single item.
  static int forLeaf({
    required bool isConcept,
    required Difficulty difficulty,
  }) {
    if (isConcept) return conceptMinutes;
    return switch (difficulty) {
      Difficulty.easy => easyProblemMinutes,
      Difficulty.medium => mediumProblemMinutes,
      Difficulty.hard => hardProblemMinutes,
    };
  }

  /// Formats a minute count the way the UI shows it ("45 min", "2h 30m").
  static String format(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
