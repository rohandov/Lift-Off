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

class Presets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class PresetExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get presetId =>
      integer().references(Presets, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
}
