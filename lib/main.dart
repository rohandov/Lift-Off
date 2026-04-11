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
