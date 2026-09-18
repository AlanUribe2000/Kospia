import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../data/powersync/powersync_config.dart';
import 'session_service.dart';

class GoogleAuthService {
  GoogleAuthService();

  static const _serverClientId = String.fromEnvironment(
    'KOSPIA_GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  bool _initialized = false;
  GoogleSignInAccount? currentAccount;
  GoogleSignInAuthentication? currentAuthentication;

  bool get hasConfiguredServerClientId => _serverClientId.isNotEmpty;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (_serverClientId.isEmpty) {
      throw StateError(
        'Falta --dart-define=KOSPIA_GOOGLE_SERVER_CLIENT_ID para Google Sign-In.',
      );
    }

    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }

  Future<GoogleSignInAccount> authenticate() async {
    await initialize();

    final account = await GoogleSignIn.instance.authenticate();
    currentAccount = account;
    currentAuthentication = account.authentication;

    return account;
  }

  Future<KospiaSession> authenticateWithKospiaBackend() async {
    final token = currentAuthentication?.idToken;
    if (token == null || token.isEmpty) {
      throw StateError('No se obtuvo Google ID token.');
    }

    final uri = Uri.parse('${PowerSyncConfig.backendUrl}/auth/google');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': token}),
    );

    final decoded =
        response.headers.containsKey('content-type') &&
            response.headers['content-type']?.contains('application/json') ==
                true
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final accessToken = decoded['access_token']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        throw HttpException(
          'Backend Kospia: ERROR\nHTTP ${response.statusCode}\nSesión no creada',
        );
      }

      final user = decoded['user'] as Map<String, dynamic>?;
      if (user == null) {
        throw const HttpException(
          'Backend Kospia: ERROR\nHTTP 200\nDatos de usuario ausentes',
        );
      }

      return KospiaSession(
        accessToken: accessToken,
        userId: user['id']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
        displayName: user['display_name']?.toString() ?? '',
        photoUrl: user['photo_url']?.toString() ?? '',
      );
    }

    final safeMessage =
        decoded['error']?.toString() ?? 'Error inesperado del backend.';
    throw HttpException(
      'Backend Kospia: ERROR\nHTTP ${response.statusCode}\n$safeMessage',
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    currentAccount = null;
    currentAuthentication = null;
  }

  bool get hasIdToken =>
      currentAuthentication != null &&
      currentAuthentication!.idToken != null &&
      currentAuthentication!.idToken!.isNotEmpty;
}

class HttpException implements Exception {
  const HttpException(this.message);

  final String message;

  @override
  String toString() => message;
}
