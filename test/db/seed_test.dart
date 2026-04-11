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
