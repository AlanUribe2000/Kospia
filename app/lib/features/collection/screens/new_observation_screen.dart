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
import '../../../data/repositories/observation_repository.dart';

/// Pantalla para registrar una nueva observacion con foto y geolocation.
class NewObservationScreen extends StatefulWidget {
  const NewObservationScreen({super.key});

  @override
  State<NewObservationScreen> createState() => _NewObservationScreenState();
}

class _NewObservationScreenState extends State<NewObservationScreen> {
  final _notesController = TextEditingController();
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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // Check permissions
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
                content: Text(
                    'Permiso de ubicacion denegado permanentemente. Habilitalo desde Ajustes.')),
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

    // Save to app documents directory
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
        photoPath: _photo!.path,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        altitude: _position!.altitude,
        accuracy: _position!.accuracy,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Observacion guardada!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Nueva Observacion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo section
            _buildPhotoSection(),
            const SizedBox(height: 24),

            // Location section
            _buildLocationSection(),
            const SizedBox(height: 24),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Describe lo que observas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
                  : const Text('Guardar Observacion'),
            ),
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
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _position != null
                    ? Icons.location_on_rounded
                    : Icons.location_searching_rounded,
                color: _position != null
                    ? AppColors.success
                    : AppColors.warning,
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
                            Text(
                              'Ubicacion obtenida',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Lat: ${_position!.latitude.toStringAsFixed(5)}, '
                              'Lon: ${_position!.longitude.toStringAsFixed(5)}',
                              style: Theme.of(context).textTheme.bodyMedium,
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
