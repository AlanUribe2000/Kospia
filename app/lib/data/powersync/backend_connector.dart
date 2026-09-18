import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:powersync/powersync.dart';

import '../../features/auth/services/session_service.dart';
import 'powersync_config.dart';

class KospiaBackendConnector extends PowerSyncBackendConnector {
  KospiaBackendConnector(this._sessionService);

  final SessionService _sessionService;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = await _sessionService.loadSession();
    if (session == null) {
      throw StateError(
        'No hay una sesión Kospia válida para obtener credenciales de PowerSync.',
      );
    }

    final response = await http.get(
      Uri.parse('${PowerSyncConfig.backendUrl}${PowerSyncConfig.tokenPath}'),
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo obtener el JWT de PowerSync. '
        'HTTP ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = json['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('El endpoint JWT no devolvio el campo "token".');
    }

    return PowerSyncCredentials(
      endpoint: json['endpoint']?.toString() ?? PowerSyncConfig.powerSyncUrl,
      token: token,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    for (final operation in transaction.crud) {
      if (operation.op != UpdateType.put) {
        throw StateError(
          'Operacion PowerSync no soportada: '
          '${operation.op} sobre ${operation.table}',
        );
      }

      final data = Map<String, dynamic>.from(operation.opData ?? {})
        ..['id'] = operation.id;

      switch (operation.table) {
        case 'observations':
          await _postJson('/observations', data);
        case 'observation_photos':
          await _postJson('/observation-photos', data);
        default:
          throw StateError(
            'Tabla PowerSync no soportada para upload: ${operation.table}',
          );
      }
    }

    await transaction.complete();
  }

  Future<void> _postJson(String path, Map<String, dynamic> data) async {
    final session = await _sessionService.loadSession();
    if (session == null) {
      throw StateError(
        'No hay una sesión Kospia válida para sincronizar datos.',
      );
    }

    final response = await http.post(
      Uri.parse('${PowerSyncConfig.backendUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Error seguro subiendo $path. HTTP ${response.statusCode}',
      );
    }
  }
}
