import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kospia/data/database/app_database.dart';

void main() {
  test(
    'upgrades version 9 without losing pending observations or photos',
    () async {
      final executor = NativeDatabase.memory(
        setup: (database) {
          database.execute('''
          CREATE TABLE question_options (
            id TEXT NOT NULL PRIMARY KEY,
            question_id TEXT NOT NULL,
            option_text TEXT NOT NULL,
            value_key TEXT NOT NULL DEFAULT '',
            order_index INTEGER NOT NULL DEFAULT 0
          )
        ''');
          database.execute('''
          CREATE TABLE observations (
            id TEXT NOT NULL PRIMARY KEY,
            user_id TEXT NOT NULL,
            species_id TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            sync_status TEXT NOT NULL DEFAULT 'pending',
            validation_status TEXT NOT NULL DEFAULT 'pending',
            validated_species_id TEXT,
            rejection_reason TEXT,
            created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
            updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
            synced_at INTEGER
          )
        ''');
          database.execute('''
          CREATE TABLE observation_photos (
            id TEXT NOT NULL PRIMARY KEY,
            observation_id TEXT NOT NULL,
            photo_path TEXT NOT NULL,
            plant_part TEXT NOT NULL DEFAULT 'general',
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            altitude REAL NOT NULL DEFAULT 0,
            accuracy REAL NOT NULL DEFAULT 0,
            source TEXT NOT NULL DEFAULT 'camera',
            sync_status TEXT NOT NULL DEFAULT 'pending',
            captured_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
            validation_status TEXT NOT NULL DEFAULT 'pending',
            validation_comment TEXT,
            validated_species_id TEXT,
            validated_at INTEGER,
            validated_by TEXT
          )
        ''');
          database.execute(
            "INSERT INTO question_options (id, question_id, option_text, value_key) VALUES ('option-1', 'question-1', 'Leaf', 'leaf')",
          );
          database.execute(
            "INSERT INTO observations (id, user_id, species_id, notes) VALUES ('observation-1', 'user-1', 'species-1', 'saved notes')",
          );
          database.execute(
            "INSERT INTO observation_photos (id, observation_id, photo_path, plant_part, latitude, longitude) VALUES ('photo-1', 'observation-1', 'local/photo.jpg', 'hoja', -45.0, -70.0)",
          );
          database.execute('PRAGMA user_version = 9');
        },
      );
      final database = AppDatabase.forTesting(executor);
      addTearDown(database.close);

      final observations = await database.getPendingObservations();
      expect(observations, hasLength(1));
      expect(observations.single.id, 'observation-1');
      expect(observations.single.notes, 'saved notes');
      expect(observations.single.syncStatus, 'pending');

      final photos = await database.getPhotosForObservation('observation-1');
      expect(photos, hasLength(1));
      expect(photos.single.id, 'photo-1');
      expect(photos.single.photoPath, 'local/photo.jpg');
      expect(photos.single.plantPart, 'hoja');
      expect(photos.single.syncStatus, 'pending');

      final option = (await database.getOptionsForQuestion('question-1'))
          .single;
      expect(option.valueKey, 'leaf');
      expect(option.description, isNull);
      expect(option.iconAttachmentId, isNull);

      await database
          .into(database.questionOptionPhotos)
          .insert(
            QuestionOptionPhotosCompanion.insert(
              id: 'help-photo-1',
              optionId: 'option-1',
              orderIndex: const Value(2),
            ),
          );
      expect(
        (await database.getOptionPhotos('option-1')).single.id,
        'help-photo-1',
      );
      expect(
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        10,
      );
    },
  );
}
