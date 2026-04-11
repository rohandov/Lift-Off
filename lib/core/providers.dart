import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/database.dart';

/// Singleton database. Overridden in `main()` with an instance that has
/// already had `seedIfEmpty` run on it.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});
