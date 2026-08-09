import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/species_images.dart';
import '../../../data/database/app_database.dart';
import '../screens/identify_flow_screen.dart';

/// Paso 4: Resumen y guardar.
class StepSummary extends StatelessWidget {
  final List<CapturedPhoto> photos;
  final Specy species;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onBack;

  const StepSummary({
    super.key,
    required this.photos,
    required this.species,
    required this.isSaving,
    required this.onSave,
    required this.onBack,
  });

  String _partLabel(String part) {
    switch (part) {
      case 'general':
        return 'General';
      case 'hoja':
        return 'Hoja';
      case 'flor':
        return 'Flor';
      case 'tallo':
        return 'Tallo';
      case 'fruto':
        return 'Fruto';
      default:
        return part;
    }
  }

  @override
  Widget build(BuildContext context) {
    final speciesImg = SpeciesImages.getFirstImage(species.scientificName);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.asset(
            'assets/images/Kospi/Kospi saludando.png',
            height: 70,
            errorBuilder: (_, __, ___) => const SizedBox(height: 70),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Todo listo para guardar!',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Species card
          Card(
            color: AppColors.accentGreen.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: speciesImg != null
                        ? Image.asset(
                            speciesImg,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreenLight.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.local_florist_rounded,
                              color: AppColors.accentGreen,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.commonName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          species.scientificName,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Photos summary
          Expanded(
            child: ListView.separated(
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photo.path),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _partLabel(photo.plantPart),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Lat: ${photo.latitude?.toStringAsFixed(4)}, '
                            'Lon: ${photo.longitude?.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onBack,
                  child: const Text('Atrás', maxLines: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar registro'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
