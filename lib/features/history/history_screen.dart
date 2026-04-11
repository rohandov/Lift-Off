import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            itemBuilder: (ctx, i) => WorkoutTile(workout: workouts[i]),
          );
        },
      ),
    );
  }
}
