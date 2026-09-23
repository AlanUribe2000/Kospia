import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';

import '../../features/auth/services/session_service.dart';
import 'attachment_upload_service.dart';
import 'backend_connector.dart';
import 'powersync_database.dart';

class PowerSyncSessionManager extends ChangeNotifier {
  PowerSyncSessionManager(this._sessionService);

  final SessionService _sessionService;

  PowerSyncDatabase? _database;
  AttachmentUploadService? _attachmentUploadService;
  String? _activeUserId;
  bool _isSwitching = false;

  PowerSyncDatabase? get database => _database;
  AttachmentUploadService? get attachmentUploadService =>
      _attachmentUploadService;
  String? get activeUserId => _activeUserId;
  bool get hasActiveSession => _database != null && _activeUserId != null;
  SyncStatus? get currentStatus => _database?.currentStatus;

  Future<void> activateSession(KospiaSession session) async {
    if (_isSwitching) {
      throw StateError('Ya hay un cambio de sesión PowerSync en curso.');
    }

    if (_activeUserId == session.userId && _database != null) {
      return;
    }

    _isSwitching = true;
    try {
      await deactivateSession();

      final database = await openKospiaPowerSyncDatabase(session.userId);
      final attachmentUploadService = AttachmentUploadService(
        database,
        _sessionService,
      );

      _database = database;
      _attachmentUploadService = attachmentUploadService;
      _activeUserId = session.userId;
      notifyListeners();

      await database.connect(
        connector: KospiaBackendConnector(_sessionService),
      );
      attachmentUploadService.startConnectivityListener();
      unawaited(attachmentUploadService.uploadPending());
    } catch (_) {
      final database = _database;
      _database = null;
      _attachmentUploadService = null;
      _activeUserId = null;
      notifyListeners();
      if (database != null && !database.closed) {
        await database.close();
      }
      rethrow;
    } finally {
      _isSwitching = false;
    }
  }

  Future<void> deactivateSession() async {
    final attachmentUploadService = _attachmentUploadService;
    _attachmentUploadService = null;
    attachmentUploadService?.dispose();

    final database = _database;
    _database = null;
    _activeUserId = null;
    notifyListeners();

    if (database != null && !database.closed) {
      await database.close();
    }
  }

  Future<void> disposeManager() async {
    await deactivateSession();
    dispose();
  }

  Future<void> uploadPendingAttachments() async {
    await _attachmentUploadService?.uploadPending();
  }
}
