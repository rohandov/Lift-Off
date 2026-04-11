import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
  });

  tearDown(() => db.close());

  test('watchRecentWorkouts returns newest first', () async {
    await db.into(db.workouts).insert(WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 4, 9, 9, 0),
          finishedAt: DateTime(2026, 4, 9, 9, 30),
        ));
    await db.into(db.workouts).insert(WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 4, 11, 9, 0),
          finishedAt: DateTime(2026, 4, 11, 9, 30),
        ));
    await db.into(db.workouts).insert(WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 4, 10, 9, 0),
          finishedAt: DateTime(2026, 4, 10, 9, 30),
        ));

    final list = await db.watchRecentWorkouts().first;
    expect(list.map((w) => w.startedAt.day), [11, 10, 9]);
  });
}
