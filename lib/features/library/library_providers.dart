import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/providers.dart';

/// Streams the full exercise library.
final exercisesProvider = StreamProvider<List<Exercise>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.exercises).watch();
});

/// Ordered list of currently-selected exercise IDs.
final selectionProvider =
    NotifierProvider<SelectionNotifier, List<int>>(SelectionNotifier.new);

class SelectionNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => const [];

  void toggle(int id) {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
    } else {
      state = [...state, id];
    }
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    // ReorderableListView adjusts newIndex when moving down; we don't here
    // because tests call us with the final target index.
    final item = list.removeAt(oldIndex);
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(target, item);
    state = list;
  }

  void clear() => state = const [];
}
