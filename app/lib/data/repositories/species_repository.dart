import '../database/app_database.dart';
import '../seed/seed_data.dart';
import '../services/sequential_questionnaire.dart';
import 'package:powersync/powersync.dart';

/// Repositorio de especies. Maneja acceso a datos de flora.
class SpeciesRepository {
  final AppDatabase _drift;
  final PowerSyncDatabase _powerSync;

  SpeciesRepository(this._drift, this._powerSync);

  Future<List<Specy>> getAll() async {
    final rows = await _powerSync.getAll('''
      SELECT * FROM species
      WHERE is_active = 1
      ORDER BY common_name COLLATE NOCASE
    ''');
    if (rows.isNotEmpty) return rows.map(_speciesFromPowerSync).toList();
    return _drift.getAllSpecies();
  }

  Future<Specy?> getById(String id) async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM species WHERE id = ? LIMIT 1',
      [id],
    );
    if (rows.isNotEmpty) return _speciesFromPowerSync(rows.first);
    return _drift.getSpeciesById(id);
  }

  Future<List<Specy>> findByTraits(List<String> optionIds) async {
    if (optionIds.isEmpty) return getAll();
    final placeholders = List.filled(optionIds.length, '?').join(',');
    final rows = await _powerSync.getAll(
      '''
      SELECT s.* FROM species s
      INNER JOIN species_traits st ON s.id = st.species_id
      WHERE st.option_id IN ($placeholders) AND s.is_active = 1
      GROUP BY s.id
      HAVING COUNT(DISTINCT st.option_id) = ?
    ''',
      [...optionIds, optionIds.length],
    );
    if (rows.isNotEmpty) return rows.map(_speciesFromPowerSync).toList();
    return _drift.findSpeciesByTraits(optionIds);
  }

  Future<List<Question>> getAllQuestions() async {
    final rows = await _powerSync.getAll('''
      SELECT * FROM questions
      WHERE is_active = 1
      ORDER BY order_index ASC
    ''');
    if (rows.isEmpty) return _drift.getAllQuestions();
    return rows
        .map(
          (row) => Question(
            id: row['id']?.toString() ?? '',
            questionText: row['question_text']?.toString() ?? '',
            fieldName: row['field_name']?.toString() ?? '',
            requiredPart: row['required_part']?.toString() ?? 'general',
            orderIndex: (row['order_index'] as num?)?.toInt() ?? 0,
            isActive: _powerSyncBool(row['is_active']),
            syncStatus: 'synced',
          ),
        )
        .toList();
  }

  Future<List<QuestionOption>> getOptionsForQuestion(String questionId) async {
    final rows = await _powerSync.getAll(
      '''
      SELECT * FROM question_options
      WHERE question_id = ?
      ORDER BY order_index ASC
    ''',
      [questionId],
    );
    if (rows.isEmpty) return _drift.getOptionsForQuestion(questionId);
    return rows
        .map(
          (row) => QuestionOption(
            id: row['id']?.toString() ?? '',
            questionId: row['question_id']?.toString() ?? '',
            optionText: row['option_text']?.toString() ?? '',
            valueKey: row['value_key']?.toString() ?? '',
            orderIndex: (row['order_index'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Future<List<SpeciesTrait>> getAllTraits() async {
    final rows = await _powerSync.getAll('SELECT * FROM species_traits');
    if (rows.isEmpty) return _drift.getAllTraits();
    return rows
        .map(
          (row) => SpeciesTrait(
            id: row['id']?.toString() ?? '',
            speciesId: row['species_id']?.toString() ?? '',
            questionId: row['question_id']?.toString() ?? '',
            optionId: row['option_id']?.toString() ?? '',
          ),
        )
        .toList();
  }

  Future<List<QuestionConfig>> getQuestionnaireConfigs() async {
    final questions = await getAllQuestions();
    final configs = <QuestionConfig>[];

    for (final question in questions) {
      final options = await getOptionsForQuestion(question.id);
      configs.add(
        QuestionConfig(
          id: question.id,
          text: question.questionText,
          fieldName: question.fieldName,
          requiredPart: question.requiredPart,
          options: options
              .map(
                (option) => option.valueKey.isEmpty
                    ? option.optionText
                    : option.valueKey,
              )
              .toList(),
        ),
      );
    }

    return configs;
  }

  /// Seeds the database with initial species data if empty.
  Future<void> seedIfEmpty() async {
    final existing = await _drift.getAllSpecies();
    if (existing.isNotEmpty) return;

    await _drift.insertSeedSpecies(SeedData.speciesEntries);
    await _drift.insertSeedQuestions(SeedData.questionEntries);
    await _drift.insertSeedOptions(SeedData.optionEntries);
    await _drift.insertSeedTraits(SeedData.traitEntries);
  }

  /// Borra toda la base de datos y vuelve a cargar los datos semilla.
  Future<void> resetAndReseed() async {
    await _drift.resetDatabase();
    await _drift.insertSeedSpecies(SeedData.speciesEntries);
    await _drift.insertSeedQuestions(SeedData.questionEntries);
    await _drift.insertSeedOptions(SeedData.optionEntries);
    await _drift.insertSeedTraits(SeedData.traitEntries);
  }

  Specy _speciesFromPowerSync(Map<String, dynamic> row) => Specy(
    id: row['id']?.toString() ?? '',
    commonName: row['common_name']?.toString() ?? '',
    scientificName: row['scientific_name']?.toString() ?? '',
    description: row['description']?.toString() ?? '',
    imageUrl: row['image_url']?.toString() ?? '',
    family: row['family']?.toString() ?? '',
    habitat: row['habitat']?.toString() ?? '',
    flowerColor: row['flower_color']?.toString() ?? '',
    biologicalForm: row['biological_form']?.toString() ?? '',
    approximateHeight: row['approximate_height']?.toString() ?? '',
    leafLength: row['leaf_length']?.toString() ?? '',
    leafShape: row['leaf_shape']?.toString() ?? '',
    leafEdge: row['leaf_edge']?.toString() ?? '',
    leafTexture: row['leaf_texture']?.toString() ?? '',
    hasSpines: _powerSyncBool(row['has_spines']),
    spineType: row['spine_type']?.toString() ?? '',
    flowerGrouping: row['flower_grouping']?.toString() ?? '',
    petalCount: row['petal_count']?.toString() ?? '',
    flowerSize: row['flower_size']?.toString() ?? '',
    hasFruit: _powerSyncBool(row['has_fruit']),
    fruitShape: row['fruit_shape']?.toString() ?? '',
    fruitColor: row['fruit_color']?.toString() ?? '',
    fruitSize: row['fruit_size']?.toString() ?? '',
    observations: row['observations']?.toString() ?? '',
    isActive: _powerSyncBool(row['is_active']),
    syncStatus: 'synced',
    createdAt:
        DateTime.tryParse(row['created_at']?.toString() ?? '') ??
        DateTime.now(),
  );

  bool _powerSyncBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString().toLowerCase() == 'true' ||
        value?.toString() == '1';
  }
}
