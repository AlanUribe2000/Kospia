import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/observation_repository.dart';

/// Pantalla de captura de foto después de confirmar la especie identificada.
/// Flujo: tomar foto → obtener ubicación → guardar observación con especie.
class CaptureObservationScreen extends StatefulWidget {
  final Specy species;

  const CaptureObservationScreen({super.key, required this.species});

  @override
  State<CaptureObservationScreen> createState() =>
      _CaptureObservationScreenState();
}

class _CaptureObservationScreenState extends State<CaptureObservationScreen> {
  final _picker = ImagePicker();

  File? _photo;
  Position? _position;
  bool _isLoadingLocation = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de ubicacion denegado')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Permiso de ubicacion denegado permanentemente')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (mounted) setState(() => _position = position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error obteniendo ubicacion: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'observations'));
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    final fileName = '${const Uuid().v4()}.jpg';
    final savedFile = await File(image.path).copy(
      p.join(photosDir.path, fileName),
    );

    if (mounted) setState(() => _photo = savedFile);
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'observations'));
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    final fileName = '${const Uuid().v4()}.jpg';
    final savedFile = await File(image.path).copy(
      p.join(photosDir.path, fileName),
    );

    if (mounted) setState(() => _photo = savedFile);
  }

  Future<void> _saveObservation() async {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toma una foto primero')),
      );
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esperando ubicacion...')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = context.read<ObservationRepository>();
      await repo.create(
        userId: AppConstants.testUserId,
        speciesId: widget.species.id,
        photoPath: _photo!.path,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        altitude: _position!.altitude,
        accuracy: _position!.accuracy,
      );

      if (mounted) {
        // Show success and go back to home
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _SuccessDialog(species: widget.species),
        );
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar ${widget.species.commonName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Species info card
            _buildSpeciesCard(),
            const SizedBox(height: 24),

            // Photo section
            _buildPhotoSection(),
            const SizedBox(height: 24),

            // Location section
            _buildLocationSection(),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveObservation,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('¡Desbloquear esta planta!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesCard() {
    return Card(
      color: AppColors.accentGreen.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentGreenLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_florist_rounded,
                  color: AppColors.accentGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.species.commonName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(widget.species.scientificName,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: AppColors.textMedium)),
                ],
              ),
            ),
            const Icon(Icons.check_circle_rounded,
                color: AppColors.accentGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    if (_photo != null) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _photo!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.refresh),
            label: const Text('Tomar otra foto'),
          ),
        ],
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceLilac,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLilac, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_rounded,
              size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          const Text('Saca una foto de la planta',
              style: TextStyle(color: AppColors.textMedium)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camara'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Galeria'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _position != null
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _position != null
                    ? Icons.location_on_rounded
                    : Icons.location_searching_rounded,
                color:
                    _position != null ? AppColors.success : AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoadingLocation
                  ? const Text('Obteniendo ubicacion...')
                  : _position != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ubicacion obtenida',
                                style:
                                    Theme.of(context).textTheme.titleLarge),
                            Text(
                              'Lat: ${_position!.latitude.toStringAsFixed(5)}, '
                              'Lon: ${_position!.longitude.toStringAsFixed(5)}',
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        )
                      : const Text('Sin ubicacion'),
            ),
            if (!_isLoadingLocation && _position == null)
              IconButton(
                onPressed: _getLocation,
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog de éxito tras guardar la observación.
class _SuccessDialog extends StatelessWidget {
  final Specy species;

  const _SuccessDialog({required this.species});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.backgroundLilac,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 40, color: AppColors.success),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Planta desbloqueada!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${species.commonName} fue registrada exitosamente',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMedium),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver al inicio'),
            ),
          ),
        ],
      ),
    );
  }
}
