import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PowerSyncDatabase db;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kospia_ps_test_');

    db = PowerSyncDatabase(
      schema: const Schema([
        Table.localOnly('test_observations', [
          Column.text('species_id'),
        ]),
        Table.localOnly('test_photos', [
          Column.text('observation_id'),
        ]),
        Table.localOnly('test_queue', [
          Column.text('photo_id'),
        ]),
      ]),
      path: '${tempDir.path}/test.db',
    );

    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  test('revierte todas las inserciones ante un error', () async {
    await expectLater(
      db.writeTransaction((tx) async {
        await tx.execute(
          'INSERT INTO test_observations (id, species_id) VALUES (?, ?)',
          ['obs-1', 'species-1'],
        );

        await tx.execute(
          'INSERT INTO test_photos (id, observation_id) VALUES (?, ?)',
          ['photo-1', 'obs-1'],
        );

        await tx.execute(
          'INSERT INTO test_queue (id, photo_id) VALUES (?, ?)',
          ['queue-1', 'photo-1'],
        );

        throw StateError('Fallo simulado');
      }),
      throwsA(isA<StateError>()),
    );

    final observations = await db.getAll(
      'SELECT * FROM test_observations',
    );

    final photos = await db.getAll(
      'SELECT * FROM test_photos',
    );

    final queue = await db.getAll(
      'SELECT * FROM test_queue',
    );

    expect(observations, isEmpty);
    expect(photos, isEmpty);
    expect(queue, isEmpty);
  });

  test('confirma todas las inserciones si no hay errores', () async {
    await db.writeTransaction((tx) async {
      await tx.execute(
        'INSERT INTO test_observations (id, species_id) VALUES (?, ?)',
        ['obs-2', 'species-2'],
      );

      await tx.execute(
        'INSERT INTO test_photos (id, observation_id) VALUES (?, ?)',
        ['photo-2', 'obs-2'],
      );

      await tx.execute(
        'INSERT INTO test_queue (id, photo_id) VALUES (?, ?)',
        ['queue-2', 'photo-2'],
      );
    });

    final observations = await db.getAll(
      'SELECT * FROM test_observations',
    );

    final photos = await db.getAll(
      'SELECT * FROM test_photos',
    );

    final queue = await db.getAll(
      'SELECT * FROM test_queue',
    );

    expect(observations.length, 1);
    expect(photos.length, 1);
    expect(queue.length, 1);
  });
}
