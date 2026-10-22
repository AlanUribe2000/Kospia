import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:powersync/powersync.dart';

import '../../features/auth/services/session_service.dart';
import '../powersync/powersync_config.dart';

/// Notificación de validación tal como la ve la UI (lectura local).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.observationId,
    required this.type,
    required this.title,
    required this.body,
    required this.oldSpeciesId,
    required this.oldSpeciesName,
    required this.newSpeciesId,
    required this.newSpeciesName,
    required this.readAt,
    required this.createdAt,
  });

  final String id;
  final String observationId;
  final String type;
  final String title;
  final String body;
  final String? oldSpeciesId;
  final String? oldSpeciesName;
  final String? newSpeciesId;
  final String? newSpeciesName;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;
}

/// Repositorio de notificaciones. SOLO lee la tabla local `notifications`
/// (que baja por PowerSync); NUNCA la escribe en SQLite. El estado de lectura
/// se cambia por REST (`PATCH /notifications/{id}/read`) y vuelve a bajar por
/// PowerSync. Ver la invariante en backend_connector.dart.
class NotificationRepository extends ChangeNotifier {
  NotificationRepository(this._powerSync, this._sessionService) {
    _watchForChanges();
  }

  final PowerSyncDatabase _powerSync;
  final SessionService _sessionService;
  StreamSubscription<void>? _subscription;

  void _watchForChanges() {
    // Dispara notifyListeners() cuando PowerSync empuja filas nuevas o cambios
    // de read_at. La UI nunca ve este Stream directamente.
    _subscription = _powerSync
        .watch(
          'SELECT id FROM notifications',
          triggerOnTables: {'notifications'},
        )
        .listen((_) => notifyListeners());
  }

  Future<List<NotificationItem>> getAll() async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM notifications ORDER BY created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<int> getUnreadCount() async {
    final rows = await _powerSync.getAll(
      'SELECT COUNT(*) AS total FROM notifications WHERE read_at IS NULL',
    );
    if (rows.isEmpty) return 0;
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Marca una notificación como leída vía REST. NO toca SQLite local.
  Future<void> markAsRead(String id) async {
    final session = await _sessionService.loadSession();
    if (session == null) {
      throw StateError(
        'No hay una sesión Kospia válida para marcar notificaciones.',
      );
    }

    final response = await http.patch(
      Uri.parse('${PowerSyncConfig.backendUrl}/notifications/$id/read'),
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'No se pudo marcar la notificación como leída. '
        'HTTP ${response.statusCode}',
      );
    }

    notifyListeners();
  }

  NotificationItem _fromRow(Map<String, dynamic> row) => NotificationItem(
    id: row['id']?.toString() ?? '',
    observationId: row['observation_id']?.toString() ?? '',
    type: row['type']?.toString() ?? '',
    title: row['title']?.toString() ?? '',
    body: row['body']?.toString() ?? '',
    oldSpeciesId: row['old_species_id']?.toString(),
    oldSpeciesName: row['old_species_name']?.toString(),
    newSpeciesId: row['new_species_id']?.toString(),
    newSpeciesName: row['new_species_name']?.toString(),
    readAt: _parseNullableDate(row['read_at']),
    createdAt:
        DateTime.tryParse(row['created_at']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  DateTime? _parseNullableDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
