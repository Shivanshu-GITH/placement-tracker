import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    Sheets,
    Nodes,
    UserSheets,
    LeafProgress,
    StudySessions,
    ActivityDays,
    Resources,
    Achievements,
    TimetableBlocks,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Each identity (a Google account, or the guest session) gets its own
  /// database file so switching accounts never mixes progress or plans.
  AppDatabase({String dbKey = 'guest'}) : super(_openConnection(dbKey));

  /// For tests: inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  /// Deletes every row from every table (content + all user progress) on the
  /// live connection. Used by the account/data-deletion flow so the user's data
  /// is gone immediately, even on platforms where the still-open file can't be
  /// removed. Children are deleted before parents to respect foreign keys.
  Future<void> wipeAllData() async {
    await transaction(() async {
      await delete(leafProgress).go();
      await delete(studySessions).go();
      await delete(activityDays).go();
      await delete(achievements).go();
      await delete(resources).go();
      await delete(userSheets).go();
      await delete(nodes).go();
      await delete(sheets).go();
      await delete(userProfiles).go();
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 -> v2 replaced the content schema with the generic Nodes tree.
            // Rebuild everything (no production data existed at v1).
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await m.createAll();
          } else {
            // v2 -> v3 only ADDS the resources table; keep existing data.
            if (from < 3) await m.createTable(resources);
            // (v3 -> v4 added daily_plan_items.canon, a table that v5 drops —
            // no need to add the column just to remove the table below.)
            if (from < 5) {
              // v4 -> v5 retires the old phase-roadmap + daily-plan tables.
              // Drop the FK child before its parent. Raw SQL because the table
              // classes no longer exist in the schema.
              await customStatement('DROP TABLE IF EXISTS roadmap_tasks');
              await customStatement('DROP TABLE IF EXISTS roadmap_phases');
              await customStatement('DROP TABLE IF EXISTS daily_plan_items');
            }
            // v5 -> v6 adds the daily timetable.
            if (from < 6) await m.createTable(timetableBlocks);
            // v6 -> v7 retires the per-day "problems" goal. SQLite can't drop a
            // column in place, so Drift rebuilds the table and copies the rows;
            // every other profile field is preserved.
            if (from < 7) {
              await m.alterTable(
                TableMigration(userProfiles),
              );
            }
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

String _safeKey(String dbKey) => dbKey.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

LazyDatabase _openConnection(String dbKey) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    // Sanitise the key so it is always a safe file-name fragment.
    final file = File(p.join(dir.path, 'preppilot_${_safeKey(dbKey)}.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Best-effort removal of a bucket's on-disk SQLite file (plus its WAL/SHM
/// sidecars). Call AFTER the connection for [dbKey] has been closed. Safe to
/// call when the files don't exist or can't be removed (e.g. still locked) —
/// the account/data-deletion flow already wipes the rows first, so a lingering
/// file holds no user data.
Future<void> deleteDatabaseFileForKey(String dbKey) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final base = p.join(dir.path, 'preppilot_${_safeKey(dbKey)}.sqlite');
    for (final path in [base, '$base-wal', '$base-shm']) {
      final f = File(path);
      if (await f.exists()) {
        try {
          await f.delete();
        } catch (_) {/* still locked — rows were already wiped */}
      }
    }
  } catch (_) {/* documents dir unavailable — nothing to remove */}
}
