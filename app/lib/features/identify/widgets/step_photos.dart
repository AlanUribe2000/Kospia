import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../screens/identify_flow_screen.dart';

/// Paso 1: Captura de fotos con selección de parte de planta.
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

  static const _plantParts = [
    ('general', 'General'),
    ('hoja', 'Hoja'),
    ('flor', 'Flor'),
    ('tallo', 'Tallo'),
    ('fruto', 'Fruto'),
  ];

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null) return;

    // Capture GPS at moment of photo
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {}

    final saved = await _saveImage(image);
    if (saved == null) return;

    final photo = CapturedPhoto(
      path: saved.path,
      source: 'camera',
      latitude: position?.latitude,
      longitude: position?.longitude,
      altitude: position?.altitude ?? 0.0,
      accuracy: position?.accuracy ?? 0.0,
    );

    final updated = [...widget.photos, photo];
    widget.onPhotosChanged(updated);
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (images.isEmpty) return;

    final newPhotos = <CapturedPhoto>[];
    for (final image in images) {
      final saved = await _saveImage(image);
      if (saved != null) {
        newPhotos.add(CapturedPhoto(path: saved.path, source: 'gallery'));
      }
    }

    final updated = [...widget.photos, ...newPhotos];
    widget.onPhotosChanged(updated);
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

  void _removePhoto(int index) {
    final updated = [...widget.photos]..removeAt(index);
    widget.onPhotosChanged(updated);
  }

  void _updatePlantPart(int index, String part) {
    final updated = [...widget.photos];
    updated[index].plantPart = part;
    widget.onPhotosChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Kospi + title
          Image.asset(
            'assets/images/Kospi/Kospi saludando.png',
            height: 80,
            errorBuilder: (_, __, ___) => const SizedBox(height: 80),
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
            'Podés tomar varias fotos de distintas partes',
            style: TextStyle(color: AppColors.textMedium, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text(
                    'Cámara',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text(
                    'Galería',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Photos grid
          Expanded(child: _buildPhotosList()),
          // Next button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              child: const Text('Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosList() {
    if (widget.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 8),
            const Text(
              'Aún no hay fotos',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: widget.photos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final photo = widget.photos[index];
        return _PhotoCard(
          photo: photo,
          plantParts: _plantParts,
          onPartChanged: (part) => _updatePlantPart(index, part),
          onRemove: () => _removePhoto(index),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final CapturedPhoto photo;
  final List<(String, String)> plantParts;
  final ValueChanged<String> onPartChanged;
  final VoidCallback onRemove;

  const _PhotoCard({
    required this.photo,
    required this.plantParts,
    required this.onPartChanged,
    required this.onRemove,
  });

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullPhotoViewer(photoPath: photo.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Thumbnail - tappable
            GestureDetector(
              onTap: () => _openFullScreen(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(photo.path),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceLilac,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dropdown for plant part
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parte de la planta',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLilac,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: photo.plantPart,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        items: plantParts.map((part) {
                          return DropdownMenuItem(
                            value: part.$1,
                            child: Text(part.$2),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) onPartChanged(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Remove button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.error,
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
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
