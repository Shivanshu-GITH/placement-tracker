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
    RoadmapPhases,
    RoadmapTasks,
    DailyPlanItems,
    Resources,
    Achievements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests: inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'preppilot.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
