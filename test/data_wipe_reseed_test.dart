import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/data/database/database.dart';
import 'package:preppilot/data/repositories/seed_service.dart';
import 'package:preppilot/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deleting an account (or a guest's data) empties the CURRENT database
/// connection with wipeAllData(). That clears the shipped catalogue — sheets,
/// nodes, resources, the default sheet selection — as well as the user's own
/// rows, and nothing re-seeded that live connection: bootstrapProvider had
/// already resolved, and it only re-runs when the account bucket (dbKey)
/// changes, which a wipe does not do.
///
/// The app therefore kept rendering as if it had booted, over an empty
/// database: onboarding with no sheets to pick, a dashboard with no topics and
/// an empty planner — until the next launch re-ran the seeder and it all
/// reappeared.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  group('the seeder repairs a wiped bucket', () {
    test('a second ensureSeeded() restores content, selection and profile',
        () async {
      final seed = SeedService(db);
      await seed.ensureSeeded();
      final sheets = (await db.select(db.sheets).get()).length;
      expect(sheets, greaterThan(0));

      await db.wipeAllData();
      expect(await db.select(db.sheets).get(), isEmpty);

      await seed.ensureSeeded();
      expect((await db.select(db.sheets).get()).length, sheets);
      expect(await db.select(db.nodes).get(), isNotEmpty);
      expect(
          (await db.select(db.userSheets).get()).where((u) => u.active).toList(),
          isNotEmpty,
          reason: 'the default sheet selection must come back');
      expect((await db.select(db.userProfiles).get()).length, 1);
      expect(await db.select(db.resources).get(), isNotEmpty);
    });
  });

  group('the deletion flows repair the bucket they leave the user on', () {
    late _CountingSeedService seeder;
    late ProviderContainer container;

    setUp(() {
      seeder = _CountingSeedService(db);
      container = ProviderContainer(overrides: [
        databaseProvider.overrideWith((ref) {
          ref.watch(dbKeyProvider);
          return db;
        }),
        // Stubbed: this group asserts the flow re-seeds. What the real seeder
        // puts back is covered by the group above.
        seedServiceProvider.overrideWithValue(seeder),
      ]);
      // Keep the content stream alive, as the running app does.
      container.listen(sheetsProvider, (_, _) {});
    });
    tearDown(() => container.dispose());

    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('deleting guest data leaves a usable bucket', () async {
      final ref = _ContainerRef(container);
      await container.read(bootstrapProvider.future);
      await settle();
      expect(seeder.calls, 1);
      expect(container.read(sheetsProvider).valueOrNull, isNotEmpty);

      await deleteGuestData(ref);
      await settle();

      expect(seeder.calls, 2, reason: 'the wiped bucket must be re-seeded');
      expect(container.read(sheetsProvider).valueOrNull, isNotEmpty,
          reason: 'the UI reads its content through this stream');
    });

    test('deleting the account leaves a usable bucket', () async {
      final ref = _ContainerRef(container);
      await container.read(bootstrapProvider.future);
      await settle();

      expect(await deleteAccountAndData(ref), isNull);
      await settle();

      expect(seeder.calls, 2, reason: 'the wiped bucket must be re-seeded');
      expect(container.read(sheetsProvider).valueOrNull, isNotEmpty,
          reason: 'the UI reads its content through this stream');
    });
  });
}

/// Stands in for the real seeder: records the calls and writes just enough for
/// the content streams to have something to report.
class _CountingSeedService extends SeedService {
  _CountingSeedService(super.db) : _db = db;
  final AppDatabase _db;
  int calls = 0;

  @override
  Future<void> ensureSeeded() async {
    calls++;
    if ((await _db.select(_db.sheets).get()).isNotEmpty) return;
    await _db.into(_db.sheets).insert(SheetsCompanion.insert(
          slug: 'seeded-$calls',
          title: 'Seeded',
          category: 'dsa',
        ));
  }
}

/// The deletion flows take a WidgetRef (they are called from the profile
/// screen). They only ever read and invalidate, so a thin adapter over a
/// ProviderContainer lets them run without a widget tree — Drift deadlocks
/// under a widget test's fake async.
class _ContainerRef implements WidgetRef {
  _ContainerRef(this._container);
  final ProviderContainer _container;

  @override
  T read<T>(ProviderListenable<T> provider) => _container.read(provider);

  @override
  void invalidate(ProviderOrFamily provider) => _container.invalidate(provider);

  @override
  BuildContext get context => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
      'the deletion flows should only read and invalidate');
}
