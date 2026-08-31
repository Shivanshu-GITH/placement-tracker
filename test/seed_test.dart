import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/data/database/database.dart';
import 'package:preppilot/data/repositories/seed_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed loads all content packs + resources into the DB', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await SeedService(db).ensureSeeded();

    final sheets = (await db.select(db.sheets).get()).length;
    final allNodes = await db.select(db.nodes).get();
    final nodes = allNodes.length;
    final leaves = allNodes.where((n) => n.kind == 'leaf').toList();
    final resources = await db.select(db.resources).get();
    final free = resources.where((r) => r.tier == 'free').length;
    final paid = resources.where((r) => r.tier == 'paid').length;
    final userSheets = await db.select(db.userSheets).get();

    expect(sheets, 17);
    expect(nodes, greaterThan(2900));
    expect(leaves.length, greaterThan(2600));
    expect(resources.length, 60);
    expect(free, 44);
    expect(paid, 16);
    // Every paid resource ships with an (empty) affiliate slot to fill later.
    expect(resources.where((r) => r.tier == 'paid').every((r) => r.affiliateUrl == ''),
        isTrue);
    // A default sheet selection exists.
    expect(userSheets.where((u) => u.active).length, greaterThan(0));
    expect(userSheets.where((u) => u.isPrimary).length, 1);
  });
}
