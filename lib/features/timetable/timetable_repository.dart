import 'package:drift/drift.dart';

import '../../data/database/database.dart';
import 'timetable_models.dart';

/// Reads and writes the user's daily timetable.
class TimetableRepository {
  TimetableRepository(this._db);
  final AppDatabase _db;

  /// All blocks, ordered by start time then title.
  Stream<List<TimetableBlock>> watchBlocks() {
    final q = _db.select(_db.timetableBlocks)
      ..orderBy([
        (t) => OrderingTerm(expression: t.startMinute),
        (t) => OrderingTerm(expression: t.title),
      ]);
    return q.watch();
  }

  Future<List<TimetableBlock>> allBlocks() {
    final q = _db.select(_db.timetableBlocks)
      ..orderBy([(t) => OrderingTerm(expression: t.startMinute)]);
    return q.get();
  }

  Future<int> add({
    required String title,
    required int startMinute,
    required int durationMinutes,
    int daysMask = Weekdays.all,
    String category = '',
    bool reminder = true,
    int leadMinutes = 0,
  }) {
    return _db.into(_db.timetableBlocks).insert(
          TimetableBlocksCompanion.insert(
            title: title,
            startMinute: startMinute,
            durationMinutes: Value(durationMinutes),
            daysMask: Value(daysMask),
            category: Value(category),
            reminder: Value(reminder),
            leadMinutes: Value(leadMinutes),
          ),
        );
  }

  Future<void> update(TimetableBlock block) =>
      _db.update(_db.timetableBlocks).replace(block);

  Future<void> setEnabled(int id, bool enabled) {
    return (_db.update(_db.timetableBlocks)..where((t) => t.id.equals(id)))
        .write(TimetableBlocksCompanion(enabled: Value(enabled)));
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.timetableBlocks)..where((t) => t.id.equals(id))).go();
}
