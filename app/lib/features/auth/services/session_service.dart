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
    if (!_hasRequiredUserData(session) ||
        !_hasFutureExpiration(session.accessToken, session.userId)) {
      throw const FormatException('Sesión Kospia inválida o expirada.');
    }

    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _userIdKey, value: session.userId);
    await _writeOrDelete(_emailKey, session.email);
    await _writeOrDelete(_displayNameKey, session.displayName);
    await _writeOrDelete(_photoUrlKey, session.photoUrl);
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

    if (!_hasRequiredUserData(session) ||
        !_hasFutureExpiration(session.accessToken, session.userId)) {
      if (values.isNotEmpty) {
        await clearSession();
      }
      return null;
    }

    return session;
  }

  Future<void> clearSession() async {
    for (final key in [
      _accessTokenKey,
      _userIdKey,
      _emailKey,
      _displayNameKey,
      _photoUrlKey,
    ]) {
      await _storage.delete(key: key);
    }
  }

  Future<void> _writeOrDelete(String key, String value) async {
    if (value.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  bool _hasRequiredUserData(KospiaSession session) {
    return session.accessToken.isNotEmpty &&
        session.userId.isNotEmpty &&
        _isUuid(session.userId);
  }

  bool _hasFutureExpiration(String token, String userId) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) {
        return false;
      }

      if (payload['sub']?.toString() != userId) {
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
