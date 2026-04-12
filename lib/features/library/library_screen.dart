import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/features/history/history_screen.dart';
import 'package:lift_off/features/library/library_providers.dart';
import 'package:lift_off/features/library/widgets/add_exercise_sheet.dart';
import 'package:lift_off/features/library/widgets/edit_defaults_sheet.dart';
import 'package:lift_off/features/library/widgets/exercise_card.dart';
import 'package:lift_off/features/review/review_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider);
    final selection = ref.watch(selectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const GradientTitle(),
        actions: [
          IconButton(
            key: const Key('history-button'),
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exercises) => GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: exercises.length,
          itemBuilder: (context, i) {
            final ex = exercises[i];
            final isSelected = selection.contains(ex.id);
            return ExerciseCard(
              key: Key('exercise-card-${ex.id}'),
              exercise: ex,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(selectionProvider.notifier).toggle(ex.id),
              onLongPress: () => _showEditSheet(context, ex),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-exercise-fab'),
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            key: const Key('start-button'),
            onPressed: selection.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReviewScreen()),
                    ),
            child: Text('Start (${selection.length} selected)'),
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditDefaultsSheet(exercise: exercise),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddExerciseSheet(),
    );
  }
}
