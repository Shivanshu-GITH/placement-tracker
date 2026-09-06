import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/data/database/database.dart';
import 'package:preppilot/data/repositories/prep_repository.dart';

/// The status button used to decide its next value in the widget, from the row
/// that build() had rendered. A second tap landing before the Drift stream
/// re-emitted therefore recomputed from the stale status and wrote the same
/// value again, silently dropping the tap — which is how an item could stay in
/// "revisit" (and keep being counted) after the user had cycled it away.
///
/// The transition is now resolved inside the transaction from what is stored,
/// so back-to-back calls each advance one step.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PrepRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PrepRepository(db);
  });
  tearDown(() => db.close());

  Future<String?> statusOf(String canon) async {
    final row = await (db.select(db.leafProgress)
          ..where((t) => t.canon.equals(canon)))
        .getSingleOrNull();
    return row?.status;
  }

  group('problem status cycle', () {
    test('advances one step per call from the stored value', () async {
      await repo.cycleLeafStatus('p1', isConcept: false);
      expect(await statusOf('p1'), 'attempted');
      await repo.cycleLeafStatus('p1', isConcept: false);
      expect(await statusOf('p1'), 'solved');
      await repo.cycleLeafStatus('p1', isConcept: false);
      expect(await statusOf('p1'), 'revisit');
      // ...and wraps back around, clearing the revisit state.
      await repo.cycleLeafStatus('p1', isConcept: false);
      expect(await statusOf('p1'), 'todo');
    });

    test('two rapid cycles land two steps on, not one', () async {
      // Fired without awaiting the first — the old widget-side cycle would have
      // computed both from 'todo' and left the row on 'attempted'.
      await Future.wait([
        repo.cycleLeafStatus('p2', isConcept: false),
        repo.cycleLeafStatus('p2', isConcept: false),
      ]);
      expect(await statusOf('p2'), 'solved');
    });

    test('cycling out of revisit really clears it', () async {
      await repo.setLeafStatus('p3', 'revisit');
      expect(await statusOf('p3'), 'revisit');
      await repo.cycleLeafStatus('p3', isConcept: false);
      expect(await statusOf('p3'), 'todo');
    });
  });

  group('concept status cycle', () {
    test('advances through its own states', () async {
      await repo.cycleLeafStatus('c1', isConcept: true);
      expect(await statusOf('c1'), 'learning');
      await repo.cycleLeafStatus('c1', isConcept: true);
      expect(await statusOf('c1'), 'done');
      await repo.cycleLeafStatus('c1', isConcept: true);
      expect(await statusOf('c1'), 'revise');
      await repo.cycleLeafStatus('c1', isConcept: true);
      expect(await statusOf('c1'), 'notStarted');
    });
  });

  group('done toggle', () {
    test('flips from the stored value both ways', () async {
      await repo.toggleLeafDone('p4', isConcept: false);
      expect(await statusOf('p4'), 'solved');
      await repo.toggleLeafDone('p4', isConcept: false);
      expect(await statusOf('p4'), 'todo');
    });

    test('two rapid toggles cancel out instead of being lost', () async {
      await Future.wait([
        repo.toggleLeafDone('p5', isConcept: false),
        repo.toggleLeafDone('p5', isConcept: false),
      ]);
      expect(await statusOf('p5'), 'todo');
    });

    test('a revisit item is treated as not-done and becomes solved', () async {
      await repo.setLeafStatus('p6', 'revisit');
      await repo.toggleLeafDone('p6', isConcept: false);
      expect(await statusOf('p6'), 'solved');
    });

    test('concepts use their own done/not-done names', () async {
      await repo.toggleLeafDone('c2', isConcept: true);
      expect(await statusOf('c2'), 'done');
      await repo.toggleLeafDone('c2', isConcept: true);
      expect(await statusOf('c2'), 'notStarted');
    });
  });
}
