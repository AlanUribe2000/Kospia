import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import '../powersync/attachment_upload_service.dart';

class ObservationRepository extends ChangeNotifier {
  final PowerSyncDatabase _powerSync;
  final AttachmentUploadService _attachmentUploadService;
  static const _uuid = Uuid();

  ObservationRepository(this._powerSync, this._attachmentUploadService);

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

  Future<List<ObservationPhoto>> getAllPhotosForSpecies(
    String speciesId,
  ) async {
    final rows = await _powerSync.getAll(
      'SELECT op.* FROM observation_photos op '
      'INNER JOIN observations o ON o.id = op.observation_id '
      'WHERE o.species_id = ? ORDER BY op.captured_at DESC',
      [speciesId],
    );
    return rows.map(_observationPhotoFromPowerSync).toList();
  }

  Future<Set<String>> getPartsForSpecies(String speciesId) async {
    final rows = await _powerSync.getAll(
      'SELECT DISTINCT op.plant_part FROM observation_photos op '
      'INNER JOIN observations o ON o.id = op.observation_id '
      'WHERE o.species_id = ?',
      [speciesId],
    );
    return rows
        .map((row) => row['plant_part']?.toString() ?? '')
        .where((part) => part.isNotEmpty)
        .toSet();
  }

  Future<Map<String, Set<String>>> getPartsGroupedBySpecies() async {
    final rows = await _powerSync.getAll('''
      SELECT o.species_id, op.plant_part
      FROM observation_photos op
      INNER JOIN observations o ON o.id = op.observation_id
      WHERE o.species_id != 'unidentified'
      GROUP BY o.species_id, op.plant_part
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
    required String userId,
    required String speciesId,
    required List<PhotoData> photos,
    String notes = '',
  }) async {
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
        userId,
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
