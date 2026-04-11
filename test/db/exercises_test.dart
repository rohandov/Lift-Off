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

  test('updating default sets and reps persists', () async {
    final bench = await (db.select(db.exercises)
          ..where((t) => t.name.equals('Bench Press')))
        .getSingle();

    await (db.update(db.exercises)..where((t) => t.id.equals(bench.id))).write(
      const ExercisesCompanion(
        defaultSets: Value(5),
        defaultReps: Value('5'),
      ),
    );

    final after = await (db.select(db.exercises)
          ..where((t) => t.id.equals(bench.id)))
        .getSingle();
    expect(after.defaultSets, 5);
    expect(after.defaultReps, '5');
  });

  test('adding a custom exercise appears in watchExercises stream',
      () async {
    final stream = db.select(db.exercises).watch();
    final first = await stream.first;
    expect(first.any((e) => e.isCustom), isFalse);

    await db.into(db.exercises).insert(
          ExercisesCompanion.insert(
            name: 'My Funky Lift',
            iconName: 'star',
            defaultSets: 4,
            defaultReps: '6',
            isCustom: const Value(true),
          ),
        );

    final second = await stream.first;
    expect(second.length, 26);
    expect(second.any((e) => e.name == 'My Funky Lift' && e.isCustom), isTrue);
  });
}
