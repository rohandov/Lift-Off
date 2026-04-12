import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';
import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/core/widgets/gradient_card.dart';
import 'package:lift_off/features/library/library_providers.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/features/presets/widgets/save_preset_sheet.dart';
import 'package:lift_off/features/workout/workout_screen.dart';
import 'package:lift_off/models/workout_session.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save as preset',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const SavePresetSheet(),
            ),
          ),
        ],
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final byId = {for (final e in all) e.id: e};
          final ordered = [
            for (final id in selection)
              if (byId[id] != null) byId[id]!,
          ];
          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
            itemCount: ordered.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(selectionProvider.notifier).reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, i) {
              final ex = ordered[i];
              return GradientCard(
                key: ValueKey(ex.id),
                gradient: gradientForId(ex.id),
                child: ListTile(
                  leading: Icon(iconFor(ex.iconName)),
                  title: Text(ex.name),
                  subtitle: Text('${ex.defaultSets} × ${ex.defaultReps}'),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: () => _start(context, ref),
            child: const Text('Start Workout'),
          ),
        ),
      ),
    );
  }

  void _start(BuildContext context, WidgetRef ref) {
    final selection = ref.read(selectionProvider);
    final all = ref.read(exercisesProvider).asData?.value ?? const [];
    final byId = {for (final e in all) e.id: e};
    final sessionExercises = <SessionExercise>[
      for (final id in selection)
        if (byId[id] != null) SessionExercise.fromExercise(byId[id]!),
    ];
    if (sessionExercises.isEmpty) return;
    ref.read(currentWorkoutProvider.notifier).start(sessionExercises);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WorkoutScreen()),
    );
  }
}
