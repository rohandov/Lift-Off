import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/providers.dart';
import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/core/widgets/gradient_card.dart';
import 'package:lift_off/features/library/library_providers.dart';
import 'package:lift_off/features/presets/preset_providers.dart';
import 'package:lift_off/features/review/review_screen.dart';

class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Presets')),
      body: presetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (presets) {
          if (presets.isEmpty) {
            return const Center(
              child: Text('No presets saved yet'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: presets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final preset = presets[i];
              return Dismissible(
                key: ValueKey(preset.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, preset),
                onDismissed: (_) {
                  final db = ref.read(databaseProvider);
                  db.deletePreset(preset.id);
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
                child: GradientCard(
                  gradient: gradientForId(preset.id),
                  child: InkWell(
                    onTap: () => _load(context, ref, preset.id),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.bookmarks_outlined, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              preset.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _load(BuildContext context, WidgetRef ref, int presetId) async {
    final db = ref.read(databaseProvider);
    final ids = await db.getPresetExerciseIds(presetId);
    if (ids.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('All exercises in this preset have been deleted')),
        );
      }
      return;
    }
    ref.read(selectionProvider.notifier).loadFrom(ids);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReviewScreen()),
      );
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, dynamic preset) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete preset?'),
        content: Text('Remove "${preset.name}"?'),
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
