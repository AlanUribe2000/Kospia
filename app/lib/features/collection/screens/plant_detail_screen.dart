import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';

/// Pantalla de detalle de una planta desbloqueada.
/// Muestra la foto tomada, información de la especie y un mapa con la ubicación.
class PlantDetailScreen extends StatelessWidget {
  final Specy species;
  final Observation observation;

  const PlantDetailScreen({
    super.key,
    required this.species,
    required this.observation,
  });

  void _showFullPhoto(BuildContext context, File photoFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullPhotoScreen(
          photoFile: photoFile,
          heroTag: 'plant-photo-${observation.id}',
        ),
      ),
    );
  }

  void _openFullMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullMapScreen(
          latitude: observation.latitude,
          longitude: observation.longitude,
          speciesName: species.commonName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final photoFile = File(observation.photoPath);
    final hasPhoto = photoFile.existsSync();

    return Scaffold(
      appBar: AppBar(title: Text(species.commonName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo - tap to expand
            if (hasPhoto)
              GestureDetector(
                onTap: () => _showFullPhoto(context, photoFile),
                child: Hero(
                  tag: 'plant-photo-${observation.id}',
                  child: Image.file(
                    photoFile,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: AppColors.surfaceLilac,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: AppColors.textLight,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Species name
                  Text(
                    species.commonName,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    species.scientificName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.family_restroom,
                        label: species.family,
                      ),
                      _InfoChip(
                        icon: Icons.landscape_rounded,
                        label: species.habitat,
                      ),
                      if (species.flowerColor.isNotEmpty)
                        _InfoChip(
                          icon: Icons.color_lens_rounded,
                          label: species.flowerColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    species.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Observation details
                  Text(
                    'Registro',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),

                  // Date
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Fecha',
                    value: dateFormat.format(observation.capturedAt),
                  ),
                  const SizedBox(height: 10),

                  // Location map placeholder
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Ubicacion',
                    value:
                        'Lat: ${observation.latitude.toStringAsFixed(5)}, Lon: ${observation.longitude.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 16),

                  // Map (tap to expand fullscreen)
                  GestureDetector(
                    onTap: () => _openFullMap(context),
                    child: Stack(
                      children: [
                        _buildMap(),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 20,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    final point = LatLng(observation.latitude, observation.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kospia.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accentGreen),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
        ),
      ],
    );
  }
}

/// Pantalla de foto en pantalla completa con pinch-to-zoom.
class _FullPhotoScreen extends StatelessWidget {
  final File photoFile;
  final String heroTag;

  const _FullPhotoScreen({required this.photoFile, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(photoFile, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de mapa en pantalla completa con zoom libre.
class _FullMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String speciesName;

  const _FullMapScreen({
    required this.latitude,
    required this.longitude,
    required this.speciesName,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(title: Text('Ubicación - $speciesName')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 15,
          minZoom: 3,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.kospia.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 24,
                height: 24,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentOrange.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
