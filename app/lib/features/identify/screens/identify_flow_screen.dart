import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/observation_repository.dart';
import '../widgets/step_location.dart';
import '../widgets/step_photos.dart';
import '../widgets/step_identify.dart';
import '../widgets/step_summary.dart';

/// Datos temporales de una foto durante el flujo de identificación.
class CapturedPhoto {
  final String path;
  final String source; // 'camera' or 'gallery'
  String plantPart;
  double? latitude;
  double? longitude;
  double altitude;
  double accuracy;
  DateTime capturedAt;

  CapturedPhoto({
    required this.path,
    required this.source,
    this.plantPart = 'general',
    this.latitude,
    this.longitude,
    this.altitude = 0.0,
    this.accuracy = 0.0,
    DateTime? capturedAt,
  }) : capturedAt = capturedAt ?? DateTime.now();

  bool get hasLocation => latitude != null && longitude != null;
}

/// Pantalla principal del flujo de identificación multi-paso.
/// Paso 1: Captura de fotos
/// Paso 2: Identificar la planta (catálogo o cuestionario)
/// Paso 3: Ubicación geográfica por foto
/// Paso 4: Resumen y guardar
class IdentifyFlowScreen extends StatefulWidget {
  const IdentifyFlowScreen({super.key});

  @override
  State<IdentifyFlowScreen> createState() => _IdentifyFlowScreenState();
}

class _IdentifyFlowScreenState extends State<IdentifyFlowScreen> {
  int _currentStep = 0;
  final List<CapturedPhoto> _photos = [];
  Specy? _selectedSpecies;
  bool _isSaving = false;

  static const _stepCount = 4;

  void _nextStep() {
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _photos.clear();
      _selectedSpecies = null;
      _isSaving = false;
    });
  }

  void _onPhotosChanged(List<CapturedPhoto> photos) {
    setState(() {
      _photos.clear();
      _photos.addAll(photos);
    });
  }

  void _onSpeciesSelected(Specy species) {
    setState(() => _selectedSpecies = species);
  }

  Future<void> _saveObservation() async {
    if (_selectedSpecies == null || _photos.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final repo = context.read<ObservationRepository>();
      final photoDataList = _photos.map((photo) {
        return PhotoData(
          path: photo.path,
          plantPart: photo.plantPart,
          latitude: photo.latitude ?? 0.0,
          longitude: photo.longitude ?? 0.0,
          altitude: photo.altitude,
          accuracy: photo.accuracy,
          source: photo.source,
          capturedAt: photo.capturedAt,
        );
      }).toList();

      await repo.createWithPhotos(
        userId: AppConstants.testUserId,
        speciesId: _selectedSpecies!.id,
        photos: photoDataList,
      );

      if (mounted) {
        await _showSuccessDialog();
        _reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error guardando: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.backgroundLilac,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/Kospi/Kospi saludando.png',
              height: 100,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Registro guardado!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedSpecies!.commonName} fue registrada '
              'con ${_photos.length} foto${_photos.length > 1 ? 's' : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMedium),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),
          // Step content
          Expanded(child: _buildCurrentStep()),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final labels = ['Fotos', 'Planta', 'Ubicación', 'Resumen'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == _currentStep;
          final isDone = index < _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone || isActive
                              ? AppColors.accentGreen
                              : AppColors.surfaceLilac,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.accentGreen
                            : isActive
                            ? AppColors.accentGreenLight
                            : AppColors.surfaceLilac,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textLight,
                                ),
                              ),
                      ),
                    ),
                    if (index < labels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone
                              ? AppColors.accentGreen
                              : AppColors.surfaceLilac,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive || isDone
                        ? AppColors.accentGreen
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return StepPhotos(
          photos: _photos,
          onPhotosChanged: _onPhotosChanged,
          onNext: _photos.isNotEmpty ? _nextStep : null,
        );
      case 1:
        return StepIdentify(
          selectedSpecies: _selectedSpecies,
          onSpeciesSelected: _onSpeciesSelected,
          onNext: _selectedSpecies != null ? _nextStep : null,
          onBack: _previousStep,
          photoPaths: _photos.map((p) => p.path).toList(),
        );
      case 2:
        return StepLocation(
          photos: _photos,
          onPhotosChanged: _onPhotosChanged,
          onNext: _photos.every((p) => p.hasLocation) ? _nextStep : null,
          onBack: _previousStep,
        );
      case 3:
        return StepSummary(
          photos: _photos,
          species: _selectedSpecies!,
          isSaving: _isSaving,
          onSave: _saveObservation,
          onBack: _previousStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
