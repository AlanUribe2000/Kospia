import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:powersync/powersync.dart';

import 'package:kospia/data/powersync/attachment_upload_service.dart';
import 'package:kospia/features/auth/services/session_service.dart';

class FakeSessionService extends SessionService {
  @override
  Future<KospiaSession?> loadSession() async {
    return const KospiaSession(
      accessToken: 'token-de-prueba',
      userId: '123e4567-e89b-42d3-a456-426614174000',
      email: 'test@example.com',
      displayName: 'Usuario de prueba',
      photoUrl: '',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late PowerSyncDatabase db;
  late File photoFile;
  AttachmentUploadService? service;

  setUp(() async {
    service = null;
    tempDir = await Directory.systemTemp.createTemp('kospia_upload_test_');

    db = PowerSyncDatabase(
      schema: const Schema([
        Table.localOnly('attachments_queue', [
          Column.text('photo_id'),
          Column.text('local_path'),
          Column.text('extension'),
          Column.text('status'),
          Column.text('created_at'),
        ]),
      ]),
      path: '${tempDir.path}/test.db',
    );

    await db.initialize();

    photoFile = File('${tempDir.path}/photo.jpg');
    await photoFile.writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    service?.dispose();
    await db.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> enqueue(String id) async {
    await db.execute(
      '''
      INSERT INTO attachments_queue
        (id, photo_id, local_path, extension, status, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        id,
        id,
        photoFile.path,
        'jpg',
        'pending',
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }

  Future<int> pendingCount() async {
    final rows = await db.getAll(
      "SELECT * FROM attachments_queue WHERE status = 'pending'",
    );
    return rows.length;
  }

  void configureClient(Future<http.Response> Function(http.Request) handler) {
    service = AttachmentUploadService(
      db,
      FakeSessionService(),
      httpClient: MockClient(handler),
    );
  }

  test('HTTP 200 elimina el elemento de la cola', () async {
    await enqueue('photo-200');

    configureClient((request) async => http.Response('', 200));

    await service!.uploadPending();

    expect(await pendingCount(), 0);
  });

  test('HTTP 404 conserva el elemento pendiente', () async {
    await enqueue('photo-404');

    configureClient((request) async => http.Response('', 404));

    await service!.uploadPending();

    expect(await pendingCount(), 1);
  });

  test('HTTP 500 conserva el elemento pendiente', () async {
    await enqueue('photo-500');

    configureClient((request) async => http.Response('', 500));

    await service!.uploadPending();

    expect(await pendingCount(), 1);
  });

  test('HTTP 500 no impide procesar otra fotografia', () async {
    await enqueue('photo-error');
    await enqueue('photo-ok');

    configureClient((request) async {
      if (request.url.path.endsWith('/photo-error')) {
        return http.Response('', 500);
      }
      return http.Response('', 200);
    });

    await service!.uploadPending();

    final rows = await db.getAll('SELECT photo_id FROM attachments_queue');

    expect(rows.length, 1);
    expect(rows.single['photo_id'], 'photo-error');
  });

  test('HTTP 401 conserva el elemento y detiene la pasada', () async {
    await enqueue('photo-401');

    configureClient((request) async => http.Response('', 401));

    await expectLater(service!.uploadPending(), throwsA(isA<StateError>()));

    expect(await pendingCount(), 1);
  });

  test('HTTP 403 conserva el elemento y detiene la pasada', () async {
    await enqueue('photo-403');

    configureClient((request) async => http.Response('', 403));

    await expectLater(service!.uploadPending(), throwsA(isA<StateError>()));

    expect(await pendingCount(), 1);
  });
}
