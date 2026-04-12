import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/providers.dart';
import 'package:lift_off/features/history/history_providers.dart';
import 'package:lift_off/features/history/widgets/workout_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (workouts) {
          if (workouts.isEmpty) {
            return const Center(child: Text('No workouts yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: workouts.length,
            itemBuilder: (ctx, i) {
              final workout = workouts[i];
              return Dismissible(
                key: ValueKey(workout.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, workout),
                onDismissed: (_) {
                  final db = ref.read(databaseProvider);
                  db.deleteWorkout(workout.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: WorkoutTile(workout: workout),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, dynamic workout) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
  }
}
