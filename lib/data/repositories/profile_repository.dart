import 'package:drift/drift.dart';

import '../database/database.dart';

/// Reads and writes the single-row user profile (id = 1 by convention).
class ProfileRepository {
  ProfileRepository(this._db);
  final AppDatabase _db;

  Future<UserProfile> get() async {
    final existing = await _db.select(_db.userProfiles).get();
    if (existing.isNotEmpty) return existing.first;
    // Defensive: create if missing.
    await _db.into(_db.userProfiles).insert(const UserProfilesCompanion());
    return (await _db.select(_db.userProfiles).get()).first;
  }

  Stream<UserProfile?> watch() {
    return (_db.select(_db.userProfiles)..limit(1))
        .watchSingleOrNull();
  }

  Future<void> completeOnboarding({
    required String name,
    required int dailyGoalMinutes,
    DateTime? targetDate,
  }) async {
    final profile = await get();
    await (_db.update(_db.userProfiles)
          ..where((t) => t.id.equals(profile.id)))
        .write(UserProfilesCompanion(
      name: Value(name.trim().isEmpty ? 'Aspirant' : name.trim()),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      targetDate: Value(targetDate),
      onboarded: const Value(true),
    ));
  }

  Future<void> addXp(int amount) async {
    final profile = await get();
    await (_db.update(_db.userProfiles)
          ..where((t) => t.id.equals(profile.id)))
        .write(UserProfilesCompanion(xp: Value(profile.xp + amount)));
  }

  /// Sets (or clears) the target/deadline date that drives the planner's pacing.
  Future<void> setTargetDate(DateTime? date) async {
    final profile = await get();
    await (_db.update(_db.userProfiles)
          ..where((t) => t.id.equals(profile.id)))
        .write(UserProfilesCompanion(targetDate: Value(date)));
  }

  /// Sets the daily study budget in minutes — the planner's capacity, and what
  /// a day has to hit to count towards the streak.
  Future<void> updateGoals({required int minutes}) async {
    final profile = await get();
    await (_db.update(_db.userProfiles)
          ..where((t) => t.id.equals(profile.id)))
        .write(UserProfilesCompanion(dailyGoalMinutes: Value(minutes)));
  }
}
