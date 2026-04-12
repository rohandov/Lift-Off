import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';
import 'package:lift_off/core/providers.dart';
import 'package:lift_off/features/library/library_providers.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/models/workout_session.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentWorkoutProvider);
    if (session == null) {
      // Defensive: if the session is gone, go back to the library.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard workout?'),
            content: const Text('Your current workout will be lost.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Discard')),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          ref.read(currentWorkoutProvider.notifier).discard();
          ref.read(selectionProvider.notifier).clear();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          itemCount: session.exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final ex = session.exercises[i];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: Key('workout-row-$i'),
                leading: Icon(iconFor(ex.iconName),
                    color: ex.isCompleted ? Colors.white38 : null),
                title: Text(
                  ex.name,
                  style: TextStyle(
                    decoration:
                        ex.isCompleted ? TextDecoration.lineThrough : null,
                    color: ex.isCompleted ? Colors.white38 : null,
                  ),
                ),
                subtitle: Text(
                  '${ex.sets} × ${ex.reps}',
                  style: TextStyle(
                    color: ex.isCompleted ? Colors.white24 : null,
                  ),
                ),
                trailing: _TrailingStatus(exercise: ex),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  for (var s = 0; s < ex.sets; s++)
                    CheckboxListTile(
                      key: Key('workout-row-$i-set-$s'),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: ex.completedSets[s],
                      onChanged: (_) => ref
                          .read(currentWorkoutProvider.notifier)
                          .toggleSetAt(i, s),
                      title: Text('Set ${s + 1}'),
                      subtitle: Text('${ex.reps} reps'),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              key: const Key('finish-button'),
              style: session.allDone
                  ? null
                  : FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
              onPressed: () => _finish(context, ref, session),
              child: Text(session.allDone ? 'Finish' : 'Finish early'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish(
      BuildContext context, WidgetRef ref, WorkoutSession session) async {
    final db = ref.read(databaseProvider);
    try {
      await db.transaction(() async {
        final workoutId = await db.into(db.workouts).insert(
              WorkoutsCompanion.insert(
                startedAt: session.startedAt,
                finishedAt: DateTime.now(),
              ),
            );
        await db.batch((b) {
          b.insertAll(
            db.workoutExercises,
            [
              for (var i = 0; i < session.exercises.length; i++)
                WorkoutExercisesCompanion.insert(
                  workoutId: workoutId,
                  exerciseId: Value(session.exercises[i].exerciseId),
                  position: i + 1,
                  nameSnapshot: session.exercises[i].name,
                  setsSnapshot: session.exercises[i].sets,
                  repsSnapshot: session.exercises[i].reps,
                  wasCompleted: Value(session.exercises[i].isCompleted),
                ),
            ],
          );
        });
      });
      ref.read(currentWorkoutProvider.notifier).discard();
      ref.read(selectionProvider.notifier).clear();
      if (context.mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save workout')),
        );
      }
    }
  }
}

class _TrailingStatus extends StatelessWidget {
  const _TrailingStatus({required this.exercise});
  final SessionExercise exercise;

  @override
  Widget build(BuildContext context) {
    if (exercise.isCompleted) {
      return const Icon(Icons.check_circle, color: Colors.greenAccent);
    }
    final done = exercise.completedSets.where((c) => c).length;
    return Text(
      '$done/${exercise.sets}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
