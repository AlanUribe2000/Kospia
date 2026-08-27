import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/identify_flow_screen.dart';

/// Paso 1: Captura de fotos organizadas por parte de la planta.
/// 5 tarjetas (General, Hoja, Espinas, Flor, Fruto) con botones de cámara y galería.
class StepPhotos extends StatefulWidget {
  final List<CapturedPhoto> photos;
  final ValueChanged<List<CapturedPhoto>> onPhotosChanged;
  final VoidCallback? onNext;

  const StepPhotos({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
    required this.onNext,
  });

  @override
  State<StepPhotos> createState() => _StepPhotosState();
}

class _StepPhotosState extends State<StepPhotos> {
  final _picker = ImagePicker();
  static const _uuid = Uuid();

  /// GPS de la sesión: se obtiene una vez y se usa para todas las fotos de cámara.
  Position? _sessionPosition;
  bool _gpsObtained = false;

  static const _parts = [
    (AppConstants.partGeneral, 'General', Icons.nature_rounded),
    (AppConstants.partHoja, 'Hoja', Icons.eco_rounded),
    (AppConstants.partEspinas, 'Espinas', Icons.grass_rounded),
    (AppConstants.partFlor, 'Flor', Icons.local_florist_rounded),
    (AppConstants.partFruto, 'Fruto', Icons.spa_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _obtainSessionGps();
  }

  /// Obtiene GPS una sola vez para toda la sesión de fotos.
  Future<void> _obtainSessionGps() async {
    if (_gpsObtained) return;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      _sessionPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {}
    _gpsObtained = true;
  }

  List<CapturedPhoto> _photosForPart(String part) {
    return widget.photos.where((p) => p.plantPart == part).toList();
  }

  Future<void> _takePhoto(String part) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null) return;

    if (!_gpsObtained) await _obtainSessionGps();

    final saved = await _saveImage(image);
    if (saved == null) return;

    final photo = CapturedPhoto(
      path: saved.path,
      source: 'camera',
      plantPart: part,
      latitude: _sessionPosition?.latitude,
      longitude: _sessionPosition?.longitude,
      altitude: _sessionPosition?.altitude ?? 0.0,
      accuracy: _sessionPosition?.accuracy ?? 0.0,
    );

    widget.onPhotosChanged([...widget.photos, photo]);
  }

  Future<void> _pickFromGallery(String part) async {
    // Pedir permiso de ubicación de medios (necesario para leer GPS de fotos)
    await Permission.accessMediaLocation.request();

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    if (!_gpsObtained) await _obtainSessionGps();

    final newPhotos = <CapturedPhoto>[];
    for (final image in images) {
      // Leer EXIF GPS y fecha del archivo original (antes de comprimir)
      final exifData = await _extractExifMetadata(image.path);

      final saved = await _saveImage(image);
      if (saved != null) {
        // GPS: EXIF si hay, sino GPS de la sesión como fallback
        final lat = exifData?.lat ?? _sessionPosition?.latitude;
        final lng = exifData?.lng ?? _sessionPosition?.longitude;
        final exifDate = exifData?.date;
        final hasGps = exifData?.lat != null;

        newPhotos.add(
          CapturedPhoto(
            path: saved.path,
            source: 'gallery',
            plantPart: part,
            latitude: lat,
            longitude: lng,
            hasExifGps: hasGps,
            capturedAt: exifDate,
          ),
        );
      }
    }

    widget.onPhotosChanged([...widget.photos, ...newPhotos]);
  }

  /// Extrae coordenadas GPS y fecha/hora de la metadata EXIF de una imagen.
  Future<({double? lat, double? lng, DateTime? date})?> _extractExifMetadata(
    String path,
  ) async {
    try {
      final bytes = await File(path).readAsBytes();
      final data = await readExifFromBytes(bytes);
      if (data.isEmpty) return null;

      // GPS
      double? lat;
      double? lng;
      final latTag = data['GPS GPSLatitude'];
      final latRef = data['GPS GPSLatitudeRef'];
      final lngTag = data['GPS GPSLongitude'];
      final lngRef = data['GPS GPSLongitudeRef'];

      if (latTag != null && lngTag != null) {
        final latVal = _gpsToDecimal(latTag.values, latRef?.printable ?? 'N');
        final lngVal = _gpsToDecimal(lngTag.values, lngRef?.printable ?? 'E');
        if (!latVal.isNaN &&
            !latVal.isInfinite &&
            !lngVal.isNaN &&
            !lngVal.isInfinite &&
            !(latVal == 0.0 && lngVal == 0.0)) {
          lat = latVal;
          lng = lngVal;
        }
      }

      // Fecha/hora
      DateTime? exifDate;
      final dateTag =
          data['EXIF DateTimeOriginal'] ??
          data['EXIF DateTimeDigitized'] ??
          data['Image DateTime'];
      if (dateTag != null) {
        exifDate = _parseExifDate(dateTag.printable);
      }

      return (lat: lat, lng: lng, date: exifDate);
    } catch (_) {
      return null;
    }
  }

  /// Parsea una fecha EXIF en formato "YYYY:MM:DD HH:MM:SS" a DateTime.
  DateTime? _parseExifDate(String dateStr) {
    try {
      // Formato EXIF: "2024:11:15 14:30:00"
      // Reemplazar los primeros dos ':' por '-' para ISO 8601
      final parts = dateStr.split(' ');
      if (parts.isEmpty) return null;
      final datePart = parts[0].replaceAll(':', '-');
      final timePart = parts.length > 1 ? parts[1] : '00:00:00';
      return DateTime.tryParse('$datePart $timePart');
    } catch (_) {
      return null;
    }
  }

  /// Convierte coordenadas GPS EXIF (grados/minutos/segundos) a decimal.
  double _gpsToDecimal(IfdValues values, String ref) {
    try {
      final ratios = values.toList();
      if (ratios.length < 3) return 0.0;

      final dDen = (ratios[0] as Ratio).denominator.toDouble();
      final mDen = (ratios[1] as Ratio).denominator.toDouble();
      final sDen = (ratios[2] as Ratio).denominator.toDouble();

      // Proteger contra divisiones por cero
      if (dDen == 0 || mDen == 0 || sDen == 0) return 0.0;

      final d = (ratios[0] as Ratio).numerator.toDouble() / dDen;
      final m = (ratios[1] as Ratio).numerator.toDouble() / mDen;
      final s = (ratios[2] as Ratio).numerator.toDouble() / sDen;

      var decimal = d + (m / 60.0) + (s / 3600.0);
      if (ref == 'S' || ref == 'W') decimal = -decimal;
      return decimal;
    } catch (_) {
      return 0.0;
    }
  }

  Future<File?> _saveImage(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(appDir.path, 'observations'));
      if (!photosDir.existsSync()) {
        photosDir.createSync(recursive: true);
      }
      final fileName = '${_uuid.v4()}.jpg';
      return await File(image.path).copy(p.join(photosDir.path, fileName));
    } catch (_) {
      return null;
    }
  }

  void _removePhoto(CapturedPhoto photo) {
    final updated = widget.photos.where((p) => p != photo).toList();
    widget.onPhotosChanged(updated);
  }

  void _openFullPhoto(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullPhotoViewer(photoPath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Kospi + title
          SizedBox(
            height: AppConstants.kospiImageHeight,
            child: Image.asset(
              'assets/images/Kospi/Kospi saludando.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Sacá fotos de la planta!',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cargá fotos en las partes que puedas observar',
            style: TextStyle(color: AppColors.textMedium, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Part cards - scrollable
          Expanded(
            child: ListView.separated(
              itemCount: _parts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final part = _parts[index];
                final photos = _photosForPart(part.$1);
                return _PartCard(
                  partId: part.$1,
                  partLabel: part.$2,
                  partIcon: part.$3,
                  photos: photos,
                  onTakePhoto: () => _takePhoto(part.$1),
                  onPickGallery: () => _pickFromGallery(part.$1),
                  onRemovePhoto: _removePhoto,
                  onTapPhoto: _openFullPhoto,
                );
              },
            ),
          ),
          // Next button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              child: const Text('Siguiente'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Tarjeta de una parte de la planta con botones de cámara/galería y miniaturas.
class _PartCard extends StatelessWidget {
  final String partId;
  final String partLabel;
  final IconData partIcon;
  final List<CapturedPhoto> photos;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickGallery;
  final ValueChanged<CapturedPhoto> onRemovePhoto;
  final ValueChanged<String> onTapPhoto;

  const _PartCard({
    required this.partId,
    required this.partLabel,
    required this.partIcon,
    required this.photos,
    required this.onTakePhoto,
    required this.onPickGallery,
    required this.onRemovePhoto,
    required this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: photos.isNotEmpty
            ? AppColors.accentGreen.withValues(alpha: 0.06)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: photos.isNotEmpty
              ? AppColors.accentGreenLight
              : AppColors.surfaceLilac,
          width: photos.isNotEmpty ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + label + action buttons
          Row(
            children: [
              Icon(
                partIcon,
                size: 20,
                color: photos.isNotEmpty
                    ? AppColors.accentGreen
                    : AppColors.textLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  partLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: photos.isNotEmpty
                        ? AppColors.textDark
                        : AppColors.textMedium,
                  ),
                ),
              ),
              if (photos.isNotEmpty)
                Text(
                  '${photos.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 8),
              // Camera button
              _IconActionButton(
                icon: Icons.camera_alt_rounded,
                onPressed: onTakePhoto,
                filled: true,
              ),
              const SizedBox(width: 6),
              // Gallery button
              _IconActionButton(
                icon: Icons.photo_library_rounded,
                onPressed: onPickGallery,
                filled: false,
              ),
            ],
          ),
          // Photo thumbnails
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return _PhotoThumbnail(
                    photo: photo,
                    onTap: () => onTapPhoto(photo.path),
                    onRemove: () => onRemovePhoto(photo),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Botón de acción con solo ícono (cámara o galería).
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  const _IconActionButton({
    required this.icon,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Icon(icon, size: 18),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Icon(icon, size: 18),
            ),
    );
  }
}

/// Miniatura de foto con botón de eliminar y tap para agrandar.
class _PhotoThumbnail extends StatelessWidget {
  final CapturedPhoto photo;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoThumbnail({
    required this.photo,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(photo.path),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.surfaceLilac,
                child: const Icon(Icons.broken_image, size: 18),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Visor de foto a pantalla completa con zoom y doble tap.
class _FullPhotoViewer extends StatefulWidget {
  final String photoPath;
  const _FullPhotoViewer({required this.photoPath});

  @override
  State<_FullPhotoViewer> createState() => _FullPhotoViewerState();
}

class _FullPhotoViewerState extends State<_FullPhotoViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _tc = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _anim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          if (_anim != null) _tc.value = _anim!.value;
        });
  }

  @override
  void dispose() {
    _animController.dispose();
    _tc.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails d) {
    if (_tc.value.getMaxScaleOnAxis() > 1.05) {
      _animateTo(Matrix4.identity());
    } else {
      final pos = d.localPosition;
      _animateTo(
        Matrix4(
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
          -pos.dx * 1.5,
          -pos.dy * 1.5,
          0,
          1,
        ),
      );
    }
  }

  void _animateTo(Matrix4 target) {
    _anim = Matrix4Tween(begin: _tc.value, end: target).animate(
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
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {},
        child: InteractiveViewer(
          transformationController: _tc,
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: Image.file(
              File(widget.photoPath),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_rounded,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
