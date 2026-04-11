import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/providers.dart';

/// Streams recent workouts, newest first.
final historyProvider = StreamProvider<List<Workout>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentWorkouts();
});

/// Streams the exercises (with snapshots + completion) for a single workout.
final workoutExercisesProvider =
    StreamProvider.family<List<WorkoutExercise>, int>((ref, workoutId) {
  final db = ref.watch(databaseProvider);
  return db.watchExercisesForWorkout(workoutId);
});
