import 'package:flutter/foundation.dart';

import '../../../data/powersync/powersync_session_manager.dart';
import '../services/google_auth_service.dart';
import '../services/session_service.dart';

enum AuthStatus { loading, unauthenticated, authenticated, error }

class AuthController extends ChangeNotifier {
  AuthController(
    this._sessionService,
    this._googleAuthService,
    this._powerSyncSessionManager,
  );

  final SessionService _sessionService;
  final GoogleAuthService _googleAuthService;
  final PowerSyncSessionManager _powerSyncSessionManager;

  AuthStatus _status = AuthStatus.unauthenticated;
  KospiaSession? _session;
  Object? _error;
  bool _operationInProgress = false;

  AuthStatus get status => _status;
  KospiaSession? get session => _session;
  Object? get error => _error;
  bool get isLoading => _operationInProgress || _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> restoreSession() async {
    if (_operationInProgress) return;

    _beginOperation();
    try {
      final restoredSession = await _sessionService.loadSession();
      if (restoredSession == null) {
        _session = null;
        _setStatus(AuthStatus.unauthenticated);
        return;
      }

      _session = restoredSession;
      try {
        await _powerSyncSessionManager.activateSession(restoredSession);
        _setStatus(AuthStatus.authenticated);
      } catch (error, stackTrace) {
        _logFailure('restore_powersync_activate', error, stackTrace);
        // Keep the valid local session and its per-user SQLite database. A
        // temporary PowerSync/network failure must not log the user out.
        _setError(error);
      }
    } catch (error, stackTrace) {
      _logFailure('restore_load_session', error, stackTrace);
      _session = null;
      _setError(error);
    } finally {
      _endOperation();
    }
  }

  Future<void> signInWithGoogle() async {
    if (_operationInProgress) return;

    _beginOperation();
    _session = null;
    var stage = 'start';
    try {
      stage = 'google_authenticate';
      await _googleAuthService.authenticate();
      stage = 'kospia_backend_auth_google';
      final authenticatedSession = await _googleAuthService
          .authenticateWithKospiaBackend();
      stage = 'save_session_secure_storage';

      // Save only after Google and /auth/google have both returned a complete
      // Kospia session. A failed authentication never persists a new session.
      await _sessionService.saveSession(authenticatedSession);
      _session = authenticatedSession;

      try {
        stage = 'powersync_activate';
        await _powerSyncSessionManager.activateSession(authenticatedSession);
        _setStatus(AuthStatus.authenticated);
      } catch (error, stackTrace) {
        _logFailure(stage, error, stackTrace);
        // The Kospia session is valid even when PowerSync is temporarily
        // unavailable, so keep it for a later retry.
        _setError(error);
      }
    } catch (error, stackTrace) {
      _logFailure(stage, error, stackTrace);
      _session = null;
      _setError(error);
    } finally {
      _endOperation();
    }
  }

  Future<void> logout() async {
    if (_operationInProgress) return;

    _beginOperation();
    Object? firstError;
    try {
      try {
        await _powerSyncSessionManager.deactivateSession();
      } catch (error) {
        firstError ??= error;
      }

      try {
        await _sessionService.clearSession();
      } catch (error) {
        firstError ??= error;
      }

      try {
        await _googleAuthService.signOut();
      } catch (error) {
        firstError ??= error;
      }

      _session = null;
      if (firstError == null) {
        _setStatus(AuthStatus.unauthenticated);
      } else {
        _setError(firstError);
      }
    } finally {
      _endOperation();
    }

    if (firstError != null) {
      throw StateError('No se pudo completar completamente el logout.');
    }
  }

  void _logFailure(String stage, Object error, StackTrace stackTrace) {
    debugPrint('[Auth] fallo en etapa=$stage tipo=${error.runtimeType} causa=$error');
    debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
  }

  void _beginOperation() {
    _operationInProgress = true;
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _endOperation() {
    _operationInProgress = false;
    notifyListeners();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    _error = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status = AuthStatus.error;
    _error = error;
    notifyListeners();
  }
}
