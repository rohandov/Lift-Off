# Lift Off Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a speed-first card-based workout app for iOS and Android in Flutter, matching the approved spec (`docs/superpowers/specs/2026-04-11-lift-off-workout-app-design.md`).

**Architecture:** Flutter app using Riverpod for state management and Drift (type-safe SQLite) for local storage. Feature-based folder structure with `core/` for shared infrastructure and `features/` for each screen. No backend, no auth, no network.

**Tech Stack:** Flutter (stable), Dart 3, Riverpod 2, Drift 2, SQLite, Material Icons.

---

## Conventions

- **Working directory:** `/Users/rohanvora/Documents/GitHub/lift_off` (root of the Flutter project). All `flutter` and `dart` commands below assume this CWD unless noted.
- **Running tests:** `flutter test <path>` runs a specific file; `flutter test` runs the whole suite.
- **Code generation:** `dart run build_runner build --delete-conflicting-outputs` regenerates Drift-generated files. Re-run whenever you change `tables.dart` or `database.dart`.
- **Commits:** After each task completes and tests pass, commit with a conventional message (`feat:`, `test:`, `chore:`).
- **Git:** If this project is not yet a git repo, the very first task initializes it.

## File Structure

```
lift_off/
├── pubspec.yaml                              # modified: add dependencies
├── .gitignore                                # modified: add .superpowers/, generated files
│
├── lib/
│   ├── main.dart                             # modified: ProviderScope + init DB + runApp
│   ├── app.dart                              # new: MaterialApp + theme + routing
│   │
│   ├── core/
│   │   ├── db/
│   │   │   ├── tables.dart                   # new: Drift table definitions
│   │   │   ├── database.dart                 # new: @DriftDatabase class
│   │   │   ├── database.g.dart               # generated
│   │   │   └── seed.dart                     # new: idempotent seed of 25 exercises
│   │   ├── theme/
│   │   │   └── app_theme.dart                # new
│   │   └── providers.dart                    # new: databaseProvider
│   │
│   ├── features/
│   │   ├── library/
│   │   │   ├── library_screen.dart           # new
│   │   │   ├── library_providers.dart        # new: exercisesProvider, selectionProvider
│   │   │   └── widgets/
│   │   │       ├── exercise_card.dart
│   │   │       ├── edit_defaults_sheet.dart
│   │   │       └── add_exercise_sheet.dart
│   │   ├── review/
│   │   │   └── review_screen.dart            # new
│   │   ├── workout/
│   │   │   ├── workout_screen.dart           # new
│   │   │   └── workout_providers.dart        # new
│   │   └── history/
│   │       ├── history_screen.dart           # new
│   │       ├── history_providers.dart        # new
│   │       └── widgets/
│   │           └── workout_tile.dart         # new
│   │
│   └── models/
│       └── workout_session.dart              # new
│
└── test/
    ├── db/
    │   ├── seed_test.dart                    # new
    │   ├── exercises_test.dart               # new
    │   ├── workouts_test.dart                # new
    │   └── history_test.dart                 # new
    ├── providers/
    │   ├── selection_notifier_test.dart      # new
    │   └── workout_notifier_test.dart        # new
    └── widgets/
        ├── library_screen_test.dart          # new
        └── workout_screen_test.dart          # new
```

---

## Task 1: Initialize git and update .gitignore

**Files:**
- Create/modify: `.gitignore`
- Git: init repo

- [ ] **Step 1: Check whether the project is already a git repo**

Run: `git rev-parse --is-inside-work-tree 2>/dev/null || echo "no-git"`
Expected: `no-git` (skip init if it prints `true`).

- [ ] **Step 2: Initialize the git repo if needed**

Run: `git init && git add -A && git commit -m "chore: initial flutter scaffold"`
Expected: a single initial commit containing the `flutter create` output.

- [ ] **Step 3: Append entries to .gitignore**

Append these lines to `/Users/rohanvora/Documents/GitHub/lift_off/.gitignore` (don't duplicate if already present):

```
# Drift generated
*.g.dart

# Superpowers brainstorm session data
.superpowers/
```

- [ ] **Step 4: Commit the .gitignore change**

```bash
git add .gitignore
git commit -m "chore: ignore generated files and brainstorm session data"
```

---

## Task 2: Add project dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Edit `pubspec.yaml` — replace the `dependencies:` and `dev_dependencies:` sections**

Replace the existing `dependencies:` and `dev_dependencies:` blocks with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  drift: ^2.22.0
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.26
  path_provider: ^2.1.5
  path: ^1.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  drift_dev: ^2.22.0
```

- [ ] **Step 2: Fetch dependencies**

Run: `flutter pub get`
Expected: no errors, `Got dependencies!` at the end.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add riverpod, drift, and supporting deps"
```

---

## Task 3: Define Drift tables

**Files:**
- Create: `lib/core/db/tables.dart`

- [ ] **Step 1: Create the file with all four tables**

Full contents of `lib/core/db/tables.dart`:

```dart
import 'package:drift/drift.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get iconName => text()();
  IntColumn get defaultSets => integer()();
  TextColumn get defaultReps => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime()();
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer()
      .nullable()
      .references(Exercises, #id, onDelete: KeyAction.setNull)();
  IntColumn get position => integer()();
  TextColumn get nameSnapshot => text()();
  IntColumn get setsSnapshot => integer()();
  TextColumn get repsSnapshot => text()();
  BoolColumn get wasCompleted => boolean().withDefault(const Constant(false))();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/db/tables.dart
git commit -m "feat(db): define drift tables for exercises, workouts, history"
```

---

## Task 4: Create the Drift Database class

**Files:**
- Create: `lib/core/db/database.dart`

- [ ] **Step 1: Create the Database class**

Full contents of `lib/core/db/database.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Exercises, Workouts, WorkoutExercises, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'lift_off'));

  @override
  int get schemaVersion => 1;
}
```

- [ ] **Step 2: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: prints `[INFO] Succeeded after ...`. Creates `lib/core/db/database.g.dart`.

- [ ] **Step 3: Verify the generated file exists**

Run: `ls lib/core/db/database.g.dart`
Expected: file exists.

- [ ] **Step 4: Commit (do NOT commit the generated file — it's in .gitignore)**

```bash
git add lib/core/db/database.dart
git commit -m "feat(db): add AppDatabase class with drift codegen"
```

---

## Task 5: Seed data — module and test for idempotency

**Files:**
- Create: `lib/core/db/seed.dart`
- Create: `test/db/seed_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/db/seed_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('seedIfEmpty inserts the curated exercises on an empty db', () async {
    final before = await db.select(db.exercises).get();
    expect(before, isEmpty);

    await seedIfEmpty(db);

    final after = await db.select(db.exercises).get();
    expect(after.length, 25);
    expect(after.any((e) => e.name == 'Bench Press'), isTrue);
  });

  test('seedIfEmpty is idempotent — does not duplicate on second call',
      () async {
    await seedIfEmpty(db);
    await seedIfEmpty(db);

    final rows = await db.select(db.exercises).get();
    expect(rows.length, 25);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/db/seed_test.dart`
Expected: FAIL — `seedIfEmpty` is not defined.

- [ ] **Step 3: Implement `seed.dart`**

Create `lib/core/db/seed.dart`:

```dart
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
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/db/seed_test.dart`
Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/seed.dart test/db/seed_test.dart
git commit -m "feat(db): seed curated exercise library, idempotent"
```

---

## Task 6: Exercise edit + custom add — DB tests

**Files:**
- Create: `test/db/exercises_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/db/exercises_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
  });

  tearDown(() => db.close());

  test('updating default sets and reps persists', () async {
    final bench = await (db.select(db.exercises)
          ..where((t) => t.name.equals('Bench Press')))
        .getSingle();

    await (db.update(db.exercises)..where((t) => t.id.equals(bench.id))).write(
      const ExercisesCompanion(
        defaultSets: Value(5),
        defaultReps: Value('5'),
      ),
    );

    final after = await (db.select(db.exercises)
          ..where((t) => t.id.equals(bench.id)))
        .getSingle();
    expect(after.defaultSets, 5);
    expect(after.defaultReps, '5');
  });

  test('adding a custom exercise appears in watchExercises stream',
      () async {
    final stream = db.select(db.exercises).watch();
    final first = await stream.first;
    expect(first.any((e) => e.isCustom), isFalse);

    await db.into(db.exercises).insert(
          ExercisesCompanion.insert(
            name: 'My Funky Lift',
            iconName: 'star',
            defaultSets: 4,
            defaultReps: '6',
            isCustom: const Value(true),
          ),
        );

    final second = await stream.first;
    expect(second.length, 26);
    expect(second.any((e) => e.name == 'My Funky Lift' && e.isCustom), isTrue);
  });
}
```

- [ ] **Step 2: Run the test and confirm it passes**

Run: `flutter test test/db/exercises_test.dart`
Expected: both tests PASS (the DB layer already supports these — no code changes needed).

- [ ] **Step 3: Commit**

```bash
git add test/db/exercises_test.dart
git commit -m "test(db): exercise edit and custom-add"
```

---

## Task 7: Workout save with snapshots — DB test

**Files:**
- Create: `test/db/workouts_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/db/workouts_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
  });

  tearDown(() => db.close());

  test('saving a workout writes snapshot fields that survive a later rename',
      () async {
    final bench = await (db.select(db.exercises)
          ..where((t) => t.name.equals('Bench Press')))
        .getSingle();
    final squat = await (db.select(db.exercises)
          ..where((t) => t.name.equals('Back Squat')))
        .getSingle();

    final start = DateTime(2026, 4, 11, 10, 0);
    final finish = DateTime(2026, 4, 11, 10, 30);
    final workoutId = await db.into(db.workouts).insert(
          WorkoutsCompanion.insert(
            startedAt: start,
            finishedAt: finish,
          ),
        );

    await db.batch((b) {
      b.insertAll(db.workoutExercises, [
        WorkoutExercisesCompanion.insert(
          workoutId: workoutId,
          exerciseId: Value(bench.id),
          position: 1,
          nameSnapshot: bench.name,
          setsSnapshot: bench.defaultSets,
          repsSnapshot: bench.defaultReps,
          wasCompleted: const Value(true),
        ),
        WorkoutExercisesCompanion.insert(
          workoutId: workoutId,
          exerciseId: Value(squat.id),
          position: 2,
          nameSnapshot: squat.name,
          setsSnapshot: squat.defaultSets,
          repsSnapshot: squat.defaultReps,
          wasCompleted: const Value(false),
        ),
      ]);
    });

    // Rename Bench Press AFTER the workout is saved.
    await (db.update(db.exercises)..where((t) => t.id.equals(bench.id))).write(
      const ExercisesCompanion(name: Value('Flat Bench')),
    );

    final rows = await (db.select(db.workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    expect(rows.length, 2);
    expect(rows[0].nameSnapshot, 'Bench Press'); // preserved
    expect(rows[0].wasCompleted, isTrue);
    expect(rows[1].nameSnapshot, 'Back Squat');
    expect(rows[1].wasCompleted, isFalse);
  });
}
```

- [ ] **Step 2: Run the test and confirm it passes**

Run: `flutter test test/db/workouts_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add test/db/workouts_test.dart
git commit -m "test(db): workout save preserves snapshot fields"
```

---

## Task 8: History ordering — DB test + helper query

**Files:**
- Modify: `lib/core/db/database.dart`
- Create: `test/db/history_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/db/history_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
  });

  tearDown(() => db.close());

  test('watchRecentWorkouts returns newest first', () async {
    await db.into(db.workouts).insert(WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 4, 9, 9, 0),
          finishedAt: DateTime(2026, 4, 9, 9, 30),
        ));
    await db.into(db.workouts).insert(WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 4, 11, 9, 0),
          finishedAt: DateTime(2026, 4, 11, 9, 30),
        ));
    await db.into(db.workouts).insert(WorkoutsCompanion.insert(
          startedAt: DateTime(2026, 4, 10, 9, 0),
          finishedAt: DateTime(2026, 4, 10, 9, 30),
        ));

    final list = await db.watchRecentWorkouts().first;
    expect(list.map((w) => w.startedAt.day), [11, 10, 9]);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/db/history_test.dart`
Expected: FAIL — `watchRecentWorkouts` not defined.

- [ ] **Step 3: Add the helper to `AppDatabase`**

Modify `lib/core/db/database.dart` — add the method inside the `AppDatabase` class (just after `schemaVersion`):

```dart
  Stream<List<Workout>> watchRecentWorkouts() {
    return (select(workouts)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  Stream<List<WorkoutExercise>> watchExercisesForWorkout(int workoutId) {
    return (select(workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }
```

- [ ] **Step 4: Regenerate and run tests**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/db/history_test.dart`
Expected: test PASSES.

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/database.dart test/db/history_test.dart
git commit -m "feat(db): add watchRecentWorkouts and watchExercisesForWorkout"
```

---

## Task 9: WorkoutSession model

**Files:**
- Create: `lib/models/workout_session.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/models/workout_session.dart`:

```dart
import 'package:lift_off/core/db/database.dart';

/// A single exercise entry in an in-progress workout.
class SessionExercise {
  final int exerciseId;
  final String name;
  final String iconName;
  final int sets;
  final String reps;
  final bool isCompleted;

  const SessionExercise({
    required this.exerciseId,
    required this.name,
    required this.iconName,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });

  SessionExercise copyWith({bool? isCompleted}) => SessionExercise(
        exerciseId: exerciseId,
        name: name,
        iconName: iconName,
        sets: sets,
        reps: reps,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  factory SessionExercise.fromExercise(Exercise e) => SessionExercise(
        exerciseId: e.id,
        name: e.name,
        iconName: e.iconName,
        sets: e.defaultSets,
        reps: e.defaultReps,
      );
}

/// In-progress workout state held in memory from Start → Finish.
class WorkoutSession {
  final DateTime startedAt;
  final List<SessionExercise> exercises;

  const WorkoutSession({required this.startedAt, required this.exercises});

  bool get allDone =>
      exercises.isNotEmpty && exercises.every((e) => e.isCompleted);

  WorkoutSession toggleAt(int index) {
    final next = List<SessionExercise>.from(exercises);
    next[index] = next[index].copyWith(isCompleted: !next[index].isCompleted);
    return WorkoutSession(startedAt: startedAt, exercises: next);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/models/workout_session.dart
git commit -m "feat(model): add WorkoutSession and SessionExercise"
```

---

## Task 10: Core provider — databaseProvider

**Files:**
- Create: `lib/core/providers.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/core/providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/database.dart';

/// Singleton database. Overridden in `main()` with an instance that has
/// already had `seedIfEmpty` run on it.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/providers.dart
git commit -m "feat(core): add databaseProvider placeholder"
```

---

## Task 11: SelectionNotifier + tests

**Files:**
- Create: `lib/features/library/library_providers.dart`
- Create: `test/providers/selection_notifier_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/providers/selection_notifier_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/features/library/library_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('toggle adds when absent', () {
    container.read(selectionProvider.notifier).toggle(1);
    expect(container.read(selectionProvider), [1]);
  });

  test('toggle removes when present', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(1);
    notifier.toggle(2);
    notifier.toggle(1);
    expect(container.read(selectionProvider), [2]);
  });

  test('toggle preserves pick order', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(3);
    notifier.toggle(1);
    notifier.toggle(2);
    expect(container.read(selectionProvider), [3, 1, 2]);
  });

  test('reorder moves an item', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(1);
    notifier.toggle(2);
    notifier.toggle(3);
    notifier.reorder(0, 2);
    expect(container.read(selectionProvider), [2, 1, 3]);
  });

  test('clear empties the selection', () {
    final notifier = container.read(selectionProvider.notifier);
    notifier.toggle(1);
    notifier.toggle(2);
    notifier.clear();
    expect(container.read(selectionProvider), isEmpty);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/providers/selection_notifier_test.dart`
Expected: FAIL — `selectionProvider` not defined.

- [ ] **Step 3: Implement the provider**

Create `lib/features/library/library_providers.dart`:

```dart
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
```

- [ ] **Step 4: Run the tests again**

Run: `flutter test test/providers/selection_notifier_test.dart`
Expected: all 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/library/library_providers.dart test/providers/selection_notifier_test.dart
git commit -m "feat(library): selection and exercises providers + tests"
```

---

## Task 12: WorkoutNotifier + tests

**Files:**
- Create: `lib/features/workout/workout_providers.dart`
- Create: `test/providers/workout_notifier_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/providers/workout_notifier_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/models/workout_session.dart';

SessionExercise _ex(int id, String name) => SessionExercise(
      exerciseId: id,
      name: name,
      iconName: 'fitness_center',
      sets: 3,
      reps: '8',
    );

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('start creates a session with all rows uncompleted', () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench'), _ex(2, 'Squat')]);

    final session = container.read(currentWorkoutProvider)!;
    expect(session.exercises.length, 2);
    expect(session.exercises.every((e) => !e.isCompleted), isTrue);
    expect(session.allDone, isFalse);
  });

  test('toggle flips a row and updates allDone when everything is complete',
      () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench'), _ex(2, 'Squat')]);

    notifier.toggleAt(0);
    expect(container.read(currentWorkoutProvider)!.exercises[0].isCompleted,
        isTrue);
    expect(container.read(currentWorkoutProvider)!.allDone, isFalse);

    notifier.toggleAt(1);
    expect(container.read(currentWorkoutProvider)!.allDone, isTrue);

    notifier.toggleAt(0);
    expect(container.read(currentWorkoutProvider)!.allDone, isFalse);
  });

  test('discard clears the session', () {
    final notifier = container.read(currentWorkoutProvider.notifier);
    notifier.start([_ex(1, 'Bench')]);
    notifier.discard();
    expect(container.read(currentWorkoutProvider), isNull);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/providers/workout_notifier_test.dart`
Expected: FAIL — `currentWorkoutProvider` not defined.

- [ ] **Step 3: Implement the provider**

Create `lib/features/workout/workout_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/models/workout_session.dart';

final currentWorkoutProvider =
    NotifierProvider<WorkoutNotifier, WorkoutSession?>(WorkoutNotifier.new);

class WorkoutNotifier extends Notifier<WorkoutSession?> {
  @override
  WorkoutSession? build() => null;

  void start(List<SessionExercise> exercises) {
    state = WorkoutSession(
      startedAt: DateTime.now(),
      exercises: List<SessionExercise>.unmodifiable(exercises),
    );
  }

  void toggleAt(int index) {
    final current = state;
    if (current == null) return;
    state = current.toggleAt(index);
  }

  void discard() => state = null;
}
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/providers/workout_notifier_test.dart`
Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/workout_providers.dart test/providers/workout_notifier_test.dart
git commit -m "feat(workout): currentWorkoutProvider + tests"
```

---

## Task 13: History provider

**Files:**
- Create: `lib/features/history/history_providers.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/history/history_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/providers.dart';

/// Streams recent workouts, newest first.
final historyProvider = StreamProvider<List<Workout>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentWorkouts();
});

/// Streams the exercises (with snapshots + completion) for a single workout.
final workoutExercisesProvider =
    StreamProvider.family<List<WorkoutExercise>, int>((ref, workoutId) {
  final db = ref.watch(databaseProvider);
  return db.watchExercisesForWorkout(workoutId);
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/history/history_providers.dart
git commit -m "feat(history): historyProvider and workoutExercisesProvider"
```

---

## Task 14: App theme

**Files:**
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4ADE80),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0B0F),
      cardTheme: CardThemeData(
        color: const Color(0xFF16161D),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat(theme): dark theme with accent green"
```

---

## Task 15: Icon lookup helper

**Files:**
- Create: `lib/core/icons.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/core/icons.dart`:

```dart
import 'package:flutter/material.dart';

/// Maps the handful of icon names we use in the seed data and custom-add sheet
/// to actual `IconData` values. Keeping this tiny keeps our app tree-shakable.
const Map<String, IconData> kIconChoices = {
  'fitness_center': Icons.fitness_center,
  'accessibility_new': Icons.accessibility_new,
  'timer': Icons.timer_outlined,
  'directions_walk': Icons.directions_walk,
  'sports_gymnastics': Icons.sports_gymnastics,
  'star': Icons.star,
  'bolt': Icons.bolt,
  'self_improvement': Icons.self_improvement,
};

IconData iconFor(String name) =>
    kIconChoices[name] ?? Icons.fitness_center;
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/icons.dart
git commit -m "feat(core): icon lookup helper"
```

---

## Task 16: ExerciseCard widget

**Files:**
- Create: `lib/features/library/widgets/exercise_card.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/library/widgets/exercise_card.dart`:

```dart
import 'package:flutter/material.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';

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
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.12)
              : const Color(0xFF16161D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.08),
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/library/widgets/exercise_card.dart
git commit -m "feat(library): ExerciseCard widget"
```

---

## Task 17: EditDefaultsSheet widget

**Files:**
- Create: `lib/features/library/widgets/edit_defaults_sheet.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/library/widgets/edit_defaults_sheet.dart`:

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/library/widgets/edit_defaults_sheet.dart
git commit -m "feat(library): edit defaults bottom sheet"
```

---

## Task 18: AddExerciseSheet widget

**Files:**
- Create: `lib/features/library/widgets/add_exercise_sheet.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/library/widgets/add_exercise_sheet.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';
import 'package:lift_off/core/providers.dart';

class AddExerciseSheet extends ConsumerStatefulWidget {
  const AddExerciseSheet({super.key});

  @override
  ConsumerState<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends ConsumerState<AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '10');
  String _iconName = 'fitness_center';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final sets = int.tryParse(_setsCtrl.text.trim());
    final reps = _repsCtrl.text.trim();
    if (name.isEmpty || sets == null || sets <= 0 || reps.isEmpty) return;

    final db = ref.read(databaseProvider);
    await db.into(db.exercises).insert(ExercisesCompanion.insert(
          name: name,
          iconName: _iconName,
          defaultSets: sets,
          defaultReps: reps,
          isCustom: const Value(true),
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
          Text('New exercise',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _setsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sets'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repsCtrl,
            decoration: const InputDecoration(labelText: 'Reps'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final entry in kIconChoices.entries)
                GestureDetector(
                  onTap: () => setState(() => _iconName = entry.key),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _iconName == entry.key
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white24,
                        width: _iconName == entry.key ? 2 : 1,
                      ),
                    ),
                    child: Icon(entry.value),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Add')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/library/widgets/add_exercise_sheet.dart
git commit -m "feat(library): add-exercise bottom sheet"
```

---

## Task 19: LibraryScreen

**Files:**
- Create: `lib/features/library/library_screen.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/library/library_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
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
        title: const Text('Lift Off'),
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/library/library_screen.dart
git commit -m "feat(library): LibraryScreen — card grid + start button"
```

---

## Task 20: ReviewScreen

**Files:**
- Create: `lib/features/review/review_screen.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/review/review_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';
import 'package:lift_off/features/library/library_providers.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/features/workout/workout_screen.dart';
import 'package:lift_off/models/workout_session.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
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
              return Card(
                key: ValueKey(ex.id),
                child: ListTile(
                  leading: Icon(iconFor(ex.iconName)),
                  title: Text(ex.name),
                  subtitle: Text('${ex.defaultSets} × ${ex.defaultReps}'),
                  trailing: const Icon(Icons.drag_handle),
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/review/review_screen.dart
git commit -m "feat(review): ReviewScreen with drag-to-reorder"
```

---

## Task 21: WorkoutScreen

**Files:**
- Create: `lib/features/workout/workout_screen.dart`

- [ ] **Step 1: Create the file**

Full contents of `lib/features/workout/workout_screen.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/icons.dart';
import 'package:lift_off/core/providers.dart';
import 'package:lift_off/features/library/library_providers.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/models/workout_session.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentWorkoutProvider);
    if (session == null) {
      // Defensive: if the session is gone, go back to the library.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard workout?'),
            content: const Text('Your current workout will be lost.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Discard')),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          ref.read(currentWorkoutProvider.notifier).discard();
          ref.read(selectionProvider.notifier).clear();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          itemCount: session.exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final ex = session.exercises[i];
            return Card(
              child: ListTile(
                key: Key('workout-row-$i'),
                onTap: () =>
                    ref.read(currentWorkoutProvider.notifier).toggleAt(i),
                leading: Icon(iconFor(ex.iconName),
                    color: ex.isCompleted ? Colors.white38 : null),
                title: Text(
                  ex.name,
                  style: TextStyle(
                    decoration:
                        ex.isCompleted ? TextDecoration.lineThrough : null,
                    color: ex.isCompleted ? Colors.white38 : null,
                  ),
                ),
                subtitle: Text(
                  '${ex.sets} × ${ex.reps}',
                  style: TextStyle(
                    color: ex.isCompleted ? Colors.white24 : null,
                  ),
                ),
                trailing: ex.isCompleted
                    ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                    : const Icon(Icons.radio_button_unchecked),
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              key: const Key('finish-button'),
              style: session.allDone
                  ? null
                  : FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
              onPressed: () => _finish(context, ref, session),
              child: Text(session.allDone ? 'Finish' : 'Finish early'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish(
      BuildContext context, WidgetRef ref, WorkoutSession session) async {
    final db = ref.read(databaseProvider);
    try {
      await db.transaction(() async {
        final workoutId = await db.into(db.workouts).insert(
              WorkoutsCompanion.insert(
                startedAt: session.startedAt,
                finishedAt: DateTime.now(),
              ),
            );
        await db.batch((b) {
          b.insertAll(
            db.workoutExercises,
            [
              for (var i = 0; i < session.exercises.length; i++)
                WorkoutExercisesCompanion.insert(
                  workoutId: workoutId,
                  exerciseId: Value(session.exercises[i].exerciseId),
                  position: i + 1,
                  nameSnapshot: session.exercises[i].name,
                  setsSnapshot: session.exercises[i].sets,
                  repsSnapshot: session.exercises[i].reps,
                  wasCompleted: Value(session.exercises[i].isCompleted),
                ),
            ],
          );
        });
      });
      ref.read(currentWorkoutProvider.notifier).discard();
      ref.read(selectionProvider.notifier).clear();
      if (context.mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save workout')),
        );
      }
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/workout/workout_screen.dart
git commit -m "feat(workout): WorkoutScreen with finish + snapshot save"
```

---

## Task 22: HistoryScreen and WorkoutTile

**Files:**
- Create: `lib/features/history/history_screen.dart`
- Create: `lib/features/history/widgets/workout_tile.dart`

- [ ] **Step 1: Create the tile widget**

Create `lib/features/history/widgets/workout_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/features/history/history_providers.dart';

class WorkoutTile extends ConsumerWidget {
  final Workout workout;
  const WorkoutTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(workoutExercisesProvider(workout.id));
    final dateStr = _formatDate(workout.startedAt);
    return Card(
      child: ExpansionTile(
        title: Text(dateStr),
        subtitle: exercisesAsync.when(
          data: (rows) => Text('${rows.length} exercises'),
          loading: () => const Text('…'),
          error: (_, __) => const Text('—'),
        ),
        children: [
          exercisesAsync.when(
            data: (rows) => Column(
              children: [
                for (final r in rows)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      r.wasCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: r.wasCompleted ? Colors.greenAccent : null,
                    ),
                    title: Text(r.nameSnapshot),
                    subtitle: Text('${r.setsSnapshot} × ${r.repsSnapshot}'),
                  ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
```

- [ ] **Step 2: Create the history screen**

Create `lib/features/history/history_screen.dart`:

```dart
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
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/history/
git commit -m "feat(history): HistoryScreen and WorkoutTile"
```

---

## Task 23: App root + main

**Files:**
- Create: `lib/app.dart`
- Modify: `lib/main.dart` (replace entirely)

- [ ] **Step 1: Create `lib/app.dart`**

```dart
import 'package:flutter/material.dart';

import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/features/library/library_screen.dart';

class LiftOffApp extends StatelessWidget {
  const LiftOffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lift Off',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const LibraryScreen(),
    );
  }
}
```

- [ ] **Step 2: Replace `lib/main.dart` entirely**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/app.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';
import 'package:lift_off/core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await seedIfEmpty(db);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const LiftOffApp(),
    ),
  );
}
```

- [ ] **Step 3: Run `flutter analyze` to catch any import issues**

Run: `flutter analyze`
Expected: `No issues found!` (or only info-level lints).

- [ ] **Step 4: Commit**

```bash
git add lib/app.dart lib/main.dart
git commit -m "feat(app): wire main, ProviderScope, and MaterialApp"
```

---

## Task 24: LibraryScreen widget test — tap card toggles selection

**Files:**
- Create: `test/widgets/library_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/library_screen_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/db/seed.dart';
import 'package:lift_off/core/providers.dart';
import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/features/library/library_screen.dart';

void main() {
  testWidgets('tapping a card selects it and updates the start button count',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const LibraryScreen(),
        ),
      ),
    );

    // Let the exercises stream resolve.
    await tester.pumpAndSettle();

    expect(find.text('Start (0 selected)'), findsOneWidget);

    // Find the first card by the predictable key pattern.
    final card = find
        .byWidgetPredicate((w) =>
            w.key is ValueKey &&
            (w.key as ValueKey).value is String &&
            ((w.key as ValueKey).value as String).startsWith('exercise-card-'))
        .first;

    await tester.tap(card);
    await tester.pump();

    expect(find.text('Start (1 selected)'), findsOneWidget);
    // Checkmark icon should now appear inside the tapped card.
    expect(find.byIcon(Icons.check_circle), findsWidgets);
  });
}
```

- [ ] **Step 2: Run the test**

Run: `flutter test test/widgets/library_screen_test.dart`
Expected: PASS. If it fails due to scroll-lazy rendering, the first card should still be in view since the grid starts at the top.

- [ ] **Step 3: Commit**

```bash
git add test/widgets/library_screen_test.dart
git commit -m "test(library): tap card toggles selection + updates start button"
```

---

## Task 25: WorkoutScreen widget test — tap row, undo, all-done finishes

**Files:**
- Create: `test/widgets/workout_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/workout_screen_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/providers.dart';
import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/features/workout/workout_providers.dart';
import 'package:lift_off/features/workout/workout_screen.dart';
import 'package:lift_off/models/workout_session.dart';

SessionExercise _ex(int id, String name) => SessionExercise(
      exerciseId: id,
      name: name,
      iconName: 'fitness_center',
      sets: 3,
      reps: '8',
    );

void main() {
  testWidgets('tapping a row strikes it through; tap again undoes',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    container
        .read(currentWorkoutProvider.notifier)
        .start([_ex(1, 'Bench Press'), _ex(2, 'Back Squat')]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const WorkoutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially: Finish early
    expect(find.text('Finish early'), findsOneWidget);

    // Tap first row.
    await tester.tap(find.byKey(const Key('workout-row-0')));
    await tester.pump();
    expect(container.read(currentWorkoutProvider)!.exercises[0].isCompleted,
        isTrue);

    // Tap again — undo.
    await tester.tap(find.byKey(const Key('workout-row-0')));
    await tester.pump();
    expect(container.read(currentWorkoutProvider)!.exercises[0].isCompleted,
        isFalse);

    // Complete all rows → button becomes "Finish".
    await tester.tap(find.byKey(const Key('workout-row-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('workout-row-1')));
    await tester.pump();
    expect(find.text('Finish'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test**

Run: `flutter test test/widgets/workout_screen_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add test/widgets/workout_screen_test.dart
git commit -m "test(workout): tap row toggles, all-done shows Finish"
```

---

## Task 26: Run the full test suite + analyzer

**Files:** none (verification)

- [ ] **Step 1: Run the full suite**

Run: `flutter test`
Expected: all tests PASS — DB (4 files), providers (2 files), widgets (2 files).

- [ ] **Step 2: Run the analyzer**

Run: `flutter analyze`
Expected: `No issues found!` (info-level lints acceptable, errors are not).

- [ ] **Step 3: Commit a clean-up if anything was adjusted**

If any of the earlier steps needed tweaks during this cleanup, commit them now:
```bash
git add -A
git commit -m "chore: cleanup + fix lints"
```

If nothing changed, skip the commit.

---

## Task 27: Run on iOS simulator — manual smoke test

**Files:** none (manual verification)

- [ ] **Step 1: Make sure the iOS simulator is up**

Run: `open -a Simulator`
Expected: Simulator app launches. If no device boots, open the Simulator menu → File → Open Simulator → iPhone 17.

- [ ] **Step 2: Run the app**

Run: `flutter run -d ios`
Expected: app builds, installs, and launches. First run takes a minute or two (pod install runs).

- [ ] **Step 3: Smoke test the happy path**

Manually verify:
1. Library screen shows the 25 seeded cards in a 3-column grid.
2. Tap 3 cards — they get the accent border and check icon. Bottom button says "Start (3 selected)".
3. Long-press a card — edit sheet appears. Change sets to 5, reps to `5`. Save. Card now reads "5 × 5".
4. Tap `+` FAB — add-exercise sheet appears. Enter a custom name, save. Card appears in the grid.
5. Tap Start → Review screen. Drag an item to a new position.
6. Tap Start Workout → Workout screen. Tap each row to mark done. Finish button becomes primary. Tap Finish → back to Library, selection empty.
7. Tap history icon → the workout appears at the top with correct date and count. Expand → see the exercises and completion checks.

- [ ] **Step 4: Quit the app**

Back in the terminal running `flutter run`, press `q` to quit.

---

## Task 28: Run on Android emulator — manual smoke test

**Files:** none (manual verification)

- [ ] **Step 1: Launch the Android emulator**

Run: `flutter emulators --launch Pixel_8`
Expected: Pixel 8 emulator boots (takes ~30 seconds on first launch).

- [ ] **Step 2: Run the app**

Run: `flutter run -d android`
Expected: builds (Gradle may take a minute on first run), installs, launches.

- [ ] **Step 3: Repeat the smoke test from Task 27 Step 3.**

- [ ] **Step 4: Quit with `q`.**

- [ ] **Step 5: Tag v0.1**

```bash
git tag v0.1-mvp -m "Lift Off v0.1 — card selection, workout, and history on iOS + Android"
```

---

## Verification Summary

After all tasks are complete:

- `flutter test` — all tests pass (4 DB test files, 2 provider test files, 2 widget test files)
- `flutter analyze` — no errors
- App runs and completes the happy-path smoke test on both iOS and Android simulators
- Git log shows one commit per task with conventional messages
- `docs/superpowers/specs/2026-04-11-lift-off-workout-app-design.md` is the spec of record and matches the behavior of the built app

## Self-Review (done — fixes applied inline)

1. **Spec coverage** — every spec section has a task:
   - Library screen → Task 19
   - Review screen → Task 20
   - Workout screen → Task 21
   - History screen → Task 22
   - Data model (all 4 tables) → Task 3
   - `default_reps` as TEXT → Task 3 (column type) + Task 5 (seed values include `max`, `60s`, `40s`)
   - `reps_snapshot` as TEXT → Task 3
   - Snapshot preservation test → Task 7
   - Reverse-chronological history → Task 8
   - Seeding idempotency → Task 5
   - Discard dialog → Task 21
   - DB error SnackBar → Task 21
   - Riverpod providers (database, exercises, selection, currentWorkout, history) → Tasks 10, 11, 12, 13
   - Theme → Task 14
   - Tests explicitly called out in the spec → Tasks 5, 6, 7, 8, 11, 12, 24, 25

2. **Placeholder scan** — no TBD/TODO/"similar to Task N"/missing code blocks.

3. **Type/name consistency** — `seedIfEmpty`, `databaseProvider`, `exercisesProvider`, `selectionProvider`, `currentWorkoutProvider`, `historyProvider`, `workoutExercisesProvider`, `SessionExercise`, `WorkoutSession`, `toggle`/`toggleAt`/`reorder`/`clear`/`start`/`discard` all match between definition and use.

4. **Scope check** — v1 is a single cohesive feature: pick cards → run workout → save history. Not split further.
