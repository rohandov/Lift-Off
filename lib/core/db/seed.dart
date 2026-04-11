import 'package:drift/drift.dart';

import 'database.dart';

/// Inserts the curated exercise library if the exercises table is empty.
/// Idempotent — safe to call on every app launch.
Future<void> seedIfEmpty(AppDatabase db) async {
  final count = await db
      .customSelect('SELECT COUNT(*) AS c FROM exercises')
      .getSingle();
  if ((count.data['c'] as int) > 0) return;

  const seeds = <_Seed>[
    // Push
    _Seed('Bench Press', 'fitness_center', 3, '8'),
    _Seed('Overhead Press', 'fitness_center', 3, '8'),
    _Seed('Incline DB Press', 'fitness_center', 3, '10'),
    _Seed('Dips', 'accessibility_new', 3, '10'),
    _Seed('Tricep Pushdown', 'fitness_center', 3, '12'),
    _Seed('Lateral Raise', 'fitness_center', 3, '15'),
    // Pull
    _Seed('Deadlift', 'fitness_center', 3, '5'),
    _Seed('Barbell Row', 'fitness_center', 3, '8'),
    _Seed('Pull-Up', 'accessibility_new', 3, 'max'),
    _Seed('Lat Pulldown', 'fitness_center', 3, '10'),
    _Seed('Seated Cable Row', 'fitness_center', 3, '10'),
    _Seed('Face Pull', 'fitness_center', 3, '15'),
    _Seed('Bicep Curl', 'fitness_center', 3, '12'),
    // Legs
    _Seed('Back Squat', 'fitness_center', 3, '8'),
    _Seed('Front Squat', 'fitness_center', 3, '8'),
    _Seed('Romanian Deadlift', 'fitness_center', 3, '10'),
    _Seed('Leg Press', 'fitness_center', 3, '10'),
    _Seed('Walking Lunge', 'directions_walk', 3, '10'),
    _Seed('Leg Curl', 'fitness_center', 3, '12'),
    _Seed('Calf Raise', 'fitness_center', 3, '15'),
    // Core/Other
    _Seed('Plank', 'timer', 3, '60s'),
    _Seed('Hanging Leg Raise', 'accessibility_new', 3, '10'),
    _Seed('Ab Wheel', 'sports_gymnastics', 3, '10'),
    _Seed('Farmer Carry', 'directions_walk', 3, '40s'),
    _Seed('Kettlebell Swing', 'fitness_center', 3, '15'),
  ];

  await db.batch((b) {
    b.insertAll(
      db.exercises,
      [
        for (final s in seeds)
          ExercisesCompanion.insert(
            name: s.name,
            iconName: s.iconName,
            defaultSets: s.defaultSets,
            defaultReps: s.defaultReps,
          ),
      ],
    );
  });
}

class _Seed {
  final String name;
  final String iconName;
  final int defaultSets;
  final String defaultReps;
  const _Seed(this.name, this.iconName, this.defaultSets, this.defaultReps);
}
