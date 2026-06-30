import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';

/// Pantalla de detalle de una especie.
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
            // Header with icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.local_florist_rounded,
                    color: AppColors.accentGreen, size: 56),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            Center(
              child: Text(species.commonName,
                  style: Theme.of(context).textTheme.displayLarge),
            ),
            Center(
              child: Text(species.scientificName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMedium)),
            ),
            const SizedBox(height: 24),

            // Info chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                    icon: Icons.family_restroom,
                    label: species.family),
                _InfoChip(
                    icon: Icons.landscape_rounded,
                    label: species.habitat),
                if (species.flowerColor.isNotEmpty)
                  _InfoChip(
                      icon: Icons.color_lens_rounded,
                      label: species.flowerColor),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Text('Descripcion',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(species.description,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.accentGreen),
      label: Text(label),
      backgroundColor: AppColors.surfaceLight,
    );
  }
}
