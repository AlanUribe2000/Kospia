import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kospia/data/database/app_database.dart';
import 'package:kospia/data/services/sequential_questionnaire.dart';

AppDatabase historicalDatabase() {
  return AppDatabase.forTesting(
    NativeDatabase.memory(
      setup: (database) {
        for (final statement in [
          '''CREATE TABLE species (
            id TEXT NOT NULL PRIMARY KEY, common_name TEXT NOT NULL,
            scientific_name TEXT NOT NULL, description TEXT NOT NULL,
            image_url TEXT NOT NULL DEFAULT '', family TEXT NOT NULL DEFAULT '',
            habitat TEXT NOT NULL DEFAULT '', flower_color TEXT NOT NULL DEFAULT '',
            biological_form TEXT NOT NULL DEFAULT '', approximate_height TEXT NOT NULL DEFAULT '',
            leaf_length TEXT NOT NULL DEFAULT '', leaf_shape TEXT NOT NULL DEFAULT '',
            leaf_edge TEXT NOT NULL DEFAULT '', leaf_texture TEXT NOT NULL DEFAULT '',
            has_spines INTEGER NOT NULL DEFAULT 0, spine_type TEXT NOT NULL DEFAULT '',
            flower_grouping TEXT NOT NULL DEFAULT '', petal_count TEXT NOT NULL DEFAULT '',
            flower_size TEXT NOT NULL DEFAULT '', has_fruit INTEGER NOT NULL DEFAULT 0,
            fruit_shape TEXT NOT NULL DEFAULT '', fruit_color TEXT NOT NULL DEFAULT '',
            fruit_size TEXT NOT NULL DEFAULT '', observations TEXT NOT NULL DEFAULT '',
            is_active INTEGER NOT NULL DEFAULT 1, sync_status TEXT NOT NULL DEFAULT 'synced',
            created_at INTEGER NOT NULL DEFAULT 0)''',
          '''CREATE TABLE questions (
            id TEXT NOT NULL PRIMARY KEY, question_text TEXT NOT NULL,
            field_name TEXT NOT NULL DEFAULT '', required_part TEXT NOT NULL DEFAULT 'general',
            order_index INTEGER NOT NULL, is_active INTEGER NOT NULL DEFAULT 1,
            sync_status TEXT NOT NULL DEFAULT 'synced')''',
          '''CREATE TABLE question_options (
            id TEXT NOT NULL PRIMARY KEY, question_id TEXT NOT NULL,
            option_text TEXT NOT NULL, value_key TEXT NOT NULL DEFAULT '',
            order_index INTEGER NOT NULL DEFAULT 0)''',
          '''CREATE TABLE species_traits (
            id TEXT NOT NULL PRIMARY KEY, species_id TEXT NOT NULL,
            question_id TEXT NOT NULL, option_id TEXT NOT NULL)''',
          '''CREATE TABLE observations (
            id TEXT NOT NULL PRIMARY KEY, user_id TEXT NOT NULL, species_id TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT '', sync_status TEXT NOT NULL DEFAULT 'pending',
            validation_status TEXT NOT NULL DEFAULT 'pending', validated_species_id TEXT,
            rejection_reason TEXT, created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0, synced_at INTEGER)''',
          '''CREATE TABLE observation_photos (
            id TEXT NOT NULL PRIMARY KEY, observation_id TEXT NOT NULL, photo_path TEXT NOT NULL,
            plant_part TEXT NOT NULL DEFAULT 'general', latitude REAL NOT NULL, longitude REAL NOT NULL,
            altitude REAL NOT NULL DEFAULT 0, accuracy REAL NOT NULL DEFAULT 0,
            source TEXT NOT NULL DEFAULT 'camera', sync_status TEXT NOT NULL DEFAULT 'pending',
            captured_at INTEGER NOT NULL DEFAULT 0, validation_status TEXT NOT NULL DEFAULT 'pending',
            validation_comment TEXT, validated_species_id TEXT, validated_at INTEGER, validated_by TEXT)''',
          '''CREATE TABLE users (
            id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL DEFAULT '',
            total_observations INTEGER NOT NULL DEFAULT 0, species_unlocked INTEGER NOT NULL DEFAULT 0,
            sync_status TEXT NOT NULL DEFAULT 'synced', created_at INTEGER NOT NULL DEFAULT 0)''',
          '''CREATE TABLE notifications (
            id TEXT NOT NULL PRIMARY KEY, user_id TEXT NOT NULL, observation_id TEXT NOT NULL,
            type TEXT NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL, old_species_id TEXT,
            old_species_name TEXT, new_species_id TEXT, new_species_name TEXT, read_at INTEGER,
            created_at INTEGER NOT NULL DEFAULT 0)''',
          '''CREATE TABLE attachments_queue (
            id TEXT NOT NULL PRIMARY KEY, photo_id TEXT, local_path TEXT,
            extension TEXT, status TEXT, created_at TEXT)''',
          "INSERT INTO species (id, common_name, scientific_name, description, biological_form, leaf_shape, has_spines) VALUES ('sp-1', 'A', 'A', 'saved', 'arbusto', 'oval', 1), ('sp-2', 'B', 'B', 'saved', 'hierba', 'linear', 0)",
          "INSERT INTO questions (id, question_text, field_name, required_part, order_index) VALUES ('q-form', 'Form', 'biologicalForm', 'general', 1), ('q-leaf', 'Leaf', 'leafShape', 'hoja', 2)",
          "INSERT INTO question_options (id, question_id, option_text, value_key, order_index) VALUES ('opt-1', 'q-form', 'Shrub', 'arbusto', 1), ('opt-2', 'q-leaf', 'Oval', 'oval', 1)",
          "INSERT INTO species_traits VALUES ('trait-1', 'sp-1', 'q-form', 'opt-1')",
          "INSERT INTO observations (id, user_id, species_id, notes, sync_status, validation_status) VALUES ('obs-pending', 'user-1', 'sp-1', 'offline notes', 'pending', 'rejected'), ('obs-synced', 'user-1', 'sp-2', 'synced notes', 'synced', 'pending')",
          "INSERT INTO observation_photos (id, observation_id, photo_path, plant_part, latitude, longitude, sync_status, validation_status) VALUES ('photo-pending', 'obs-pending', 'offline.jpg', 'hoja', -45, -70, 'pending', 'validated'), ('photo-synced', 'obs-synced', 'uploaded.jpg', 'general', -46, -71, 'synced', 'pending')",
          "INSERT INTO users (id, name, email) VALUES ('user-1', 'User', 'user@example.test')",
          "INSERT INTO notifications (id, user_id, observation_id, type, title, body) VALUES ('notification-1', 'user-1', 'obs-pending', 'rejected', 'Title', 'Body')",
          "INSERT INTO attachments_queue VALUES ('queue-1', 'photo-pending', 'offline.jpg', 'jpg', 'pending', '2026-01-01'), ('queue-2', 'photo-synced', 'uploaded.jpg', 'jpg', 'synced', '2026-01-02')",
          'PRAGMA user_version = 9',
        ]) {
          database.execute(statement);
        }
      },
    ),
  );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = historicalDatabase();
  });
  tearDown(() => database.close());

  test(
    'complete v9 fixture retains rows and pending states on upgrade',
    () async {
      expect(database.schemaVersion, 10);
      final pending = await database.getPendingObservations();
      expect(pending.map((row) => row.id), ['obs-pending']);
      expect(pending.single.notes, 'offline notes');
      expect(pending.single.validationStatus, 'rejected');
      expect(
        (await database.getAllObservations()).map((row) => row.id).toSet(),
        {'obs-pending', 'obs-synced'},
      );

      final photos = await database.getPhotosForObservation('obs-pending');
      expect(photos.single.photoPath, 'offline.jpg');
      expect(photos.single.syncStatus, 'pending');
      expect(photos.single.validationStatus, 'validated');
      expect(
        (await database.getPhotosForObservation('obs-synced'))
            .single
            .syncStatus,
        'synced',
      );

      expect((await database.getAllSpecies()).map((row) => row.id).toSet(), {
        'sp-1',
        'sp-2',
      });
      expect((await database.getAllQuestions()).map((row) => row.id), [
        'q-form',
        'q-leaf',
      ]);
      expect((await database.getAllTraits()).single.id, 'trait-1');
      expect(
        (await database.getUserById('user-1'))?.email,
        'user@example.test',
      );
      expect((await database.getNotifications()).single.body, 'Body');
      final option = (await database.getOptionsForQuestion('q-form')).single;
      expect(option.valueKey, 'arbusto');
      expect(option.description, isNull);
      expect(option.iconAttachmentId, isNull);
      expect(
        (await database.getOptionsForQuestion('q-leaf')).single.id,
        'opt-2',
      );

      final queue = await database
          .customSelect(
            'SELECT id, photo_id, local_path, extension, status, created_at FROM attachments_queue ORDER BY id',
          )
          .get();
      expect(queue.map((row) => row.read<String>('id')), [
        'queue-1',
        'queue-2',
      ]);
      expect(queue.first.read<String>('photo_id'), 'photo-pending');
      expect(queue.first.read<String>('local_path'), 'offline.jpg');
      expect(queue.first.read<String>('extension'), 'jpg');
      expect(queue.first.read<String>('status'), 'pending');
      expect(queue.first.read<String>('created_at'), '2026-01-01');
      expect(queue.last.read<String>('status'), 'synced');

      await database
          .into(database.questionOptionPhotos)
          .insert(
            QuestionOptionPhotosCompanion.insert(
              id: 'help-1',
              optionId: 'opt-1',
              orderIndex: const Value(2),
            ),
          );
      expect((await database.getOptionPhotos('opt-1')).single.id, 'help-1');
      expect(
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        10,
      );
    },
  );

  test(
    'migrated questions drive filtering, unknown answers and undo',
    () async {
      final questions = await database.getAllQuestions();
      final configs = <QuestionConfig>[];
      for (final question in questions) {
        final options = await database.getOptionsForQuestion(question.id);
        configs.add(
          QuestionConfig(
            id: question.id,
            text: question.questionText,
            fieldName: question.fieldName,
            requiredPart: question.requiredPart,
            options: options.map((option) => option.valueKey).toList(),
          ),
        );
      }
      final questionnaire = SequentialQuestionnaire(
        allSpecies: await database.getAllSpecies(),
        photoParts: {'hoja'},
        questions: configs,
      );
      expect(questionnaire.currentQuestion?.id, 'q-form');
      questionnaire.answer('arbusto');
      expect(questionnaire.candidates.map((row) => row.id), ['sp-1']);
      expect(questionnaire.currentQuestion?.id, 'q-leaf');
      questionnaire.answer(SequentialQuestionnaire.noSabe);
      expect(questionnaire.isFinished, isTrue);
      expect(questionnaire.candidates.single.id, 'sp-1');
      questionnaire.undo();
      expect(questionnaire.currentQuestion?.id, 'q-leaf');
      expect(questionnaire.answers, {'biologicalForm': 'arbusto'});
      questionnaire.undo();
      expect(questionnaire.candidates.map((row) => row.id).toSet(), {
        'sp-1',
        'sp-2',
      });
      expect(questionnaire.canUndo, isFalse);

      final generalOnly = SequentialQuestionnaire(
        allSpecies: await database.getAllSpecies(),
        photoParts: {},
        questions: configs,
      );
      expect(generalOnly.totalQuestions, 1);
      expect(generalOnly.currentQuestion?.id, 'q-form');
    },
  );
}
