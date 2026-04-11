import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/features/history/history_providers.dart';

class WorkoutTile extends ConsumerWidget {
  final Workout workout;
  const WorkoutTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(workoutExercisesProvider(workout.id));
    final dateStr = _formatDate(workout.startedAt);
    return Card(
      child: ExpansionTile(
        title: Text(dateStr),
        subtitle: exercisesAsync.when(
          data: (rows) => Text('${rows.length} exercises'),
          loading: () => const Text('…'),
          error: (_, __) => const Text('—'),
        ),
        children: [
          exercisesAsync.when(
            data: (rows) => Column(
              children: [
                for (final r in rows)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      r.wasCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: r.wasCompleted ? Colors.greenAccent : null,
                    ),
                    title: Text(r.nameSnapshot),
                    subtitle: Text('${r.setsSnapshot} × ${r.repsSnapshot}'),
                  ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
