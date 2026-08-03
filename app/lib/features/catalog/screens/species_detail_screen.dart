import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/species_images.dart';
import '../../../data/database/app_database.dart';

/// Pantalla de detalle de una especie con información completa.
class SpeciesDetailScreen extends StatelessWidget {
  final Specy species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    final images = SpeciesImages.getImages(species.scientificName);

    return Scaffold(
      appBar: AppBar(title: Text(species.commonName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image gallery
            if (images.isNotEmpty)
              _ImageGallery(images: images)
            else
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

class _ImageGallery extends StatefulWidget {
  final List<String> images;

  const _ImageGallery({required this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image carousel
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullScreen(context, index),
                  child: Image.asset(
                    widget.images[index],
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.accentGreenLight.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.textLight,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Page indicator dots
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 10),
              ...List.generate(widget.images.length, (index) {
                return Container(
                  width: index == _currentIndex ? 8 : 6,
                  height: index == _currentIndex ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? AppColors.accentGreen
                        : AppColors.textLight.withValues(alpha: 0.3),
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }

  void _showFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          images: widget.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

/// Visor de imágenes a pantalla completa con zoom y swipe.
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late int _currentIndex;
  late final PageController _pageController;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onZoomChanged(bool zoomed) {
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.images.length > 1
            ? Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: _isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return _ZoomableImage(
            imagePath: widget.images[index],
            onZoomChanged: _onZoomChanged,
          );
        },
      ),
    );
  }
}

/// Widget individual de imagen con zoom.
/// Notifica al padre cuando se entra/sale del estado de zoom
/// para que pueda bloquear el swipe del PageView.
class _ZoomableImage extends StatefulWidget {
  final String imagePath;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({required this.imagePath, required this.onZoomChanged});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
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

    _transformController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.05);
  }

  /// Doble tap para alternar zoom 2.5x / reset.
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
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 1.0,
        maxScale: 5.0,
        panEnabled: true,
        scaleEnabled: true,
        onInteractionStart: (_) {
          widget.onZoomChanged(true);
        },
        onInteractionEnd: (_) {
          _onTransformChanged();
        },
        child: Center(
          child: Image.asset(
            widget.imagePath,
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
