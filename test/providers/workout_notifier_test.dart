import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/models/workout_session.dart';

SessionExercise _ex(int id, String name, {int sets = 3}) => SessionExercise(
      exerciseId: id,
      name: name,
      iconName: 'fitness_center',
      sets: sets,
      reps: '8',
      completedSets: List<bool>.filled(sets, false),
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
    for (final e in session.exercises) {
      expect(e.completedSets.length, e.sets);
      expect(e.completedSets.every((c) => !c), isTrue);
      expect(e.isCompleted, isFalse);
    }
    expect(session.allDone, isFalse);
  });

  test(
      'toggleSetAt flips a single set, and auto-completes the exercise when all sets are checked',
      () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench'), _ex(2, 'Squat')]);

    notifier.toggleSetAt(0, 0);
    var session = container.read(currentWorkoutProvider)!;
    expect(session.exercises[0].completedSets[0], isTrue);
    expect(session.exercises[0].isCompleted, isFalse);
    expect(session.allDone, isFalse);

    notifier.toggleSetAt(0, 1);
    notifier.toggleSetAt(0, 2);
    session = container.read(currentWorkoutProvider)!;
    expect(session.exercises[0].isCompleted, isTrue);
    expect(session.allDone, isFalse);

    notifier.toggleSetAt(1, 0);
    notifier.toggleSetAt(1, 1);
    notifier.toggleSetAt(1, 2);
    session = container.read(currentWorkoutProvider)!;
    expect(session.allDone, isTrue);

    notifier.toggleSetAt(0, 0);
    expect(container.read(currentWorkoutProvider)!.allDone, isFalse);
    expect(container.read(currentWorkoutProvider)!.exercises[0].isCompleted,
        isFalse);
  });

  test('toggleSetAt is a no-op when session is null', () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    expect(container.read(currentWorkoutProvider), isNull);
    notifier.toggleSetAt(0, 0);
    expect(container.read(currentWorkoutProvider), isNull);
  });

  test('discard clears the session', () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench')]);
    notifier.discard();
    expect(container.read(currentWorkoutProvider), isNull);
  });
}
