import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/identify_flow_screen.dart';

/// Paso 3: Ubicación geográfica.
/// Agrupa fotos en 3 categorías:
/// - Galería con EXIF: ubicación fija, no editable.
/// - Cámara: comparten una ubicación, editable.
/// - Galería sin EXIF: cada una editable individualmente.
class StepLocation extends StatefulWidget {
  final List<CapturedPhoto> photos;
  final ValueChanged<List<CapturedPhoto>> onPhotosChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final VoidCallback? onCancel;

  const StepLocation({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
    required this.onNext,
    required this.onBack,
    this.onCancel,
  });

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  bool _loadingLocation = false;

  List<CapturedPhoto> get _exifPhotos => widget.photos
      .where((p) => p.source == 'gallery' && p.hasExifGps)
      .toList();

  List<CapturedPhoto> get _cameraPhotos =>
      widget.photos.where((p) => p.source == 'camera').toList();

  List<CapturedPhoto> get _galleryNoGps => widget.photos
      .where((p) => p.source == 'gallery' && !p.hasExifGps)
      .toList();

  @override
  void initState() {
    super.initState();
    _autoFillMissing();
  }

  Future<void> _autoFillMissing() async {
    final needsGps = widget.photos.where((p) => !p.hasLocation).toList();
    if (needsGps.isEmpty) return;

    setState(() => _loadingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      for (final p in needsGps) {
        p.latitude = pos.latitude;
        p.longitude = pos.longitude;
      }
      widget.onPhotosChanged([...widget.photos]);
    } catch (_) {}
    if (mounted) setState(() => _loadingLocation = false);
  }

  void _updateCameraLocation(double lat, double lng) {
    for (final p in _cameraPhotos) {
      p.latitude = lat;
      p.longitude = lng;
    }
    widget.onPhotosChanged([...widget.photos]);
  }

  void _updatePhotoLocation(CapturedPhoto photo, double lat, double lng) {
    photo.latitude = lat;
    photo.longitude = lng;
    widget.onPhotosChanged([...widget.photos]);
  }

  void _openPhoto(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullPhotoViewer(photoPath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allHaveLocation = widget.photos.every((p) => p.hasLocation);
    final exif = _exifPhotos;
    final camera = _cameraPhotos;
    final noGps = _galleryNoGps;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: AppConstants.kospiImageHeight,
            child: Image.asset(
              'assets/images/Kospi/Kospi tomandose las manos.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Dónde se tomaron las fotos?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (_loadingLocation)
            const Padding(
              padding: EdgeInsets.all(8),
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
            child: ListView(
              children: [
                // Fotos con EXIF (fijas)
                for (final photo in exif)
                  _LocationCard(
                    photos: [photo],
                    label: 'Ubicación original',
                    latitude: photo.latitude!,
                    longitude: photo.longitude!,
                    editable: false,
                    onTapPhoto: _openPhoto,
                    onExpandMap: () => _expandMap(
                      photo.latitude!,
                      photo.longitude!,
                      false,
                      null,
                    ),
                  ),

                // Fotos de cámara (compartidas)
                if (camera.isNotEmpty && camera.first.hasLocation)
                  _LocationCard(
                    photos: camera,
                    label: 'Fotos de cámara',
                    latitude: camera.first.latitude!,
                    longitude: camera.first.longitude!,
                    editable: true,
                    onTapPhoto: _openPhoto,
                    onLocationChanged: _updateCameraLocation,
                    onExpandMap: () => _expandMap(
                      camera.first.latitude!,
                      camera.first.longitude!,
                      true,
                      _updateCameraLocation,
                    ),
                  ),

                // Fotos de galería sin EXIF (individuales)
                for (final photo in noGps)
                  _LocationCard(
                    photos: [photo],
                    label: 'Foto sin ubicación original',
                    latitude: photo.hasLocation ? photo.latitude! : 0,
                    longitude: photo.hasLocation ? photo.longitude! : 0,
                    editable: true,
                    onTapPhoto: _openPhoto,
                    onLocationChanged: (lat, lng) =>
                        _updatePhotoLocation(photo, lat, lng),
                    onExpandMap: () => _expandMap(
                      photo.hasLocation ? photo.latitude! : -43.3,
                      photo.hasLocation ? photo.longitude! : -65.1,
                      true,
                      (lat, lng) => _updatePhotoLocation(photo, lat, lng),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: const Text('Atrás'),
              ),
              if (widget.onCancel != null) ...[
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: allHaveLocation ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _expandMap(
    double lat,
    double lng,
    bool editable,
    void Function(double, double)? onChanged,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullMapScreen(
          initialLat: lat,
          initialLng: lng,
          editable: editable,
          onLocationPicked: onChanged,
        ),
      ),
    );
  }
}

/// Tarjeta de ubicación con fotos horizontales, mapa y controles.
class _LocationCard extends StatelessWidget {
  final List<CapturedPhoto> photos;
  final String label;
  final double latitude;
  final double longitude;
  final bool editable;
  final ValueChanged<String> onTapPhoto;
  final void Function(double, double)? onLocationChanged;
  final VoidCallback onExpandMap;

  const _LocationCard({
    required this.photos,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.editable,
    required this.onTapPhoto,
    required this.onExpandMap,
    this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValid =
        latitude != 0 && longitude != 0 && !latitude.isNaN && !longitude.isNaN;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (!editable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLilac,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Fija',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                if (editable)
                  TextButton(
                    onPressed: () => _openPicker(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            // Coordinates
            if (hasValid)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            // Date/time from photo metadata
            if (photos.length == 1)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Fecha: ${_formatDateTime(photos.first.capturedAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Fecha: ${_formatDateTime(photos.first.capturedAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            // Photo thumbnails (horizontal, tappable)
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onTapPhoto(photos[index].path),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photos[index].path),
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: AppColors.surfaceLilac,
                          child: const Icon(Icons.broken_image, size: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Map (tappable to expand)
            if (hasValid) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onExpandMap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 120,
                    key: ValueKey('map_${latitude}_$longitude'),
                    child: Stack(
                      children: [
                        IgnorePointer(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(latitude, longitude),
                              initialZoom: 14,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.kospia.app',
                                errorImage: const AssetImage(
                                  'assets/images/logo.png',
                                ),
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(latitude, longitude),
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
                        // Expand icon
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 16,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ),
                        // Offline overlay
                        Positioned.fill(
                          child: _OfflineOverlay(lat: latitude, lng: longitude),
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

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _openPicker(BuildContext context) {
    final lat = latitude != 0 ? latitude : -43.3;
    final lng = longitude != 0 ? longitude : -65.1;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullMapScreen(
          initialLat: lat,
          initialLng: lng,
          editable: true,
          onLocationPicked: onLocationChanged,
        ),
      ),
    );
  }
}

/// Mapa a pantalla completa. Si editable, permite tocar para mover el pin.
class _FullMapScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final bool editable;
  final void Function(double, double)? onLocationPicked;

  const _FullMapScreen({
    required this.initialLat,
    required this.initialLng,
    required this.editable,
    this.onLocationPicked,
  });

  @override
  State<_FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<_FullMapScreen> {
  late LatLng _point;

  @override
  void initState() {
    super.initState();
    _point = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editable ? 'Elegir ubicación' : 'Ubicación'),
        actions: [
          if (widget.editable)
            TextButton(
              onPressed: () {
                widget.onLocationPicked?.call(
                  _point.latitude,
                  _point.longitude,
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
          initialCenter: _point,
          initialZoom: 15,
          onTap: widget.editable
              ? (_, point) {
                  setState(() => _point = point);
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.kospia.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _point,
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

/// Visor fullscreen de foto.
class _FullPhotoViewer extends StatelessWidget {
  final String photoPath;
  const _FullPhotoViewer({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: Center(
          child: Image.file(
            File(photoPath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_rounded,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay offline.
class _OfflineOverlay extends StatefulWidget {
  final double lat;
  final double lng;
  const _OfflineOverlay({required this.lat, required this.lng});

  @override
  State<_OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<_OfflineOverlay> {
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final r = await Connectivity().checkConnectivity();
    if (mounted) setState(() => _offline = r.contains(ConnectivityResult.none));
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLilac.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            const Text(
              'Mapa no visible sin internet',
              style: TextStyle(fontSize: 11, color: AppColors.textMedium),
            ),
            Text(
              '${widget.lat.toStringAsFixed(5)}, ${widget.lng.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
