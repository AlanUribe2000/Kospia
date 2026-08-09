import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Species,
    Questions,
    QuestionOptions,
    SpeciesTraits,
    Observations,
    ObservationPhotos,
    Users,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Re-crear todas las tablas al actualizar schema
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      },
    );
  }

  // --- Species queries ---
  Future<List<Specy>> getAllSpecies() => select(species).get();

  Future<Specy?> getSpeciesById(String id) =>
      (select(species)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertSpecies(SpeciesCompanion entry) =>
      into(species).insert(entry, mode: InsertMode.insertOrReplace);

  // --- Observations queries ---
  Future<List<Observation>> getAllObservations() => (select(
    observations,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<List<Observation>> getObservationsByUser(String userId) =>
      (select(observations)..where((t) => t.userId.equals(userId))).get();

  Future<List<Observation>> getObservationsBySpecies(String speciesId) =>
      (select(observations)..where((t) => t.speciesId.equals(speciesId))).get();

  Future<List<Observation>> getPendingObservations() => (select(
    observations,
  )..where((t) => t.syncStatus.equals(AppConstants.syncPending))).get();

  Future<int> insertObservation(ObservationsCompanion entry) =>
      into(observations).insert(entry);

  Future<bool> updateObservation(ObservationsCompanion entry) =>
      update(observations).replace(entry);

  // --- ObservationPhotos queries ---
  Future<List<ObservationPhoto>> getPhotosForObservation(
    String observationId,
  ) =>
      (select(observationPhotos)
            ..where((t) => t.observationId.equals(observationId))
            ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
          .get();

  Future<List<ObservationPhoto>> getAllPhotosForSpecies(
    String speciesId,
  ) async {
    final obs = await getObservationsBySpecies(speciesId);
    if (obs.isEmpty) return [];
    final obsIds = obs.map((o) => o.id).toList();
    return (select(observationPhotos)
          ..where((t) => t.observationId.isIn(obsIds))
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
        .get();
  }

  /// Returns distinct plant parts photographed for a given species.
  Future<Set<String>> getPartsForSpecies(String speciesId) async {
    final photos = await getAllPhotosForSpecies(speciesId);
    return photos.map((p) => p.plantPart).toSet();
  }

  Future<int> insertObservationPhoto(ObservationPhotosCompanion entry) =>
      into(observationPhotos).insert(entry);

  Future<void> insertObservationPhotos(
    List<ObservationPhotosCompanion> entries,
  ) async {
    await batch((batch) {
      batch.insertAll(observationPhotos, entries);
    });
  }

  // --- Questions queries ---
  Future<List<Question>> getAllQuestions() =>
      (select(questions)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();

  Future<List<QuestionOption>> getOptionsForQuestion(String questionId) =>
      (select(questionOptions)
            ..where((t) => t.questionId.equals(questionId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();

  // --- Species Traits queries ---
  Future<List<SpeciesTrait>> getAllTraits() => select(speciesTraits).get();

  Future<List<SpeciesTrait>> getTraitsForSpecies(String speciesId) => (select(
    speciesTraits,
  )..where((t) => t.speciesId.equals(speciesId))).get();

  /// Given a set of selected option IDs, find species that match ALL of them.
  Future<List<Specy>> findSpeciesByTraits(List<String> optionIds) async {
    if (optionIds.isEmpty) return getAllSpecies();

    final query = customSelect(
      'SELECT s.* FROM species s '
      'INNER JOIN species_traits st ON s.id = st.species_id '
      'WHERE st.option_id IN (${optionIds.map((_) => '?').join(',')}) '
      'GROUP BY s.id '
      'HAVING COUNT(DISTINCT st.option_id) = ?',
      variables: [
        ...optionIds.map((id) => Variable.withString(id)),
        Variable.withInt(optionIds.length),
      ],
      readsFrom: {species, speciesTraits},
    );

    final rows = await query.get();
    return rows.map((row) {
      return Specy(
        id: row.read<String>('id'),
        commonName: row.read<String>('common_name'),
        scientificName: row.read<String>('scientific_name'),
        description: row.read<String>('description'),
        imageUrl: row.read<String>('image_url'),
        family: row.read<String>('family'),
        habitat: row.read<String>('habitat'),
        flowerColor: row.read<String>('flower_color'),
        biologicalForm: row.read<String>('biological_form'),
        approximateHeight: row.read<String>('approximate_height'),
        leafLength: row.read<String>('leaf_length'),
        leafShape: row.read<String>('leaf_shape'),
        leafEdge: row.read<String>('leaf_edge'),
        leafTexture: row.read<String>('leaf_texture'),
        hasSpines: row.read<bool>('has_spines'),
        spineType: row.read<String>('spine_type'),
        flowerGrouping: row.read<String>('flower_grouping'),
        petalCount: row.read<String>('petal_count'),
        flowerSize: row.read<String>('flower_size'),
        hasFruit: row.read<bool>('has_fruit'),
        fruitShape: row.read<String>('fruit_shape'),
        fruitColor: row.read<String>('fruit_color'),
        fruitSize: row.read<String>('fruit_size'),
        observations: row.read<String>('observations'),
        isActive: row.read<bool>('is_active'),
        syncStatus: row.read<String>('sync_status'),
        createdAt: row.read<DateTime>('created_at'),
      );
    }).toList();
  }

  // --- Users queries ---
  Future<User?> getUserById(String id) =>
      (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertUser(UsersCompanion entry) =>
      into(users).insert(entry, mode: InsertMode.insertOrReplace);

  // --- Reset database ---
  /// Borra todas las tablas y re-inserta datos semilla.
  Future<void> resetDatabase() async {
    await transaction(() async {
      await delete(observationPhotos).go();
      await delete(observations).go();
      await delete(speciesTraits).go();
      await delete(questionOptions).go();
      await delete(questions).go();
      await delete(species).go();
      await delete(users).go();
    });
  }

  // --- Seed helper ---
  Future<void> insertSeedSpecies(List<SpeciesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(species, entries, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> insertSeedQuestions(List<QuestionsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(questions, entries, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> insertSeedOptions(List<QuestionOptionsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(
        questionOptions,
        entries,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> insertSeedTraits(List<SpeciesTraitsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(speciesTraits, entries, mode: InsertMode.insertOrReplace);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
