import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KospiaSession {
  const KospiaSession({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  final String accessToken;
  final String userId;
  final String email;
  final String displayName;
  final String photoUrl;
}

class SessionService {
  SessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'kospia.access_token';
  static const _userIdKey = 'kospia.user.id';
  static const _emailKey = 'kospia.user.email';
  static const _displayNameKey = 'kospia.user.display_name';
  static const _photoUrlKey = 'kospia.user.photo_url';

  final FlutterSecureStorage _storage;

  Future<void> saveSession(KospiaSession session) async {
    if (!_hasRequiredUserData(session) || !_hasFutureExpiration(session.accessToken)) {
      throw const FormatException('Sesión Kospia inválida o expirada.');
    }

    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _userIdKey, value: session.userId);
    await _storage.write(key: _emailKey, value: session.email);
    await _storage.write(key: _displayNameKey, value: session.displayName);
    await _storage.write(key: _photoUrlKey, value: session.photoUrl);
  }

  Future<KospiaSession?> loadSession() async {
    final values = await _storage.readAll();
    final session = KospiaSession(
      accessToken: values[_accessTokenKey] ?? '',
      userId: values[_userIdKey] ?? '',
      email: values[_emailKey] ?? '',
      displayName: values[_displayNameKey] ?? '',
      photoUrl: values[_photoUrlKey] ?? '',
    );

    if (!_hasRequiredUserData(session) || !_hasFutureExpiration(session.accessToken)) {
      if (values.isNotEmpty) {
        await clearSession();
      }
      return null;
    }

    return session;
  }

  Future<void> clearSession() => _storage.deleteAll();

  bool _hasRequiredUserData(KospiaSession session) {
    return session.accessToken.isNotEmpty &&
        session.userId.isNotEmpty &&
        session.email.isNotEmpty &&
        session.displayName.isNotEmpty &&
        session.photoUrl.isNotEmpty;
  }

  bool _hasFutureExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      if (payload is! Map<String, dynamic>) {
        return false;
      }

      final expiration = payload['exp'];
      if (expiration is! num) {
        return false;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        (expiration * 1000).toInt(),
        isUtc: true,
      );
      return expirationTime.isAfter(DateTime.now().toUtc());
    } on Object {
      return false;
    }
  }
}
