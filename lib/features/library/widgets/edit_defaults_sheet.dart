import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/providers.dart';

class EditDefaultsSheet extends ConsumerStatefulWidget {
  final Exercise exercise;
  const EditDefaultsSheet({super.key, required this.exercise});

  @override
  ConsumerState<EditDefaultsSheet> createState() => _EditDefaultsSheetState();
}

class _EditDefaultsSheetState extends ConsumerState<EditDefaultsSheet> {
  late final TextEditingController _setsCtrl =
      TextEditingController(text: '${widget.exercise.defaultSets}');
  late final TextEditingController _repsCtrl =
      TextEditingController(text: widget.exercise.defaultReps);

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sets = int.tryParse(_setsCtrl.text.trim());
    if (sets == null || sets <= 0) return;
    final reps = _repsCtrl.text.trim();
    if (reps.isEmpty) return;

    final db = ref.read(databaseProvider);
    await (db.update(db.exercises)..where((t) => t.id.equals(widget.exercise.id)))
        .write(ExercisesCompanion(
      defaultSets: Value(sets),
      defaultReps: Value(reps),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.exercise.name,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _setsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sets'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repsCtrl,
            decoration: const InputDecoration(
              labelText: 'Reps',
              helperText: 'Free form: "8", "max", "60s"',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
