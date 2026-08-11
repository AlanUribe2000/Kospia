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

  bool get hasLocation =>
      latitude != null &&
      longitude != null &&
      !latitude!.isNaN &&
      !longitude!.isNaN &&
      !latitude!.isInfinite &&
      !longitude!.isInfinite;
}

/// Pantalla principal del flujo de identificación multi-paso.
/// Paso 1: Captura de fotos por parte
/// Paso 2: Cuestionario secuencial → identificar o "sin identificar"
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
  bool _isUnidentified = false;
  String _unidentifiedNote = '';
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
      _isUnidentified = false;
      _unidentifiedNote = '';
      _isSaving = false;
    });
  }

  void _onPhotosChanged(List<CapturedPhoto> photos) {
    setState(() {
      _photos.clear();
      _photos.addAll(photos);
    });
  }

  void _onSpeciesSelected(Specy? species) {
    setState(() {
      if (species != null) {
        _selectedSpecies = species;
        _isUnidentified = false;
      } else {
        _selectedSpecies = null;
        _isUnidentified = true;
      }
    });
  }

  void _onUnidentifiedNote(String note) {
    setState(() {
      _unidentifiedNote = note;
      _isUnidentified = true;
      _selectedSpecies = null;
    });
  }

  /// Can advance from step 2 if species is selected OR marked as unidentified.
  bool get _canAdvanceFromIdentify =>
      _selectedSpecies != null || _isUnidentified;

  Future<void> _saveObservation() async {
    if (_photos.isEmpty) return;
    if (!_isUnidentified && _selectedSpecies == null) return;

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
        speciesId: _selectedSpecies?.id ?? 'unidentified',
        photos: photoDataList,
        notes: _isUnidentified ? _unidentifiedNote : '',
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
    final title = _isUnidentified
        ? '¡Registro guardado!'
        : '¡Planta registrada!';
    final subtitle = _isUnidentified
        ? 'Se guardó como "sin identificar" con ${_photos.length} foto${_photos.length > 1 ? 's' : ''}'
        : '${_selectedSpecies!.commonName} fue registrada con ${_photos.length} foto${_photos.length > 1 ? 's' : ''}';

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
              height: AppConstants.kospiImageHeight,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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
          // Step content (takes all available space)
          Expanded(child: _buildCurrentStep()),
          // Progress bar at the BOTTOM
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final labels = ['Fotos', 'Planta', 'Ubicación', 'Resumen'];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.surfaceLilac, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == _currentStep;
          final isDone = index < _currentStep;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      width: 22,
                      height: 22,
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
                                size: 12,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 10,
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
                const SizedBox(height: 3),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 9,
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
          onUnidentifiedNote: _onUnidentifiedNote,
          onNext: _canAdvanceFromIdentify ? _nextStep : null,
          onBack: _previousStep,
          photos: _photos,
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
          species: _selectedSpecies,
          isUnidentified: _isUnidentified,
          unidentifiedNote: _unidentifiedNote,
          isSaving: _isSaving,
          onSave: _saveObservation,
          onBack: _previousStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
