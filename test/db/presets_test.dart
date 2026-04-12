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

  test('savePreset and getPresetExerciseIds round-trip', () async {
    final exercises = await db.select(db.exercises).get();
    final ids = [exercises[2].id, exercises[0].id, exercises[1].id];

    await db.savePreset('My Preset', ids);

    final presets = await db.select(db.presets).get();
    expect(presets, hasLength(1));
    expect(presets.first.name, 'My Preset');

    final result = await db.getPresetExerciseIds(presets.first.id);
    expect(result, ids);
  });

  test('deletePreset removes preset and its exercises', () async {
    final exercises = await db.select(db.exercises).get();
    await db.savePreset('To Delete', [exercises[0].id, exercises[1].id]);

    final presets = await db.select(db.presets).get();
    expect(presets, hasLength(1));

    await db.deletePreset(presets.first.id);

    final after = await db.select(db.presets).get();
    expect(after, isEmpty);

    final links = await db.select(db.presetExercises).get();
    expect(links, isEmpty);
  });

  test('cascade: deleting exercise removes it from preset', () async {
    final exercises = await db.select(db.exercises).get();
    final ids = [exercises[0].id, exercises[1].id, exercises[2].id];

    await db.savePreset('Cascade Test', ids);

    // Delete the middle exercise
    await (db.delete(db.exercises)
          ..where((t) => t.id.equals(exercises[1].id)))
        .go();

    final presets = await db.select(db.presets).get();
    expect(presets, hasLength(1));

    final remaining = await db.getPresetExerciseIds(presets.first.id);
    expect(remaining, [exercises[0].id, exercises[2].id]);
  });

  test('watchPresets emits updates', () async {
    final stream = db.watchPresets();

    final first = await stream.first;
    expect(first, isEmpty);

    final exercises = await db.select(db.exercises).get();
    await db.savePreset('Watched', [exercises[0].id]);

    final second = await stream.first;
    expect(second, hasLength(1));
    expect(second.first.name, 'Watched');
  });
}
