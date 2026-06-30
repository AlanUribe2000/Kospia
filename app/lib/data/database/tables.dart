import 'package:drift/drift.dart';

/// Tabla de especies de flora patagonica.
class Species extends Table {
  TextColumn get id => text()();
  TextColumn get commonName => text()();
  TextColumn get scientificName => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  TextColumn get family => text().withDefault(const Constant(''))();
  TextColumn get habitat => text().withDefault(const Constant(''))();
  TextColumn get flowerColor => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Preguntas para el flujo de identificacion.
class Questions extends Table {
  TextColumn get id => text()();
  TextColumn get questionText => text()();
  IntColumn get orderIndex => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Opciones de respuesta para cada pregunta.
class QuestionOptions extends Table {
  TextColumn get id => text()();
  TextColumn get questionId => text()();
  TextColumn get optionText => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Relacion entre especies y opciones que las identifican.
class SpeciesTraits extends Table {
  TextColumn get id => text()();
  TextColumn get speciesId => text()();
  TextColumn get questionId => text()();
  TextColumn get optionId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Observaciones: registro principal de ciencia ciudadana.
class Observations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get speciesId => text().nullable()();
  TextColumn get photoPath => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().withDefault(const Constant(0.0))();
  RealColumn get accuracy => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get capturedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Usuarios del sistema.
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().withDefault(const Constant(''))();
  IntColumn get totalObservations => integer().withDefault(const Constant(0))();
  IntColumn get speciesUnlocked => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
