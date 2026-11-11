import '../database/app_database.dart';
import '../seed/seed_data.dart';
import '../services/sequential_questionnaire.dart';

import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';

/// Repositorio de especies. Maneja acceso a datos de flora.
class SpeciesRepository {
  final AppDatabase _drift;
  final PowerSyncDatabase _powerSync;

  SpeciesRepository(this._drift, this._powerSync);

  Future<void> logIdentificationDiagnostics() async {
    final counts = <String, int>{};
    for (final table in [
      'questions',
      'question_options',
      'species',
      'species_traits',
    ]) {
      final row = await _powerSync.get('SELECT COUNT(*) AS count FROM $table');
      counts[table] = (row['count'] as num?)?.toInt() ?? 0;
    }

    debugPrint('[IDENTIFY DEBUG] questions=${counts['questions']}');
    debugPrint(
      '[IDENTIFY DEBUG] question_options=${counts['question_options']}',
    );
    debugPrint('[IDENTIFY DEBUG] species=${counts['species']}');
    debugPrint('[IDENTIFY DEBUG] species_traits=${counts['species_traits']}');

    final options = await _powerSync.getAll(
      'SELECT id, question_id, value_key FROM question_options '
      'ORDER BY question_id, order_index',
    );
    for (final option in options) {
      debugPrint(
        '[IDENTIFY DEBUG] option.id=${option['id']} '
        'option.question_id=${option['question_id']} '
        'option.value_key=${option['value_key']}',
      );
    }
  }

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
    debugPrint('[IDENTIFY DEBUG] questions=${rows.length}');
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
    debugPrint(
      '[IDENTIFY DEBUG] options for question=$questionId count=${rows.length}',
    );
    for (final row in rows) {
      debugPrint(
        '[IDENTIFY DEBUG] option.id=${row['id']} '
        'option.question_id=${row['question_id']} '
        'option.value_key=${row['value_key']}',
      );
    }
    if (rows.isEmpty) return _drift.getOptionsForQuestion(questionId);
    return rows
        .map(
          (row) => QuestionOption(
            id: row['id']?.toString() ?? '',
            questionId: row['question_id']?.toString() ?? '',
            optionText: row['option_text']?.toString() ?? '',
            valueKey: row['value_key']?.toString() ?? '',
            orderIndex: (row['order_index'] as num?)?.toInt() ?? 0,
            description: _nullableString(row['description']),
            iconAttachmentId: _nullableString(row['icon_attachment_id']),
          ),
        )
        .toList();
  }

  /// Datos de ayuda de las opciones de una pregunta: etiqueta, texto
  /// descriptivo, icono (icon_attachment_id) y galería de fotos de ayuda.
  /// Se usa para el popup de ayuda ('?') de cada tarjeta de pregunta.
  /// PowerSync-first, con fallback a drift local.
  Future<List<OptionHelp>> getOptionHelpForQuestion(String questionId) async {
    final options = await getOptionsForQuestion(questionId);
    final help = <OptionHelp>[];
    for (final option in options) {
      final photos = await getOptionPhotos(option.id);
      help.add(
        OptionHelp(
          optionId: option.id,
          valueKey: option.valueKey,
          optionText: option.optionText,
          description: option.description,
          iconAttachmentId: option.iconAttachmentId,
          photos: photos,
        ),
      );
    }
    return help;
  }

  /// Versión reactiva de [getOptionHelpForQuestion]: emite la lista de
  /// [OptionHelp] de la pregunta cada vez que PowerSync aplica cambios en las
  /// tablas subyacentes (`question_options` y `question_option_photos`), ya
  /// sea por escrituras locales o por sync entrante desde la web. Así la
  /// pantalla de identificación refleja en vivo íconos/descripciones/fotos
  /// nuevos sin salir ni reiniciar la app.
  ///
  /// Un único [PowerSyncDatabase.watch] con JOIN evita el N+1 por opción:
  /// trae opciones + fotos en una sola consulta y reconstruye la lista en cada
  /// emisión. `triggerOnTables` asegura que un cambio en cualquiera de las dos
  /// tablas dispare una nueva emisión aunque la pregunta no tenga filas en
  /// `question_option_photos` todavía.
  ///
  /// Fallback a drift local SOLO para el arranque offline (cuando PowerSync
  /// aún no tiene filas), igual que el resto del repo; se prioriza PowerSync.
  Stream<List<OptionHelp>> watchOptionHelpForQuestion(String questionId) {
    return _powerSync
        .watch(
          '''
          SELECT
            o.id AS option_id,
            o.question_id AS question_id,
            o.option_text AS option_text,
            o.value_key AS value_key,
            o.order_index AS option_order_index,
            o.description AS description,
            o.icon_attachment_id AS icon_attachment_id,
            p.id AS photo_id,
            p.order_index AS photo_order_index,
            p.file_extension AS photo_file_extension
          FROM question_options o
          LEFT JOIN question_option_photos p ON p.option_id = o.id
          WHERE o.question_id = ?
          ORDER BY o.order_index ASC, p.order_index ASC
          ''',
          parameters: [questionId],
          triggerOnTables: const {'question_options', 'question_option_photos'},
        )
        .asyncMap((rows) async {
          if (rows.isEmpty) {
            // Arranque offline: PowerSync aún no sincronizó. Usar drift local.
            return _optionHelpFromDrift(questionId);
          }
          return _optionHelpFromJoinedRows(rows);
        });
  }

  /// Reconstruye la lista de [OptionHelp] a partir de las filas del JOIN
  /// opciones+fotos, preservando el orden de opciones y de fotos.
  List<OptionHelp> _optionHelpFromJoinedRows(List<Map<String, dynamic>> rows) {
    final byOption = <String, OptionHelp>{};
    final photosByOption = <String, List<OptionPhoto>>{};
    final order = <String>[];

    for (final row in rows) {
      final optionId = row['option_id']?.toString() ?? '';
      if (optionId.isEmpty) continue;
      if (!byOption.containsKey(optionId)) {
        order.add(optionId);
        byOption[optionId] = OptionHelp(
          optionId: optionId,
          valueKey: row['value_key']?.toString() ?? '',
          optionText: row['option_text']?.toString() ?? '',
          description: _nullableString(row['description']),
          iconAttachmentId: _nullableString(row['icon_attachment_id']),
          photos: const [],
        );
        photosByOption[optionId] = [];
      }
      final photoId = row['photo_id']?.toString();
      if (photoId != null && photoId.isNotEmpty) {
        photosByOption[optionId]!.add(
          OptionPhoto(
            id: photoId,
            optionId: optionId,
            orderIndex: (row['photo_order_index'] as num?)?.toInt() ?? 0,
            fileExtension: _nullableString(row['photo_file_extension']),
          ),
        );
      }
    }

    return [
      for (final optionId in order)
        OptionHelp(
          optionId: byOption[optionId]!.optionId,
          valueKey: byOption[optionId]!.valueKey,
          optionText: byOption[optionId]!.optionText,
          description: byOption[optionId]!.description,
          iconAttachmentId: byOption[optionId]!.iconAttachmentId,
          photos: photosByOption[optionId]!,
        ),
    ];
  }

  /// Fallback offline: arma la ayuda desde drift local (mismo patrón que
  /// [getOptionHelpForQuestion] pero sin tocar PowerSync).
  Future<List<OptionHelp>> _optionHelpFromDrift(String questionId) async {
    final options = await _drift.getOptionsForQuestion(questionId);
    final help = <OptionHelp>[];
    for (final option in options) {
      final localPhotos = await _drift.getOptionPhotos(option.id);
      help.add(
        OptionHelp(
          optionId: option.id,
          valueKey: option.valueKey,
          optionText: option.optionText,
          description: option.description,
          iconAttachmentId: option.iconAttachmentId,
          photos: localPhotos
              .map(
                (row) => OptionPhoto(
                  id: row.id,
                  optionId: row.optionId,
                  orderIndex: row.orderIndex,
                  fileExtension: row.fileExtension,
                ),
              )
              .toList(),
        ),
      );
    }
    return help;
  }

  /// Fotos de ayuda de una opción, ordenadas por order_index.
  /// PowerSync-first, con fallback a drift local.
  Future<List<OptionPhoto>> getOptionPhotos(String optionId) async {
    final rows = await _powerSync.getAll(
      '''
      SELECT * FROM question_option_photos
      WHERE option_id = ?
      ORDER BY order_index ASC
    ''',
      [optionId],
    );
    if (rows.isNotEmpty) {
      return rows
          .map(
            (row) => OptionPhoto(
              id: row['id']?.toString() ?? '',
              optionId: row['option_id']?.toString() ?? '',
              orderIndex: (row['order_index'] as num?)?.toInt() ?? 0,
              fileExtension: _nullableString(row['file_extension']),
            ),
          )
          .toList();
    }
    final local = await _drift.getOptionPhotos(optionId);
    return local
        .map(
          (row) => OptionPhoto(
            id: row.id,
            optionId: row.optionId,
            orderIndex: row.orderIndex,
            fileExtension: row.fileExtension,
          ),
        )
        .toList();
  }

  String? _nullableString(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return text;
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

/// Datos de ayuda de una opción para el popup del cuestionario:
/// etiqueta, texto descriptivo, icono (si tiene) y galería de fotos.
class OptionHelp {
  final String optionId;
  final String valueKey;
  final String optionText;
  final String? description;
  final String? iconAttachmentId;
  final List<OptionPhoto> photos;

  const OptionHelp({
    required this.optionId,
    required this.valueKey,
    required this.optionText,
    required this.description,
    required this.iconAttachmentId,
    required this.photos,
  });

  bool get hasContent =>
      photos.isNotEmpty || (description?.trim().isNotEmpty ?? false);
}

/// Foto de ayuda (galería) de una opción.
class OptionPhoto {
  final String id;
  final String optionId;
  final int orderIndex;
  final String? fileExtension;

  const OptionPhoto({
    required this.id,
    required this.optionId,
    required this.orderIndex,
    required this.fileExtension,
  });
}
