import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:powersync/powersync.dart';

import '../../features/auth/services/session_service.dart';
import 'powersync_config.dart';

class AttachmentUploadService {
  final PowerSyncDatabase _database;
  final SessionService _sessionService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isUploading = false;
  bool _isActive = true;

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  AttachmentUploadService(
    this._database,
    this._sessionService, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

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
    if (!_isActive || _isUploading) return;
    _isUploading = true;

    try {
      final rows = await _database.getAll('''
        SELECT *
        FROM attachments_queue
        WHERE status = 'pending'
        ORDER BY created_at ASC
      ''');

      for (final row in rows) {
        if (!_isActive) return;
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
          final response = await _httpClient.put(
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

          if (!_isActive) return;

          if (response.statusCode >= 200 && response.statusCode < 300) {
            await _database.execute(
              'DELETE FROM attachments_queue WHERE id = ?',
              [queueId],
            );
          } else if (response.statusCode == 404) {
            // 404 = el registro de la foto (observation_photos) todavía no
            // sincronizó al servidor vía PowerSync. Es transitorio: se deja el
            // archivo en la cola y se reintenta en la próxima pasada (al
            // completar un upload de PowerSync o al cambiar la conectividad),
            // sin cortar la subida del resto de la cola.
            continue;
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            throw StateError(
              'Error de autorizacion subiendo attachment. HTTP ${response.statusCode}',
            );
          } else {
            // Error temporal: conservar el archivo para reintentar.
            debugPrint(
              'Attachments: subida pendiente de reintento. '
              'HTTP ${response.statusCode}, photoId=$photoId',
            );
            continue;
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
    _isActive = false;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    if (_ownsHttpClient) {
      _httpClient.close();
    }
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
