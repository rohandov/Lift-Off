import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/models/workout_session.dart';

SessionExercise _ex(int id, String name) => SessionExercise(
      exerciseId: id,
      name: name,
      iconName: 'fitness_center',
      sets: 3,
      reps: '8',
    );

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('start creates a session with all rows uncompleted', () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench'), _ex(2, 'Squat')]);

    final session = container.read(currentWorkoutProvider)!;
    expect(session.exercises.length, 2);
    expect(session.exercises.every((e) => !e.isCompleted), isTrue);
    expect(session.allDone, isFalse);
  });

  test('toggle flips a row and updates allDone when everything is complete',
      () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench'), _ex(2, 'Squat')]);

    notifier.toggleAt(0);
    expect(container.read(currentWorkoutProvider)!.exercises[0].isCompleted,
        isTrue);
    expect(container.read(currentWorkoutProvider)!.allDone, isFalse);

    notifier.toggleAt(1);
    expect(container.read(currentWorkoutProvider)!.allDone, isTrue);

    notifier.toggleAt(0);
    expect(container.read(currentWorkoutProvider)!.allDone, isFalse);
  });

  test('discard clears the session', () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench')]);
    notifier.discard();
    expect(container.read(currentWorkoutProvider), isNull);
  });
}
