import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Exercises, Workouts, WorkoutExercises, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'lift_off'));

  @override
  int get schemaVersion => 1;

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
}
