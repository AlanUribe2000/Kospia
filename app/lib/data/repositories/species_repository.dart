import '../database/app_database.dart';
import '../seed/seed_data.dart';

/// Repositorio de especies. Maneja acceso a datos de flora.
class SpeciesRepository {
  final AppDatabase _db;

  SpeciesRepository(this._db);

  Future<List<Specy>> getAll() => _db.getAllSpecies();

  Future<Specy?> getById(String id) => _db.getSpeciesById(id);

  Future<List<Specy>> findByTraits(List<String> optionIds) =>
      _db.findSpeciesByTraits(optionIds);

  /// Seeds the database with initial species data if empty.
  Future<void> seedIfEmpty() async {
    final existing = await _db.getAllSpecies();
    if (existing.isNotEmpty) return;

    await _db.insertSeedSpecies(SeedData.speciesEntries);
    await _db.insertSeedQuestions(SeedData.questionEntries);
    await _db.insertSeedOptions(SeedData.optionEntries);
    await _db.insertSeedTraits(SeedData.traitEntries);
  }
}
