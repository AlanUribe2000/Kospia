import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:powersync/powersync.dart';

import 'powersync_config.dart';

class KospiaBackendConnector extends PowerSyncBackendConnector {
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final response = await http.get(
      Uri.parse('${PowerSyncConfig.backendUrl}${PowerSyncConfig.tokenPath}'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo obtener el JWT de PowerSync. '
        'HTTP ${response.statusCode}: ${response.body}',
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
    final response = await http.post(
      Uri.parse('${PowerSyncConfig.backendUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error subiendo $path. '
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }
}
