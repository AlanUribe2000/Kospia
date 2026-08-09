import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';

/// Pantalla de detalle de una planta desbloqueada.
/// Muestra las fotos tomadas, información de la especie y un mapa.
class PlantDetailScreen extends StatelessWidget {
  final Specy species;
  final List<ObservationPhoto> photos;

  const PlantDetailScreen({
    super.key,
    required this.species,
    required this.photos,
  });

  void _showFullPhoto(BuildContext context, File photoFile) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullPhotoScreen(photoFile: photoFile)),
    );
  }

  void _openFullMap(BuildContext context, ObservationPhoto photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullMapScreen(
          latitude: photo.latitude,
          longitude: photo.longitude,
          speciesName: species.commonName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final firstPhoto = photos.isNotEmpty ? File(photos.first.photoPath) : null;
    final hasPhoto = firstPhoto != null && firstPhoto.existsSync();

    return Scaffold(
      appBar: AppBar(title: Text(species.commonName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo - double-tap to open full screen
            if (hasPhoto)
              GestureDetector(
                onDoubleTap: () => _showFullPhoto(context, firstPhoto),
                onTap: () => _showFullPhoto(context, firstPhoto),
                child: Image.file(
                  firstPhoto,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                  if (photos.isNotEmpty)
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Fecha',
                      value: dateFormat.format(photos.first.capturedAt),
                    ),
                  const SizedBox(height: 10),

                  // Location map placeholder
                  if (photos.isNotEmpty)
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Ubicacion',
                      value:
                          'Lat: ${photos.first.latitude.toStringAsFixed(5)}, Lon: ${photos.first.longitude.toStringAsFixed(5)}',
                    ),
                  const SizedBox(height: 16),

                  // Map (tap to expand fullscreen)
                  if (photos.isNotEmpty)
                    GestureDetector(
                      onTap: () => _openFullMap(context, photos.first),
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
    if (photos.isEmpty) return const SizedBox.shrink();
    final photo = photos.first;
    final point = LatLng(photo.latitude, photo.longitude);
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

/// Pantalla de foto en pantalla completa con pinch-to-zoom y doble tap.
class _FullPhotoScreen extends StatefulWidget {
  final File photoFile;

  const _FullPhotoScreen({required this.photoFile});

  @override
  State<_FullPhotoScreen> createState() => _FullPhotoScreenState();
}

class _FullPhotoScreenState extends State<_FullPhotoScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          if (_animation != null) {
            _transformController.value = _animation!.value;
          }
        });
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    final currentScale = _transformController.value.getMaxScaleOnAxis();

    if (currentScale > 1.05) {
      _animateToMatrix(Matrix4.identity());
    } else {
      final position = details.localPosition;
      final zoomed = Matrix4(
        2.5,
        0,
        0,
        0,
        0,
        2.5,
        0,
        0,
        0,
        0,
        1,
        0,
        -position.dx * 1.5,
        -position.dy * 1.5,
        0,
        1,
      );
      _animateToMatrix(zoomed);
    }
  }

  void _animateToMatrix(Matrix4 target) {
    _animation = Matrix4Tween(begin: _transformController.value, end: target)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTap,
        onDoubleTap: () {},
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: Image.file(widget.photoFile, fit: BoxFit.contain),
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
