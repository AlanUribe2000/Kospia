import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../../core/constants/app_constants.dart';

/// Repositorio de observaciones. Maneja el CRUD de registros de campo.
class ObservationRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ObservationRepository(this._db);

  Future<List<Observation>> getAll() => _db.getAllObservations();

  Future<List<Observation>> getByUser(String userId) =>
      _db.getObservationsByUser(userId);

  Future<List<Observation>> getPending() => _db.getPendingObservations();

  /// Creates a new observation with photo and geolocation data.
  Future<String> create({
    required String userId,
    String? speciesId,
    required String photoPath,
    required double latitude,
    required double longitude,
    double altitude = 0.0,
    double accuracy = 0.0,
    String notes = '',
  }) async {
    final id = _uuid.v4();
    await _db.insertObservation(ObservationsCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: Value(speciesId),
      photoPath: Value(photoPath),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: Value(altitude),
      accuracy: Value(accuracy),
      notes: Value(notes),
      syncStatus: const Value(AppConstants.syncPending),
    ));
    return id;
  }

  /// Marks an observation as synced.
  Future<void> markSynced(String id) async {
    await _db.updateObservation(ObservationsCompanion(
      id: Value(id),
      syncStatus: const Value(AppConstants.syncSynced),
      syncedAt: Value(DateTime.now()),
    ));
  }
}
