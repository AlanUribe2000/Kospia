import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:powersync/powersync.dart';

import '../../features/auth/services/session_service.dart';
import 'powersync_config.dart';

class AttachmentUploadService {
  final PowerSyncDatabase _database;
  final SessionService _sessionService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isUploading = false;

  AttachmentUploadService(this._database, this._sessionService);

  void startConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        uploadPending();
      }
    });
  }

  Future<void> uploadPending() async {
    if (_isUploading) return;
    _isUploading = true;

    try {
      final rows = await _database.getAll('''
        SELECT *
        FROM attachments_queue
        WHERE status = 'pending'
        ORDER BY created_at ASC
      ''');

      for (final row in rows) {
        final queueId = row['id']?.toString() ?? '';
        final photoId = row['photo_id']?.toString() ?? '';
        final localPath = row['local_path']?.toString() ?? '';
        final extension = row['extension']?.toString() ?? 'jpg';
        if (queueId.isEmpty || photoId.isEmpty || localPath.isEmpty) continue;

        final file = File(localPath);
        if (!await file.exists()) continue;

        final session = await _sessionService.loadSession();
        if (session == null) {
          throw StateError(
            'No hay una sesión Kospia válida para subir attachments.',
          );
        }

        try {
          final response = await http.put(
            Uri.parse(
              '${PowerSyncConfig.backendUrl}/attachments/$photoId'
              '?extension=$extension',
            ),
            headers: {
              'Content-Type': _contentTypeForExtension(extension),
              'Authorization': 'Bearer ${session.accessToken}',
            },
            body: await file.readAsBytes(),
          );

          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _database.execute(
              'DELETE FROM attachments_queue WHERE id = ?',
              [queueId],
            );
          } else {
            throw StateError(
              'Error seguro subiendo attachment. HTTP ${response.statusCode}',
            );
          }
        } on StateError {
          rethrow;
        } catch (_) {
          continue;
        }
      }
    } finally {
      _isUploading = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  String _contentTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
