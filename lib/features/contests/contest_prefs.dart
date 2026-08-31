import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contest_models.dart';
import 'contest_schedule.dart';

/// Whether the user has opted into contest prep (shows the contests card on the
/// dashboard and enables pre-contest reminders). Persisted in shared_preferences
/// (device-level, like the daily-reminder setting).
class ContestPrefsNotifier extends Notifier<bool> {
  static const _key = 'contest_prep_enabled';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getBool(_key) ?? false) state = true;
    } catch (_) {}
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_key, value);
    } catch (_) {}
  }
}

final contestPrepProvider =
    NotifierProvider<ContestPrefsNotifier, bool>(ContestPrefsNotifier.new);

/// Contests starting today (IST).
final todaysContestsProvider = Provider<List<ContestOccurrence>>(
    (ref) => ContestSchedule.today());

/// Contests in the next week (IST), soonest first.
final upcomingContestsProvider = Provider<List<ContestOccurrence>>(
    (ref) => ContestSchedule.upcoming(days: 7));
