import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/data/database/database.dart';
import 'package:preppilot/features/timetable/timetable_models.dart';
import 'package:preppilot/features/timetable/timetable_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('weekday bitmask', () {
    test('all/weekday/weekend presets cover the right days', () {
      // Monday 2026-01-05 .. Sunday 2026-01-11
      final mon = DateTime(2026, 1, 5);
      final sat = DateTime(2026, 1, 10);
      final sun = DateTime(2026, 1, 11);

      expect(Weekdays.runsOn(Weekdays.all, mon), isTrue);
      expect(Weekdays.runsOn(Weekdays.all, sun), isTrue);

      expect(Weekdays.runsOn(Weekdays.weekdays, mon), isTrue);
      expect(Weekdays.runsOn(Weekdays.weekdays, sat), isFalse);
      expect(Weekdays.runsOn(Weekdays.weekdays, sun), isFalse);

      expect(Weekdays.runsOn(Weekdays.weekend, sat), isTrue);
      expect(Weekdays.runsOn(Weekdays.weekend, sun), isTrue);
      expect(Weekdays.runsOn(Weekdays.weekend, mon), isFalse);
    });

    test('toggling a day flips only that day', () {
      var mask = 0;
      mask = Weekdays.toggle(mask, 0); // Monday on
      expect(Weekdays.hasDay(mask, 0), isTrue);
      expect(Weekdays.hasDay(mask, 1), isFalse);
      mask = Weekdays.toggle(mask, 0); // Monday off again
      expect(Weekdays.hasDay(mask, 0), isFalse);
    });

    test('labels read naturally', () {
      expect(Weekdays.label(Weekdays.all), 'Every day');
      expect(Weekdays.label(Weekdays.weekdays), 'Mon–Fri');
      expect(Weekdays.label(Weekdays.weekend), 'Weekends');
      expect(Weekdays.label(0), 'Never');
      expect(Weekdays.label(1 | (1 << 2)), 'Mon, Wed');
    });
  });

  group('time formatting', () {
    test('renders a 12-hour clock', () {
      expect(formatMinuteOfDay(0), '12:00 AM');
      expect(formatMinuteOfDay(7 * 60 + 30), '7:30 AM');
      expect(formatMinuteOfDay(12 * 60), '12:00 PM');
      expect(formatMinuteOfDay(19 * 60 + 5), '7:05 PM');
    });
  });

  group('repository', () {
    late AppDatabase db;
    late TimetableRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = TimetableRepository(db);
    });
    tearDown(() => db.close());

    test('adds, updates, disables and deletes blocks in start order', () async {
      await repo.add(title: 'Evening core', startMinute: 18 * 60, durationMinutes: 45);
      await repo.add(title: 'Morning DSA', startMinute: 7 * 60, durationMinutes: 90);

      var blocks = await repo.allBlocks();
      expect(blocks.map((b) => b.title), ['Morning DSA', 'Evening core']);
      expect(blocks.first.daysMask, Weekdays.all); // default
      expect(blocks.first.enabled, isTrue);

      await repo.setEnabled(blocks.first.id, false);
      blocks = await repo.allBlocks();
      expect(blocks.first.enabled, isFalse);

      await repo.update(blocks.first.copyWith(title: 'Morning DSA v2'));
      blocks = await repo.allBlocks();
      expect(blocks.first.title, 'Morning DSA v2');

      await repo.delete(blocks.first.id);
      blocks = await repo.allBlocks();
      expect(blocks.length, 1);
    });
  });

  test('v5 -> v6 migration adds the timetable and keeps existing data', () async {
    // Build a v5 database, then open it at v6 and check the upgrade path.
    final native = sqlite3.openInMemory();
    native.execute('''
      CREATE TABLE user_profiles (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT 'Aspirant',
        target_role TEXT NOT NULL DEFAULT 'product',
        target_companies TEXT NOT NULL DEFAULT '',
        skill_level TEXT NOT NULL DEFAULT 'beginner',
        daily_goal_minutes INTEGER NOT NULL DEFAULT 120,
        daily_goal_problems INTEGER NOT NULL DEFAULT 4,
        target_date INTEGER NULL,
        xp INTEGER NOT NULL DEFAULT 0,
        onboarded INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
      );
    ''');
    native.execute(
        "INSERT INTO user_profiles (name, xp) VALUES ('Shivanshu', 250);");
    native.execute('PRAGMA user_version = 5;');

    final db = AppDatabase.forTesting(NativeDatabase.opened(native));
    addTearDown(db.close);

    // Touching the schema triggers the migration.
    final profiles = await db.select(db.userProfiles).get();
    expect(profiles.single.name, 'Shivanshu');
    expect(profiles.single.xp, 250); // untouched by the upgrade

    // The new table exists and works.
    final repo = TimetableRepository(db);
    await repo.add(title: 'DSA', startMinute: 420, durationMinutes: 60);
    expect((await repo.allBlocks()).single.title, 'DSA');
  });
}
