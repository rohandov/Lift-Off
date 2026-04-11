# Lift Off — Workout App Design

**Date:** 2026-04-11
**Status:** Approved for implementation planning
**Project:** `lift_off` (Flutter, iOS + Android)

## Context

A speed-first, card-based workout app. The core differentiator versus Strong/Hevy/Jefit is **minimum taps between opening the app and starting a workout**. Users pick exercise cards from a grid, optionally reorder them, then follow a simple checklist while training. Shipping target: public release (App Store + Play Store), so the app must be polished enough for general users, but not feature-rich.

v1 focuses on the core pick-and-follow loop with local history. Rep counters and smarter features come later — the design leaves room for them without building them now.

## Product Requirements

- **Platforms:** iOS + Android, from a single Flutter codebase. No backend.
- **Onboarding:** None. App opens directly to the card grid.
- **Library:** ~25 curated exercises seeded on first launch; users can add custom ones.
- **Card contents:** Name, icon, default sets and reps (editable, edits persist to the library).
- **Selection UX:** Full grid on one screen, tap to toggle. Accent border + checkmark for selected cards.
- **Sequence building:** Order = pick order, with optional drag-to-reorder on a review screen.
- **Follow-workout UX:** Simple list; tap a row to cross it out; tap again to undo; Finish button when all are done.
- **Persistence:** Full workout history (every completed workout is logged locally).
- **Non-goals for v1:** Rep counters, rest timers, progress charts, custom icon uploads, cloud sync, accounts, sharing.

## Technical Approach

- **Framework:** Flutter (stable channel)
- **State management:** Riverpod
- **Local storage:** Drift (type-safe SQLite wrapper) — chosen over Hive because relational queries for history filtering will matter as history grows
- **Icons:** Material Icons (built in, no extra dependency)
- **Testing:** `flutter_test` for unit + widget tests; Drift in-memory for DB tests

## Screens & Navigation

Flat navigation stack rooted at the Library screen. No bottom nav, no drawer.

### 1. Library Screen (root)

- 3-column grid of all exercises (curated + user-added), scrollable.
- Each card: icon, name, default "NxR" sets/reps text.
- Tap a card → toggle selection (accent border + checkmark).
- Long-press a card → slide-up sheet to edit that exercise's default sets and reps. Save writes directly to the `exercises` table.
- Floating `+` action button → slide-up sheet to add a custom exercise (name + sets + reps + icon picker).
- Bottom bar: primary button "Start (N selected)" (disabled when N=0) and a History icon button.
- Tapping Start → push ReviewScreen.
- Tapping History icon → push HistoryScreen.

### 2. Review Screen

- Vertical list of selected exercises in pick order.
- Each row: icon, name, sets/reps, drag handle on the right.
- `ReorderableListView` — long-press and drag to reorder.
- Bottom: primary button "Start Workout".
- Back arrow returns to Library (selection preserved).

### 3. Workout Screen

- Vertical list of the selected exercises in their final order.
- Each row shows icon, name, sets/reps.
- Tap a row → strikethrough + greyed out (`was_completed = true` in the in-memory session). Tap again → undo.
- When all rows are marked complete, the bottom "Finish" button becomes primary/highlighted.
- Tap Finish → write workout + workout_exercises rows to Drift with snapshot fields; `Navigator.popUntil` back to Library; clear `selectionProvider`.
- Back button during workout → confirmation dialog: "Discard workout?" Yes → pop to root, no save. No → stay.

### 4. History Screen

- Pushed from the Library screen.
- Reverse-chronological list of past workouts.
- Each collapsed row: date/time and a count ("6 exercises").
- Tap to expand inline: shows the exercise list with completion checkmarks, using the snapshot fields (not live join to `exercises`).
- No editing, no deletion in v1.

## Data Model (Drift)

### `exercises`

| Column | Type | Notes |
|---|---|---|
| `id` | INT PK autoincrement | |
| `name` | TEXT | e.g. "Bench Press" |
| `icon_name` | TEXT | Material Icons identifier, e.g. `fitness_center` |
| `default_sets` | INT | |
| `default_reps` | TEXT | Free-form string: `"8"`, `"max"`, `"60s"`, `"40s"`. Rendered as-is to the user. Not parsed in v1. |
| `is_custom` | BOOL | `false` for seed exercises, `true` for user-added |
| `created_at` | DATETIME | |

### `workouts`

| Column | Type | Notes |
|---|---|---|
| `id` | INT PK autoincrement | |
| `started_at` | DATETIME | Set when user taps Start Workout |
| `finished_at` | DATETIME | Set when user taps Finish. In v1, workouts are only written on Finish, so this is never null. |

### `workout_exercises`

| Column | Type | Notes |
|---|---|---|
| `id` | INT PK autoincrement | |
| `workout_id` | INT FK → `workouts.id` (CASCADE on delete) | |
| `exercise_id` | INT FK → `exercises.id` (SET NULL on delete) | Nullable to preserve history if the source exercise is later deleted |
| `position` | INT | 1-indexed order in the workout |
| `name_snapshot` | TEXT | Copied from the exercise at save time |
| `sets_snapshot` | INT | |
| `reps_snapshot` | TEXT | Same format as `default_reps` |
| `was_completed` | BOOL | Whether the row was crossed out at Finish |

### `settings`

Reserved, empty in v1. Included so schemaVersion 1 already has the table when future key/value preferences arrive.

### Why snapshot fields

If a user renames or deletes an exercise later, their historical workouts still read correctly — history is immutable. This is a deliberate one-time write cost at Finish in exchange for query simplicity forever after.

## Folder Structure

```
lib/
├── main.dart                      # ProviderScope + runApp
├── app.dart                       # MaterialApp, theme, routing
│
├── core/
│   ├── db/
│   │   ├── database.dart          # Drift Database class (@DriftDatabase target)
│   │   ├── tables.dart            # Table definitions
│   │   ├── seed.dart              # Idempotent seed of the ~25 curated exercises
│   │   └── database.g.dart        # Generated by drift_dev
│   ├── theme/
│   │   └── app_theme.dart         # Colors, typography, card styles
│   └── providers.dart             # databaseProvider (top-level singleton)
│
├── features/
│   ├── library/
│   │   ├── library_screen.dart
│   │   ├── library_providers.dart     # exercisesProvider, selectionProvider
│   │   └── widgets/
│   │       ├── exercise_card.dart
│   │       ├── edit_defaults_sheet.dart
│   │       └── add_exercise_sheet.dart
│   ├── review/
│   │   └── review_screen.dart
│   ├── workout/
│   │   ├── workout_screen.dart
│   │   └── workout_providers.dart     # currentWorkoutProvider
│   └── history/
│       ├── history_screen.dart
│       ├── history_providers.dart     # historyProvider
│       └── widgets/
│           └── workout_tile.dart
│
└── models/
    └── workout_session.dart           # In-memory "current workout" value type
```

### Riverpod providers

- **`databaseProvider`** — `Provider<AppDatabase>`, singleton Drift instance.
- **`exercisesProvider`** — `StreamProvider<List<Exercise>>`, streams the full library.
- **`selectionProvider`** — `NotifierProvider<SelectionNotifier, List<int>>`, the ordered list of selected exercise IDs. Lives across Library → Review → Workout, cleared on finish or discard.
- **`currentWorkoutProvider`** — `NotifierProvider<WorkoutNotifier, WorkoutSession?>`, the in-progress session (exercises + per-row completion flags). Created when Start Workout is tapped; disposed on finish/discard.
- **`historyProvider`** — `StreamProvider<List<WorkoutWithExercises>>`, reverse-chronological.

## Seed Exercise Library

All use Material Icons. Default sets/reps listed in parentheses.

**Push:** Bench Press (3×8), Overhead Press (3×8), Incline DB Press (3×10), Dips (3×10), Tricep Pushdown (3×12), Lateral Raise (3×15)

**Pull:** Deadlift (3×5), Barbell Row (3×8), Pull-Up (3×max), Lat Pulldown (3×10), Seated Cable Row (3×10), Face Pull (3×15), Bicep Curl (3×12)

**Legs:** Back Squat (3×8), Front Squat (3×8), Romanian Deadlift (3×10), Leg Press (3×10), Walking Lunge (3×10), Leg Curl (3×12), Calf Raise (3×15)

**Core/Other:** Plank (3×60s), Hanging Leg Raise (3×10), Ab Wheel (3×10), Farmer Carry (3×40s), Kettlebell Swing (3×15)

Total: 25 exercises. Seed is idempotent — runs only when the `exercises` table is empty on app launch.

## End-to-End Flow (Happy Path)

1. Open app → LibraryScreen. Grid of 25 cards, none selected.
2. Tap 5 cards → each shows accent + ✓. Bottom: "Start (5 selected)".
3. Long-press Bench Press → edit sheet. Change to 5×5. Save. Card now reads 5×5. `exercises.default_sets/reps` updated.
4. Tap Start → ReviewScreen with the 5 cards in pick order.
5. Drag Deadlift to position 1. Tap Start Workout → WorkoutScreen.
6. `currentWorkoutProvider` is created with the 5 exercises, all `was_completed=false`.
7. User taps Deadlift row → greyed and struck. Repeats for the other 4.
8. Finish button becomes primary. Tap → write `workouts` row and 5 `workout_exercises` rows with snapshots and `was_completed`. Pop to LibraryScreen. Clear selection.
9. Open History → new workout at the top, expandable.

## Unhappy Paths

- **Back during workout** → confirmation dialog, "Discard workout?" Yes discards, no save.
- **App killed mid-workout** → v1 does not persist in-progress state. Session is lost. Documented limitation; can add later via a `draft_workout` row or `SharedPreferences` snapshot.
- **DB write failure at Finish** → catch, show SnackBar ("Could not save workout"). Keep workout screen open so user can retry.
- **Schema migrations** → v1 ships with `schemaVersion = 1` and no migration code. Future versions will add `MigrationStrategy` entries as tables change.

## Testing

**Drift DB tests** (in-memory, fast):
- Seed runs exactly once across multiple launches.
- Editing an exercise's defaults persists.
- Adding a custom exercise appears in the exercises stream.
- Saving a workout writes correct snapshot fields even after the source exercise is renamed.
- `historyProvider` returns workouts in reverse chronological order.

**Provider tests:**
- `SelectionNotifier`: add, remove, reorder, clear.
- `WorkoutNotifier`: toggle completion, produce correct payload on finish.

**Widget tests:**
- **LibraryScreen**: tap card → ✓ appears, Start button count updates.
- **WorkoutScreen**: tap row → strikethrough; tap again → undo; all complete → Finish primary.

**Explicitly out of scope for v1 tests:** golden/visual tests, integration tests on simulators, history screen widget tests (rendering-only, covered indirectly by DB tests), navigation tests.

Run: `flutter test`. Expected runtime: a few seconds.

## Explicitly Deferred

These are intentionally left out of v1 and will each become their own design cycle:

- Rep counters and per-set tracking
- Rest timers
- Progress charts / stats
- Favorites / saved workout presets
- Draft workout persistence across app kills
- Custom icon or photo upload
- Cloud sync / accounts / sharing
- Exercise deletion and editing beyond sets/reps (rename, icon change)
- History editing or deletion
