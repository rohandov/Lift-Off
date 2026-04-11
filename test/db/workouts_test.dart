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

  test('saving a workout writes snapshot fields that survive a later rename',
      () async {
    final bench = await (db.select(db.exercises)
          ..where((t) => t.name.equals('Bench Press')))
        .getSingle();
    final squat = await (db.select(db.exercises)
          ..where((t) => t.name.equals('Back Squat')))
        .getSingle();

    final start = DateTime(2026, 4, 11, 10, 0);
    final finish = DateTime(2026, 4, 11, 10, 30);
    final workoutId = await db.into(db.workouts).insert(
          WorkoutsCompanion.insert(
            startedAt: start,
            finishedAt: finish,
          ),
        );

    await db.batch((b) {
      b.insertAll(db.workoutExercises, [
        WorkoutExercisesCompanion.insert(
          workoutId: workoutId,
          exerciseId: Value(bench.id),
          position: 1,
          nameSnapshot: bench.name,
          setsSnapshot: bench.defaultSets,
          repsSnapshot: bench.defaultReps,
          wasCompleted: const Value(true),
        ),
        WorkoutExercisesCompanion.insert(
          workoutId: workoutId,
          exerciseId: Value(squat.id),
          position: 2,
          nameSnapshot: squat.name,
          setsSnapshot: squat.defaultSets,
          repsSnapshot: squat.defaultReps,
          wasCompleted: const Value(false),
        ),
      ]);
    });

    // Rename Bench Press AFTER the workout is saved.
    await (db.update(db.exercises)..where((t) => t.id.equals(bench.id))).write(
      const ExercisesCompanion(name: Value('Flat Bench')),
    );

    final rows = await (db.select(db.workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    expect(rows.length, 2);
    expect(rows[0].nameSnapshot, 'Bench Press'); // preserved
    expect(rows[0].wasCompleted, isTrue);
    expect(rows[1].nameSnapshot, 'Back Squat');
    expect(rows[1].wasCompleted, isFalse);
  });
}
