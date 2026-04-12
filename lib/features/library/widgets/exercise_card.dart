import 'package:flutter/material.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';
import 'package:lift_off/core/theme/app_theme.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: Ink(
        decoration: BoxDecoration(
          gradient: isSelected ? null : gradientForId(exercise.id),
          color: isSelected ? accent.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(
            color: isSelected ? accent : kCardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(iconFor(exercise.iconName), size: 28),
                if (isSelected) Icon(Icons.check_circle, color: accent, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exercise.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '${exercise.defaultSets} × ${exercise.defaultReps}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
