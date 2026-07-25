import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';

/// Pantalla de detalle de una especie con información completa.
class SpeciesDetailScreen extends StatelessWidget {
  final Specy species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(species.commonName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: AppColors.accentGreen,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                species.commonName,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            Center(
              child: Text(
                species.scientificName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            if (species.family.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    species.family,
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Quick tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (species.biologicalForm.isNotEmpty)
                  _TagChip(species.biologicalForm, Icons.eco_rounded),
                if (species.approximateHeight.isNotEmpty)
                  _TagChip(
                    'Altura: ${species.approximateHeight}',
                    Icons.height_rounded,
                  ),
                if (species.flowerColor.isNotEmpty)
                  _TagChip(
                    'Flor: ${species.flowerColor}',
                    Icons.color_lens_rounded,
                  ),
                if (species.hasSpines)
                  _TagChip('Con espinas', Icons.warning_amber_rounded),
                if (species.hasFruit)
                  _TagChip('Fruto visible', Icons.spa_rounded),
              ],
            ),
            const SizedBox(height: 24),

            // Descripción
            if (species.description.isNotEmpty) ...[
              _SectionTitle('Descripción'),
              const SizedBox(height: 8),
              Text(
                species.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
            ],

            // Características generales
            _SectionTitle('Características generales'),
            const SizedBox(height: 10),
            _DetailCard(
              children: [
                if (species.biologicalForm.isNotEmpty)
                  _DetailRow('Forma biológica', species.biologicalForm),
                if (species.approximateHeight.isNotEmpty)
                  _DetailRow(
                    'Altura aproximada',
                    _formatHeight(species.approximateHeight),
                  ),
                if (species.observations.isNotEmpty)
                  _DetailRow('Observaciones', species.observations),
              ],
            ),
            const SizedBox(height: 16),

            // Hojas
            _SectionTitle('Hojas'),
            const SizedBox(height: 10),
            _DetailCard(
              children: [
                if (species.leafShape.isNotEmpty)
                  _DetailRow('Forma', species.leafShape),
                if (species.leafLength.isNotEmpty)
                  _DetailRow('Tamaño', species.leafLength),
                if (species.leafEdge.isNotEmpty)
                  _DetailRow('Borde', species.leafEdge),
                if (species.leafTexture.isNotEmpty)
                  _DetailRow('Textura', species.leafTexture),
              ],
            ),
            const SizedBox(height: 16),

            // Flor
            _SectionTitle('Flor'),
            const SizedBox(height: 10),
            _DetailCard(
              children: [
                if (species.flowerColor.isNotEmpty)
                  _DetailRow('Color', species.flowerColor),
                if (species.flowerGrouping.isNotEmpty)
                  _DetailRow('Agrupación', species.flowerGrouping),
                if (species.petalCount.isNotEmpty)
                  _DetailRow('Pétalos', species.petalCount),
                if (species.flowerSize.isNotEmpty)
                  _DetailRow('Tamaño', species.flowerSize),
              ],
            ),
            const SizedBox(height: 16),

            // Espinas
            if (species.hasSpines) ...[
              _SectionTitle('Espinas'),
              const SizedBox(height: 10),
              _DetailCard(
                children: [
                  _DetailRow('Tiene espinas', 'Sí'),
                  if (species.spineType.isNotEmpty)
                    _DetailRow('Tipo', species.spineType),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Fruto
            if (species.hasFruit) ...[
              _SectionTitle('Fruto'),
              const SizedBox(height: 10),
              _DetailCard(
                children: [
                  if (species.fruitShape.isNotEmpty)
                    _DetailRow('Forma', species.fruitShape),
                  if (species.fruitColor.isNotEmpty)
                    _DetailRow('Color', species.fruitColor),
                  if (species.fruitSize.isNotEmpty)
                    _DetailRow('Tamaño', species.fruitSize),
                ],
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatHeight(String height) {
    switch (height) {
      case 'muy baja':
        return 'Muy baja (< 30 cm)';
      case 'baja':
        return 'Baja (30–60 cm)';
      case 'media':
        return 'Media (60 cm – 1 m)';
      case 'alta':
        return 'Alta (1 m – 2 m)';
      case 'muy alta':
        return 'Muy alta (≥ 2 m)';
      default:
        return height;
    }
  }
}

// --- Widgets auxiliares ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    // Filter out empty-looking widgets
    final validChildren = children.whereType<Widget>().toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLilac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: validChildren),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _TagChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGreenLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentGreen),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.accentGreen),
          ),
        ],
      ),
    );
  }
}
