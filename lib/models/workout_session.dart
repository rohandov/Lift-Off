import 'package:lift_off/core/db/database.dart';

/// A single exercise entry in an in-progress workout.
class SessionExercise {
  final int exerciseId;
  final String name;
  final String iconName;
  final int sets;
  final String reps;
  final List<bool> completedSets;

  const SessionExercise({
    required this.exerciseId,
    required this.name,
    required this.iconName,
    required this.sets,
    required this.reps,
    required this.completedSets,
  });

  bool get isCompleted =>
      completedSets.isNotEmpty && completedSets.every((c) => c);

  SessionExercise copyWith({List<bool>? completedSets}) => SessionExercise(
        exerciseId: exerciseId,
        name: name,
        iconName: iconName,
        sets: sets,
        reps: reps,
        completedSets: completedSets ?? this.completedSets,
      );

  factory SessionExercise.fromExercise(Exercise e) => SessionExercise(
        exerciseId: e.id,
        name: e.name,
        iconName: e.iconName,
        sets: e.defaultSets,
        reps: e.defaultReps,
        completedSets: List<bool>.filled(e.defaultSets, false),
      );
}

/// In-progress workout state held in memory from Start → Finish.
class WorkoutSession {
  final DateTime startedAt;
  final List<SessionExercise> exercises;

  const WorkoutSession({required this.startedAt, required this.exercises});

  bool get allDone =>
      exercises.isNotEmpty && exercises.every((e) => e.isCompleted);

  WorkoutSession toggleSetAt(int exerciseIndex, int setIndex) {
    final next = List<SessionExercise>.from(exercises);
    final ex = next[exerciseIndex];
    final newCompleted = List<bool>.from(ex.completedSets);
    newCompleted[setIndex] = !newCompleted[setIndex];
    next[exerciseIndex] = ex.copyWith(completedSets: newCompleted);
    return WorkoutSession(startedAt: startedAt, exercises: next);
  }
}
