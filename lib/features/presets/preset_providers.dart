import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lift_off/core/db/database.dart';
import 'package:lift_off/core/providers.dart';

final presetsProvider = StreamProvider<List<Preset>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPresets();
});
