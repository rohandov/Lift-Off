import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/providers.dart';
import 'package:lift_off/features/library/library_providers.dart';

class SavePresetSheet extends ConsumerStatefulWidget {
  const SavePresetSheet({super.key});

  @override
  ConsumerState<SavePresetSheet> createState() => _SavePresetSheetState();
}

class _SavePresetSheetState extends ConsumerState<SavePresetSheet> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final ids = ref.read(selectionProvider);
    if (ids.isEmpty) return;

    final db = ref.read(databaseProvider);
    await db.savePreset(name, ids);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preset "$name" saved')),
      );
    }
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
          Text('Save as preset',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Preset name'),
            autofocus: true,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
