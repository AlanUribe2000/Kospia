import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../screens/identify_flow_screen.dart';

/// Paso 3: Asignar ubicación a cada foto.
class StepLocation extends StatefulWidget {
  final List<CapturedPhoto> photos;
  final ValueChanged<List<CapturedPhoto>> onPhotosChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  const StepLocation({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _autoFillMissingLocations();
  }

  /// Para fotos sin ubicación (galería), intenta obtener la actual.
  Future<void> _autoFillMissingLocations() async {
    final missing = widget.photos.where((p) => !p.hasLocation).toList();
    if (missing.isEmpty) return;

    setState(() => _loadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      for (final photo in missing) {
        photo.latitude = position.latitude;
        photo.longitude = position.longitude;
        photo.altitude = position.altitude;
        photo.accuracy = position.accuracy;
      }
      widget.onPhotosChanged([...widget.photos]);
    } catch (_) {}

    if (mounted) setState(() => _loadingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    final allHaveLocation = widget.photos.every((p) => p.hasLocation);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.asset(
            'assets/images/Kospi/Kospi tomandose las manos.png',
            height: 80,
            errorBuilder: (_, __, ___) => const SizedBox(height: 80),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Dónde se tomaron las fotos?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Podés ajustar la ubicación de cada foto',
            style: TextStyle(color: AppColors.textMedium, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_loadingLocation)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Obteniendo ubicación...',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: widget.photos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _PhotoLocationCard(
                  photo: widget.photos[index],
                  index: index,
                  onLocationChanged: (lat, lng) {
                    widget.photos[index].latitude = lat;
                    widget.photos[index].longitude = lng;
                    widget.onPhotosChanged([...widget.photos]);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Atrás', maxLines: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: allHaveLocation ? widget.onNext : null,
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoLocationCard extends StatelessWidget {
  final CapturedPhoto photo;
  final int index;
  final void Function(double lat, double lng) onLocationChanged;

  const _PhotoLocationCard({
    required this.photo,
    required this.index,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        'Foto ${index + 1} - ${_partLabel(photo.plantPart)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        photo.hasLocation
                            ? 'Lat: ${photo.latitude!.toStringAsFixed(4)}, '
                                  'Lon: ${photo.longitude!.toStringAsFixed(4)}'
                            : 'Sin ubicación',
                        style: TextStyle(
                          fontSize: 11,
                          color: photo.hasLocation
                              ? AppColors.textMedium
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _openMapPicker(context),
                  child: const Text('Cambiar', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (photo.hasLocation) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 120,
                  child: IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          photo.latitude!,
                          photo.longitude!,
                        ),
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.kospia.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(photo.latitude!, photo.longitude!),
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  void _openMapPicker(BuildContext context) {
    final initialLat = photo.latitude ?? -43.3;
    final initialLng = photo.longitude ?? -65.1;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MapPickerScreen(
          initialLat: initialLat,
          initialLng: initialLng,
          onLocationPicked: onLocationChanged,
        ),
      ),
    );
  }
}

/// Pantalla de mapa para elegir ubicación arrastrando el pin.
class _MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final void Function(double lat, double lng) onLocationPicked;

  const _MapPickerScreen({
    required this.initialLat,
    required this.initialLng,
    required this.onLocationPicked,
  });

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir ubicación'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onLocationPicked(
                _selectedPoint.latitude,
                _selectedPoint.longitude,
              );
              Navigator.of(context).pop();
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedPoint,
          initialZoom: 14,
          onTap: (_, point) {
            setState(() => _selectedPoint = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.kospia.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPoint,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentOrange.withValues(alpha: 0.4),
                        blurRadius: 6,
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
