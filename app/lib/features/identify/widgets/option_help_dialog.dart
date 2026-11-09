import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/species_repository.dart';
import '../../../data/services/sequential_questionnaire.dart';
import 'option_image.dart';

/// Fondo neutro oscuro detrás de las fotos de ayuda (carrusel y visor). Se usa
/// en lugar del lila del tema para que, mientras una foto aún no está
/// decodificada (primera visita), no aparezca la "franja violeta" al deslizar.
const Color _kPhotoBackground = Color(0xFF1A1A2E);

/// Popup de ayuda para UNA opción de una pregunta del cuestionario.
///
/// Muestra la etiqueta de la opción (título), su texto descriptivo (o un
/// mensaje suave si no tiene) y un carrusel deslizable (PageView horizontal)
/// con las fotos de ayuda de esa opción, usando [OptionImage] para
/// descargarlas del backend de forma autenticada.
///
/// En el encabezado conserva el texto de la pregunta como contexto y la opción
/// debajo, junto con el botón de cerrar (X). Las fotos del carrusel se ven
/// completas (BoxFit.contain) y al tocarlas se abre un visor a pantalla
/// completa con zoom (ver [_FullscreenPhotoViewer]).
class OptionHelpDialog extends StatelessWidget {
  const OptionHelpDialog({
    super.key,
    required this.questionText,
    required this.fieldName,
    required this.option,
  });

  final String questionText;
  final String fieldName;
  final OptionHelp option;

  @override
  Widget build(BuildContext context) {
    final label = SequentialQuestionnaire.friendlyOption(
      fieldName,
      option.valueKey.isEmpty ? option.optionText : option.valueKey,
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, label),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (option.description != null &&
                              option.description!.trim().isNotEmpty)
                          ? option.description!.trim()
                          : 'Sin descripción disponible.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: option.description != null
                            ? AppColors.textMedium
                            : AppColors.textLight,
                        fontStyle: option.description != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGallery(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.accentGreen,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    if (option.photos.isEmpty) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceLilac.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Sin fotos de ayuda todavía.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return _OptionGallery(photos: option.photos);
  }
}

/// Galería deslizable horizontal (PageView) de fotos de ayuda de una opción.
///
/// Las fotos se muestran completas (BoxFit.contain). Al tocar una foto se
/// abre un visor a pantalla completa con zoom.
class _OptionGallery extends StatefulWidget {
  const _OptionGallery({required this.photos});

  final List<OptionPhoto> photos;

  @override
  State<_OptionGallery> createState() => _OptionGalleryState();
}

class _OptionGalleryState extends State<_OptionGallery> {
  final _controller = PageController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    // Precarga de todas las fotos de la opción (son pocas, típicamente 2-10)
    // para que al deslizar la siguiente ya esté decodificada y no se vea el
    // fondo mientras descarga. El prefetch deduplica y cachea en memoria.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final photo in widget.photos) {
        OptionImage.prefetch(context, photo.id);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _FullscreenPhotoViewer(photos: widget.photos, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => _openFullscreen(index),
                  // OptionImage pinta su propio fondo neutro (no el lila del
                  // tema) detrás de la foto y la clipa, así al deslizar a una
                  // foto aún no decodificada no se ve la "franja violeta".
                  child: OptionImage(
                    imageId: widget.photos[index].id,
                    width: double.infinity,
                    height: 180,
                    borderRadius: 12,
                    fit: BoxFit.contain,
                    backgroundColor: _kPhotoBackground,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.photos.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.photos.length, (i) {
              final selected = i == _current;
              return Container(
                width: selected ? 8 : 6,
                height: selected ? 8 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.accentGreen
                      : AppColors.textLight.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Visor a pantalla completa de las fotos de ayuda de una opción.
///
/// Permite: doble toque para hacer zoom (toggle 1x <-> 2.5x centrado en el
/// punto tocado), pinch-to-zoom (InteractiveViewer), deslizar entre fotos
/// (PageView, deshabilitado mientras hay zoom para no pelear con el pan) y
/// cerrar con un botón explícito (X) además del gesto de volver. Las
/// imágenes se ven completas (BoxFit.contain) sobre fondo oscuro y se cargan
/// desde la API reutilizando [OptionImage].
class _FullscreenPhotoViewer extends StatefulWidget {
  const _FullscreenPhotoViewer({required this.photos, this.initialIndex = 0});

  final List<OptionPhoto> photos;
  final int initialIndex;

  @override
  State<_FullscreenPhotoViewer> createState() => _FullscreenPhotoViewerState();
}

class _FullscreenPhotoViewerState extends State<_FullscreenPhotoViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final TransformationController _tc;
  late final AnimationController _animController;
  Animation<Matrix4>? _anim;
  late int _currentPage;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Precarga todas las fotos para que deslizar en el visor sea instantáneo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final photo in widget.photos) {
        OptionImage.prefetch(context, photo.id);
      }
    });
    _tc = TransformationController();
    _tc.addListener(_onTransformChanged);
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
    _tc.removeListener(_onTransformChanged);
    _animController.dispose();
    _tc.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed = _tc.value.getMaxScaleOnAxis() > 1.05;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  /// Doble toque para alternar zoom: si ya está ampliada vuelve a escala 1,
  /// si no, acerca a 2.5x centrado en el punto tocado. Mantiene también el
  /// pinch-to-zoom del InteractiveViewer.
  void _onDoubleTap(TapDownDetails d) {
    if (_tc.value.getMaxScaleOnAxis() > 1.05) {
      _animateTo(Matrix4.identity());
    } else {
      const scale = 2.5;
      final p = d.localPosition;
      // Matriz de escala centrada en el punto tocado, construida de forma
      // explícita para no usar los métodos deprecados translate()/scale().
      _animateTo(
        Matrix4(
          scale,
          0,
          0,
          0, //
          0,
          scale,
          0,
          0, //
          0,
          0,
          1,
          0, //
          -p.dx * (scale - 1),
          -p.dy * (scale - 1),
          0,
          1, //
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
        ),
        title: widget.photos.length > 1
            ? Text(
                '${_currentPage + 1} / ${widget.photos.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        physics: _isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (i) => setState(() {
          _currentPage = i;
          _tc.value = Matrix4.identity();
        }),
        itemBuilder: (context, index) {
          return GestureDetector(
            onDoubleTapDown: index == _currentPage ? _onDoubleTap : null,
            onDoubleTap: () {},
            child: InteractiveViewer(
              transformationController: index == _currentPage ? _tc : null,
              minScale: 1.0,
              maxScale: 5.0,
              child: Center(
                child: OptionImage(
                  imageId: widget.photos[index].id,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0,
                  fit: BoxFit.contain,
                  // Fondo negro (= scaffold) detrás de la foto mientras carga,
                  // para no ver el lila del tema en el visor a pantalla completa.
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
