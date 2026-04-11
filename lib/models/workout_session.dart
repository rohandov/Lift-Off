import 'package:lift_off/core/db/database.dart';

/// A single exercise entry in an in-progress workout.
class SessionExercise {
  final int exerciseId;
  final String name;
  final String iconName;
  final int sets;
  final String reps;
  final bool isCompleted;

  const SessionExercise({
    required this.exerciseId,
    required this.name,
    required this.iconName,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });

  SessionExercise copyWith({bool? isCompleted}) => SessionExercise(
        exerciseId: exerciseId,
        name: name,
        iconName: iconName,
        sets: sets,
        reps: reps,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  factory SessionExercise.fromExercise(Exercise e) => SessionExercise(
        exerciseId: e.id,
        name: e.name,
        iconName: e.iconName,
        sets: e.defaultSets,
        reps: e.defaultReps,
      );
}

/// In-progress workout state held in memory from Start → Finish.
class WorkoutSession {
  final DateTime startedAt;
  final List<SessionExercise> exercises;

  const WorkoutSession({required this.startedAt, required this.exercises});

  bool get allDone =>
      exercises.isNotEmpty && exercises.every((e) => e.isCompleted);

  WorkoutSession toggleAt(int index) {
    final next = List<SessionExercise>.from(exercises);
    next[index] = next[index].copyWith(isCompleted: !next[index].isCompleted);
    return WorkoutSession(startedAt: startedAt, exercises: next);
  }
}
