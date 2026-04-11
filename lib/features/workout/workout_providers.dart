import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/models/workout_session.dart';

final currentWorkoutProvider =
    NotifierProvider<WorkoutNotifier, WorkoutSession?>(WorkoutNotifier.new);

class WorkoutNotifier extends Notifier<WorkoutSession?> {
  @override
  WorkoutSession? build() => null;

  void start(List<SessionExercise> exercises) {
    state = WorkoutSession(
      startedAt: DateTime.now(),
      exercises: List<SessionExercise>.unmodifiable(exercises),
    );
  }

  void toggleAt(int index) {
    final current = state;
    if (current == null) return;
    state = current.toggleAt(index);
  }

  void discard() => state = null;
}
