import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/data/database/database.dart';
// sqlite3 ships transitively with drift; used here only to hand-build a v4 DB.
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

/// Upgrading an old v4 database must retire the three phase-roadmap/daily-plan
/// tables, add everything introduced since (the v6 timetable), and leave every
/// other table and its data untouched.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('v4 -> current drops the retired tables and keeps unrelated data',
      () async {
    // Hand-build a v4-shaped database: the three retired tables plus one
    // unrelated table with a row to prove the migration is surgical.
    final raw = sqlite3.openInMemory();
    raw.execute('CREATE TABLE roadmap_phases (id INTEGER PRIMARY KEY, title TEXT);');
    raw.execute('CREATE TABLE roadmap_tasks (id INTEGER PRIMARY KEY, phase_id INTEGER);');
    raw.execute('CREATE TABLE daily_plan_items (id INTEGER PRIMARY KEY, canon TEXT);');
    raw.execute("INSERT INTO roadmap_phases (title) VALUES ('Foundation');");
    raw.execute('CREATE TABLE leaf_progress (canon TEXT PRIMARY KEY, status TEXT);');
    raw.execute("INSERT INTO leaf_progress VALUES ('lc:two-sum', 'solved');");
    raw.execute('PRAGMA user_version = 4;');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    // Any query forces drift to open and run the pending migration.
    final tables = (await db
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
            .get())
        .map((r) => r.read<String>('name'))
        .toSet();

    expect(tables, isNot(contains('roadmap_phases')));
    expect(tables, isNot(contains('roadmap_tasks')));
    expect(tables, isNot(contains('daily_plan_items')));

    // The unrelated table and its row survive.
    expect(tables, contains('leaf_progress'));
    final kept =
        await db.customSelect('SELECT canon, status FROM leaf_progress').get();
    expect(kept, hasLength(1));
    expect(kept.first.read<String>('status'), 'solved');

    // Tables added after v4 are created by the same upgrade.
    expect(tables, contains('timetable_blocks'));

    // The schema version advanced to the current one.
    final version = (await db.customSelect('PRAGMA user_version').getSingle())
        .read<int>('user_version');
    expect(version, db.schemaVersion);
  });
}
