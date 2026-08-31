import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A learner's result on one topic's quiz. [best] is their best score out of
/// [total]; [attempts] counts how many times they've taken it.
class QuizResult {
  const QuizResult({
    required this.best,
    required this.total,
    required this.attempts,
  });

  final int best;
  final int total;
  final int attempts;

  /// Passing bar: 60% correct.
  bool get passed => total > 0 && best / total >= 0.6;
  double get fraction => total == 0 ? 0 : best / total;

  Map<String, dynamic> toJson() =>
      {'best': best, 'total': total, 'attempts': attempts};

  factory QuizResult.fromJson(Map<String, dynamic> j) => QuizResult(
        best: (j['best'] ?? 0) as int,
        total: (j['total'] ?? 0) as int,
        attempts: (j['attempts'] ?? 0) as int,
      );
}

/// Persists per-topic quiz results in shared_preferences and exposes them
/// reactively. Kept out of the Drift DB deliberately: results are lightweight,
/// self-contained, and this avoids a schema migration.
class QuizResultsNotifier extends Notifier<Map<String, QuizResult>> {
  static const _key = 'quiz_results_v1';

  @override
  Map<String, QuizResult> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = (json.decode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, QuizResult.fromJson(v as Map<String, dynamic>)),
      );
      state = map;
    } catch (_) {
      // Corrupt store — start fresh rather than crash.
    }
  }

  /// Records a completed attempt, keeping the best score. Returns the new best.
  Future<QuizResult> record(String canon, int score, int total) async {
    final prev = state[canon];
    final best = prev == null ? score : (score > prev.best ? score : prev.best);
    final next = QuizResult(
      best: best,
      total: total,
      attempts: (prev?.attempts ?? 0) + 1,
    );
    state = {...state, canon: next};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(state.map((k, v) => MapEntry(k, v.toJson()))),
    );
    return next;
  }
}

final quizResultsProvider =
    NotifierProvider<QuizResultsNotifier, Map<String, QuizResult>>(
        QuizResultsNotifier.new);
