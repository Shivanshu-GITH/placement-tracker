import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-subject daily-pace overrides for the planner, keyed by sheet slug (slugs
/// are stable across reseeds; numeric ids are not).
///
/// A slug absent from the map means "use the auto pace" — whatever is needed to
/// finish that subject by the deadline. Kept in shared_preferences rather than
/// Drift for the same reason as quiz results: it is lightweight, self-contained,
/// and avoids a schema migration.
class PlannerSettingsNotifier extends Notifier<Map<String, int>> {
  static const _key = 'planner_paces_v1';

  /// Completes once the stored paces have been read. Writes wait on it: the
  /// state starts EMPTY and fills in asynchronously, so a pace set in that
  /// window used to persist `{thisSlug: pace}` over the whole map — wiping
  /// every other subject's pace — and was then itself overwritten when the
  /// load landed.
  Future<void>? _ready;

  @override
  Map<String, int> build() {
    _ready = _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final stored = (json.decode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      );
      // Anything set while this was loading wins: it is the user's newer
      // intent and has already been written to disk.
      state = {...stored, ...state};
    } catch (_) {
      // Corrupt store — start fresh rather than crash.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(state));
  }

  /// Pins a subject's daily pace (>= 1). Use [clearPace] to return to auto.
  Future<void> setPace(String slug, int pace) async {
    if (pace < 1) return clearPace(slug);
    await _ready; // never write on top of a half-loaded map
    state = {...state, slug: pace};
    await _persist();
  }

  /// Removes any override so the subject reverts to the auto (required) pace.
  Future<void> clearPace(String slug) async {
    await _ready;
    if (!state.containsKey(slug)) return;
    final next = {...state}..remove(slug);
    state = next;
    await _persist();
  }
}

final plannerSettingsProvider =
    NotifierProvider<PlannerSettingsNotifier, Map<String, int>>(
        PlannerSettingsNotifier.new);
