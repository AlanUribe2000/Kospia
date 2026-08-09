import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../../core/constants/app_constants.dart';

/// Repositorio de observaciones. Maneja el CRUD de registros de campo.
/// Extiende ChangeNotifier para notificar a listeners cuando hay cambios.
class ObservationRepository extends ChangeNotifier {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ObservationRepository(this._db);

  Future<List<Observation>> getAll() => _db.getAllObservations();

  Future<List<Observation>> getByUser(String userId) =>
      _db.getObservationsByUser(userId);

  Future<List<Observation>> getBySpecies(String speciesId) =>
      _db.getObservationsBySpecies(speciesId);

  Future<List<Observation>> getPending() => _db.getPendingObservations();

  Future<List<ObservationPhoto>> getPhotosForObservation(
    String observationId,
  ) => _db.getPhotosForObservation(observationId);

  Future<List<ObservationPhoto>> getAllPhotosForSpecies(String speciesId) =>
      _db.getAllPhotosForSpecies(speciesId);

  /// Returns distinct plant parts photographed for a given species.
  Future<Set<String>> getPartsForSpecies(String speciesId) =>
      _db.getPartsForSpecies(speciesId);

  /// Calcula el progreso de una especie (0.0 a 1.0).
  /// 5 partes posibles: general, hoja, flor, tallo, fruto.
  Future<double> getProgressForSpecies(String speciesId) async {
    final parts = await getPartsForSpecies(speciesId);
    return parts.length / 5.0;
  }

  /// Creates a new observation with multiple photos.
  /// Each photo has its own plant part, location, and source.
  /// Notifies listeners after creation.
  Future<String> createWithPhotos({
    required String userId,
    required String speciesId,
    required List<PhotoData> photos,
    String notes = '',
  }) async {
    final observationId = _uuid.v4();

    await _db.insertObservation(
      ObservationsCompanion(
        id: Value(observationId),
        userId: Value(userId),
        speciesId: Value(speciesId),
        notes: Value(notes),
        syncStatus: const Value(AppConstants.syncPending),
      ),
    );

    final photoEntries = photos.map((photo) {
      return ObservationPhotosCompanion(
        id: Value(_uuid.v4()),
        observationId: Value(observationId),
        photoPath: Value(photo.path),
        plantPart: Value(photo.plantPart),
        latitude: Value(photo.latitude),
        longitude: Value(photo.longitude),
        altitude: Value(photo.altitude),
        accuracy: Value(photo.accuracy),
        source: Value(photo.source),
        syncStatus: const Value(AppConstants.syncPending),
        capturedAt: Value(photo.capturedAt ?? DateTime.now()),
      );
    }).toList();

    await _db.insertObservationPhotos(photoEntries);

    notifyListeners();
    return observationId;
  }

  /// Marks an observation as synced.
  Future<void> markSynced(String id) async {
    await _db.updateObservation(
      ObservationsCompanion(
        id: Value(id),
        syncStatus: const Value(AppConstants.syncSynced),
        syncedAt: Value(DateTime.now()),
      ),
    );
    notifyListeners();
  }

  /// Notifies listeners to force a refresh (e.g. after DB reset).
  void refresh() {
    notifyListeners();
  }
}

/// Datos temporales de una foto antes de persistir.
class PhotoData {
  final String path;
  final String plantPart;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final String source; // 'camera' or 'gallery'
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
  }) {
    return PhotoData(
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
}
