import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
    tables: [Exercises, Workouts, WorkoutExercises, Settings, Presets, PresetExercises])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'lift_off'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(presets);
            await migrator.createTable(presetExercises);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Stream<List<Workout>> watchRecentWorkouts() {
    return (select(workouts)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  Stream<List<WorkoutExercise>> watchExercisesForWorkout(int workoutId) {
    return (select(workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  // --- Presets ---

  Stream<List<Preset>> watchPresets() {
    return (select(presets)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<int>> getPresetExerciseIds(int presetId) async {
    final rows = await (select(presetExercises)
          ..where((t) => t.presetId.equals(presetId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => r.exerciseId).toList();
  }

  Future<void> savePreset(String name, List<int> exerciseIds) {
    return transaction(() async {
      final presetId = await into(presets).insert(
        PresetsCompanion.insert(name: name),
      );
      for (var i = 0; i < exerciseIds.length; i++) {
        await into(presetExercises).insert(
          PresetExercisesCompanion.insert(
            presetId: presetId,
            exerciseId: exerciseIds[i],
            position: i,
          ),
        );
      }
    });
  }

  Future<void> deletePreset(int presetId) {
    return (delete(presets)..where((t) => t.id.equals(presetId))).go();
  }

  Future<void> deleteWorkout(int workoutId) {
    return (delete(workouts)..where((t) => t.id.equals(workoutId))).go();
  }
}
