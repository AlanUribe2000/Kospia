import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import '../powersync/attachment_upload_service.dart';
import '../../features/auth/services/session_service.dart';

class ObservationRepository extends ChangeNotifier {
  final PowerSyncDatabase _powerSync;
  final AttachmentUploadService _attachmentUploadService;
  final SessionService _sessionService;
  static const _uuid = Uuid();

  ObservationRepository(
    this._powerSync,
    this._attachmentUploadService,
    this._sessionService,
  );

  Future<List<Observation>> getAll() async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM observations ORDER BY created_at DESC',
    );
    return rows.map(_observationFromPowerSync).toList();
  }

  Future<List<Observation>> getByUser(String userId) async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM observations WHERE user_id = ? ORDER BY created_at DESC',
      [userId],
    );
    return rows.map(_observationFromPowerSync).toList();
  }

  Future<List<Observation>> getBySpecies(String speciesId) async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM observations WHERE species_id = ? ORDER BY created_at DESC',
      [speciesId],
    );
    return rows.map(_observationFromPowerSync).toList();
  }

  Future<List<Observation>> getPending() async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM observations WHERE sync_status = ? ORDER BY created_at ASC',
      [AppConstants.syncPending],
    );
    return rows.map(_observationFromPowerSync).toList();
  }

  Future<List<ObservationPhoto>> getPhotosForObservation(
    String observationId,
  ) async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM observation_photos WHERE observation_id = ? '
      'ORDER BY captured_at ASC',
      [observationId],
    );
    return rows.map(_observationPhotoFromPowerSync).toList();
  }

  /// Observaciones del usuario filtradas por estado de validación,
  /// más recientes primero.
  Future<List<Observation>> getByValidationStatus(
    String userId,
    String status,
  ) async {
    final rows = await _powerSync.getAll(
      'SELECT * FROM observations '
      'WHERE user_id = ? AND validation_status = ? '
      'ORDER BY created_at DESC',
      [userId, status],
    );
    return rows.map(_observationFromPowerSync).toList();
  }

  Future<int> getPendingCount(String userId) =>
      _countByValidationStatus(userId, AppConstants.validationPending);

  Future<int> getRejectedCount(String userId) =>
      _countByValidationStatus(userId, AppConstants.validationRejected);

  /// Cuenta FOTOS del usuario en el estado dado (no observaciones), para que
  /// los chips Pendientes/Rechazadas reflejen la realidad por-foto.
  Future<int> _countByValidationStatus(String userId, String status) async {
    final rows = await _powerSync.getAll(
      'SELECT COUNT(*) AS total FROM observation_photos op '
      'INNER JOIN observations o ON o.id = op.observation_id '
      'WHERE o.user_id = ? AND op.validation_status = ?',
      [userId, status],
    );
    if (rows.isEmpty) return 0;
    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Fotos pendientes del usuario, más recientes primero.
  Future<List<PhotoStatusItem>> getPendingPhotos(String userId) =>
      _photosByValidationStatus(userId, AppConstants.validationPending);

  /// Fotos rechazadas del usuario (su validationComment lleva el motivo).
  Future<List<PhotoStatusItem>> getRejectedPhotos(String userId) =>
      _photosByValidationStatus(userId, AppConstants.validationRejected);

  Future<List<PhotoStatusItem>> _photosByValidationStatus(
    String userId,
    String status,
  ) async {
    final rows = await _powerSync.getAll(
      'SELECT op.*, '
      's.common_name AS species_common_name, '
      's.scientific_name AS species_scientific_name, '
      'o.notes AS observation_notes '
      'FROM observation_photos op '
      'INNER JOIN observations o ON o.id = op.observation_id '
      'LEFT JOIN species s '
      'ON s.id = COALESCE(op.validated_species_id, o.species_id) '
      'WHERE o.user_id = ? AND op.validation_status = ? '
      'ORDER BY op.captured_at DESC',
      [userId, status],
    );
    return rows.map(_photoStatusItemFromPowerSync).toList();
  }

  PhotoStatusItem _photoStatusItemFromPowerSync(Map<String, dynamic> row) {
    final common = row['species_common_name']?.toString();
    final scientific = row['species_scientific_name']?.toString();
    return PhotoStatusItem(
      photo: _observationPhotoFromPowerSync(row),
      speciesCommonName: (common != null && common.isNotEmpty) ? common : null,
      speciesScientificName: (scientific != null && scientific.isNotEmpty)
          ? scientific
          : null,
      observationNotes: row['observation_notes']?.toString() ?? '',
    );
  }

  Future<List<ObservationPhoto>> getAllPhotosForSpecies(
    String speciesId,
  ) async {
    final rows = await _powerSync.getAll(
      'SELECT op.* FROM observation_photos op '
      'INNER JOIN observations o ON o.id = op.observation_id '
      "WHERE op.validation_status = 'validated' "
      'AND COALESCE(op.validated_species_id, o.species_id) = ? '
      'ORDER BY op.captured_at DESC',
      [speciesId],
    );
    return rows.map(_observationPhotoFromPowerSync).toList();
  }

  Future<Set<String>> getPartsForSpecies(String speciesId) async {
    final rows = await _powerSync.getAll(
      'SELECT DISTINCT op.plant_part FROM observation_photos op '
      'INNER JOIN observations o ON o.id = op.observation_id '
      "WHERE op.validation_status = 'validated' "
      'AND COALESCE(op.validated_species_id, o.species_id) = ?',
      [speciesId],
    );
    return rows
        .map((row) => row['plant_part']?.toString() ?? '')
        .where((part) => part.isNotEmpty)
        .toSet();
  }

  Future<Map<String, Set<String>>> getPartsGroupedBySpecies() async {
    final rows = await _powerSync.getAll('''
      SELECT COALESCE(op.validated_species_id, o.species_id) AS species_id,
             op.plant_part
      FROM observation_photos op
      INNER JOIN observations o ON o.id = op.observation_id
      WHERE op.validation_status = 'validated'
        AND COALESCE(op.validated_species_id, o.species_id) != 'unidentified'
      GROUP BY COALESCE(op.validated_species_id, o.species_id), op.plant_part
    ''');

    final partsBySpecies = <String, Set<String>>{};
    for (final row in rows) {
      final speciesId = row['species_id']?.toString() ?? '';
      final plantPart = row['plant_part']?.toString() ?? '';
      if (speciesId.isEmpty || plantPart.isEmpty) continue;
      partsBySpecies.putIfAbsent(speciesId, () => <String>{}).add(plantPart);
    }
    return partsBySpecies;
  }

  Future<double> getProgressForSpecies(String speciesId) async {
    final parts = await getPartsForSpecies(speciesId);
    return parts.length / 5.0;
  }

  Future<String> createWithPhotos({
    required String speciesId,
    required List<PhotoData> photos,
    String notes = '',
  }) async {
    final session = await _sessionService.loadSession();
    if (session == null) {
      throw StateError(
        'Se requiere una sesión Kospia válida para crear una observación.',
      );
    }

    final observationId = _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();

    await _powerSync.execute(
      '''
      INSERT INTO observations
        (id, user_id, species_id, notes, sync_status, created_at, updated_at, synced_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        observationId,
        session.userId,
        speciesId,
        notes,
        AppConstants.syncPending,
        now,
        now,
        null,
      ],
    );

    for (final photo in photos) {
      final photoId = _uuid.v4();
      final extension = _fileExtension(photo.path);

      await _powerSync.execute(
        '''
        INSERT INTO observation_photos
          (id, observation_id, photo_path, plant_part, latitude, longitude,
           altitude, accuracy, source, sync_status, captured_at, file_extension)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          photoId,
          observationId,
          photo.path,
          photo.plantPart,
          photo.latitude,
          photo.longitude,
          photo.altitude,
          photo.accuracy,
          photo.source,
          AppConstants.syncPending,
          (photo.capturedAt ?? DateTime.now()).toUtc().toIso8601String(),
          extension,
        ],
      );

      await _powerSync.execute(
        '''
        INSERT INTO attachments_queue
          (id, photo_id, local_path, extension, status, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
      ''',
        [_uuid.v4(), photoId, photo.path, extension, 'pending', now],
      );
    }

    notifyListeners();
    _attachmentUploadService.uploadPending().catchError((error) {
      debugPrint('Attachments: quedan pendientes para reintento: $error');
    });
    return observationId;
  }

  Future<void> markSynced(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _powerSync.execute(
      '''
      UPDATE observations
      SET sync_status = ?, synced_at = ?, updated_at = ?
      WHERE id = ?
    ''',
      [AppConstants.syncSynced, now, now, id],
    );
    notifyListeners();
  }

  void refresh() => notifyListeners();

  Observation _observationFromPowerSync(Map<String, dynamic> row) =>
      Observation(
        id: row['id']?.toString() ?? '',
        userId: row['user_id']?.toString() ?? '',
        speciesId: row['species_id']?.toString() ?? '',
        notes: row['notes']?.toString() ?? '',
        syncStatus: row['sync_status']?.toString() ?? AppConstants.syncPending,
        validationStatus:
            row['validation_status']?.toString() ??
            AppConstants.validationPending,
        validatedSpeciesId: row['validated_species_id']?.toString(),
        rejectionReason: row['rejection_reason']?.toString(),
        createdAt: _parseDate(row['created_at']),
        updatedAt: _parseDate(row['updated_at']),
        syncedAt: _parseNullableDate(row['synced_at']),
      );

  ObservationPhoto _observationPhotoFromPowerSync(Map<String, dynamic> row) =>
      ObservationPhoto(
        id: row['id']?.toString() ?? '',
        observationId: row['observation_id']?.toString() ?? '',
        photoPath: row['photo_path']?.toString() ?? '',
        plantPart: row['plant_part']?.toString() ?? 'general',
        latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
        altitude: (row['altitude'] as num?)?.toDouble() ?? 0.0,
        accuracy: (row['accuracy'] as num?)?.toDouble() ?? 0.0,
        source: row['source']?.toString() ?? 'camera',
        syncStatus: row['sync_status']?.toString() ?? AppConstants.syncPending,
        capturedAt: _parseDate(row['captured_at']),
        validationStatus:
            row['validation_status']?.toString() ??
            AppConstants.validationPending,
        validationComment: row['validation_comment']?.toString(),
        validatedSpeciesId: row['validated_species_id']?.toString(),
        validatedAt: _parseNullableDate(row['validated_at']),
        validatedBy: row['validated_by']?.toString(),
      );

  DateTime _parseDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? _parseNullableDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  String _fileExtension(String path) {
    final fileName = path.split(RegExp(r'[\\/]')).last;
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return 'jpg';
    return fileName.substring(dot + 1).toLowerCase();
  }
}

/// Foto en estado pendiente/rechazada enriquecida con la especie a la que
/// pertenece (resuelta desde la observación) y las notas de la observación.
/// Si no hay especie elegida (caso "sin identificar"), [speciesCommonName]
/// queda en null y [observationNotes] lleva la descripción escrita por el
/// usuario.
class PhotoStatusItem {
  final ObservationPhoto photo;
  final String? speciesCommonName;
  final String? speciesScientificName;
  final String observationNotes;

  const PhotoStatusItem({
    required this.photo,
    this.speciesCommonName,
    this.speciesScientificName,
    this.observationNotes = '',
  });
}

class PhotoData {
  final String path;
  final String plantPart;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final String source;
  final DateTime? capturedAt;

  const PhotoData({
    required this.path,
    this.plantPart = 'general',
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    this.accuracy = 0.0,
    this.source = 'camera',
    this.capturedAt,
  });

  PhotoData copyWith({
    String? path,
    String? plantPart,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    String? source,
    DateTime? capturedAt,
  }) => PhotoData(
    path: path ?? this.path,
    plantPart: plantPart ?? this.plantPart,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude ?? this.altitude,
    accuracy: accuracy ?? this.accuracy,
    source: source ?? this.source,
    capturedAt: capturedAt ?? this.capturedAt,
  );
}
