import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:preppilot/data/database/database.dart';
import 'package:preppilot/data/repositories/roadmap_repository.dart';

void main() {
  test('roadmap generates from the primary sheet\'s real section order', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // --- primary DSA sheet: Arrays{Easy(3),Medium(3)} + Trees(4 leaves) ------
    final dsaId = await db.into(db.sheets).insert(SheetsCompanion.insert(
        slug: 'dsa1', title: 'DSA One', category: 'dsa'));
    Future<int> section(int sheet, int? parent, String slug, String title,
            int order) =>
        db.into(db.nodes).insert(NodesCompanion.insert(
              sheetId: sheet,
              parentId: Value(parent),
              slug: slug,
              title: title,
              kind: const Value('section'),
              orderIndex: Value(order),
            ));
    Future<void> leaf(int sheet, int parent, String slug, int order) =>
        db.into(db.nodes).insert(NodesCompanion.insert(
              sheetId: sheet,
              parentId: Value(parent),
              slug: slug,
              title: slug,
              kind: const Value('leaf'),
              leafType: const Value('problem'),
              canon: Value('u:$slug'),
              orderIndex: Value(order),
            ));

    final arrays = await section(dsaId, null, 'arrays', 'Arrays', 0);
    final easy = await section(dsaId, arrays, 'arrays-easy', 'Easy', 0);
    final med = await section(dsaId, arrays, 'arrays-med', 'Medium', 1);
    for (var i = 0; i < 3; i++) {
      await leaf(dsaId, easy, 'e$i', i);
    }
    for (var i = 0; i < 3; i++) {
      await leaf(dsaId, med, 'm$i', i);
    }
    final trees = await section(dsaId, null, 'trees', 'Trees', 1);
    for (var i = 0; i < 4; i++) {
      await leaf(dsaId, trees, 't$i', i);
    }

    // --- active theory sheet: OS(3 concepts) --------------------------------
    final coreId = await db.into(db.sheets).insert(SheetsCompanion.insert(
        slug: 'core1', title: 'Core One', category: 'core'));
    final os = await section(coreId, null, 'os', 'Operating Systems', 0);
    for (var i = 0; i < 3; i++) {
      await db.into(db.nodes).insert(NodesCompanion.insert(
            sheetId: coreId,
            parentId: Value(os),
            slug: 'os$i',
            title: 'os concept $i',
            kind: const Value('leaf'),
            leafType: const Value('concept'),
            canon: Value('u:os$i'),
            orderIndex: Value(i),
          ));
    }

    // selection: dsa1 primary+active, core1 active
    await db.into(db.userSheets).insert(UserSheetsCompanion.insert(
        sheetId: Value(dsaId), active: const Value(true), isPrimary: const Value(true)));
    await db.into(db.userSheets).insert(UserSheetsCompanion.insert(
        sheetId: Value(coreId), active: const Value(true)));

    await db.into(db.userProfiles).insert(const UserProfilesCompanion());
    final profile = await db.select(db.userProfiles).getSingle();

    await RoadmapRepository(db).generate(profile);

    final tasks = await db.select(db.roadmapTasks).get();
    final titles = tasks.map((t) => t.title).toList();

    // New behaviour: titles reference real sections, not the old "DSA focus".
    expect(titles.any((t) => t.contains('DSA focus')), isFalse,
        reason: 'should not use old category-focus titles');
    expect(titles.any((t) => t.contains('Arrays')), isTrue,
        reason: 'DSA tasks should name real sections from the primary sheet');
    expect(titles.any((t) => t.contains('Operating Systems')), isTrue,
        reason: 'theory should be interleaved from active sheets');
    // A DSA task's target should equal real problem counts, not a formula.
    final dsaTargets =
        tasks.where((t) => t.category == 'dsa').map((t) => t.targetProblems);
    expect(dsaTargets.fold<int>(0, (s, e) => s + e), 10,
        reason: 'all 10 primary-sheet problems should be scheduled');
  });
}
