import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/species_images.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/species_repository.dart';
import '../../../data/services/sequential_questionnaire.dart';
import '../../catalog/screens/species_detail_screen.dart';
import '../screens/identify_flow_screen.dart';
import 'option_illustration.dart';

/// Paso 2: Identificar la planta.
/// Cuestionario secuencial filtrado por las partes fotografiadas.
/// Al final muestra resultados o permite marcar como "sin identificar".
class StepIdentify extends StatefulWidget {
  final Specy? selectedSpecies;
  final ValueChanged<Specy?> onSpeciesSelected;
  final ValueChanged<String> onUnidentifiedNote;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final VoidCallback? onCancel;
  final List<CapturedPhoto> photos;

  const StepIdentify({
    super.key,
    required this.selectedSpecies,
    required this.onSpeciesSelected,
    required this.onUnidentifiedNote,
    required this.onNext,
    required this.onBack,
    this.onCancel,
    required this.photos,
  });

  @override
  State<StepIdentify> createState() => _StepIdentifyState();
}

enum _IdentifyMode { questionnaire, results, unidentified }

class _StepIdentifyState extends State<StepIdentify> {
  SequentialQuestionnaire? _questionnaire;
  bool _loading = true;
  _IdentifyMode _mode = _IdentifyMode.questionnaire;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initQuestionnaire();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initQuestionnaire() async {
    final repo = context.read<SpeciesRepository>();
    final allSpecies = await repo.getAll();

    // Determine which parts have photos
    final photoParts = widget.photos.map((p) => p.plantPart).toSet();

    if (mounted) {
      setState(() {
        _questionnaire = SequentialQuestionnaire(
          allSpecies: allSpecies,
          photoParts: photoParts,
        );
        _loading = false;
      });
    }
  }

  void _answerQuestion(String value) {
    setState(() {
      _questionnaire!.answer(value);
      // If finished, switch to results mode
      if (_questionnaire!.isFinished) {
        _mode = _IdentifyMode.results;
      }
    });
  }

  void _selectSpecies(Specy species) {
    widget.onSpeciesSelected(species);
  }

  void _markUnidentified() {
    setState(() => _mode = _IdentifyMode.unidentified);
  }

  void _confirmUnidentified() {
    widget.onSpeciesSelected(null);
    widget.onUnidentifiedNote(_noteController.text.trim());
  }

  /// Maneja el botón "Atrás":
  /// - Si está en resultados/unidentified → vuelve a la última pregunta
  /// - Si está en cuestionario y puede deshacer → deshace la última respuesta
  /// - Si está en la primera pregunta → vuelve al paso anterior (fotos)
  void _handleBack() {
    if (_mode == _IdentifyMode.unidentified) {
      setState(() => _mode = _IdentifyMode.results);
      return;
    }
    if (_mode == _IdentifyMode.results) {
      // Volver a la última pregunta deshaciendo
      if (_questionnaire!.canUndo) {
        setState(() {
          _questionnaire!.undo();
          _mode = _IdentifyMode.questionnaire;
        });
      } else {
        widget.onBack();
      }
      return;
    }
    // Modo cuestionario
    if (_questionnaire!.canUndo) {
      setState(() => _questionnaire!.undo());
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Kospi
          SizedBox(
            height: AppConstants.kospiImageHeight,
            child: Image.asset(
              'assets/images/Kospi/Kospi pensando.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          // Progress subtitle (Pregunta X · N especies posibles)
          if (_mode == _IdentifyMode.questionnaire && _questionnaire != null)
            Text(
              'Pregunta ${_questionnaire!.answeredCount + 1} · '
              '${_questionnaire!.candidates.length} especies posibles',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),
          // Content based on mode
          Expanded(child: _buildContent()),
          // Navigation
          const SizedBox(height: 12),
          _buildNavigation(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    if (_mode == _IdentifyMode.questionnaire) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Volver'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMedium,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Cancelar'),
          ),
        ],
      );
    }

    // En modo resultados/sin identificar
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            OutlinedButton(
              onPressed: _handleBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Atrás'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onNext,
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
        if (widget.onCancel != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: GestureDetector(
              onTap: widget.onCancel,
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 13, color: AppColors.textMedium),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _IdentifyMode.questionnaire:
        return _buildQuestionnaire();
      case _IdentifyMode.results:
        return _buildResults();
      case _IdentifyMode.unidentified:
        return _buildUnidentified();
    }
  }

  Widget _buildQuestionnaire() {
    final q = _questionnaire!;
    final question = q.currentQuestion;

    if (question == null) {
      // No more questions, go to results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _mode = _IdentifyMode.results);
      });
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Question card (matching option card background)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceLilac.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceLilac, width: 1),
          ),
          child: Text(
            _formatQuestionText(question.text),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Photo thumbnails for reference (optional, smaller)
        if (widget.photos.isNotEmpty) ...[
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openPhoto(widget.photos[index].path),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(widget.photos[index].path),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Options grid (3 columns, visual cards)
        Expanded(child: _buildOptionsGrid(question)),
      ],
    );
  }

  /// Formatea el texto de la pregunta para que se vea más natural en el card.
  String _formatQuestionText(String text) {
    // Convertir a formato tipo "¿Cómo es la forma de sus hojas?"
    return text;
  }

  /// Grid de opciones con ilustraciones (3 columnas como en mockup).
  Widget _buildOptionsGrid(QuestionConfig question) {
    final hasVisual = OptionIllustration.hasVisualIllustration(
      question.fieldName,
    );

    // Total de opciones = las de la pregunta + "No sé / No contesta"
    final totalOptions = question.options.length + 1;

    if (hasVisual) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: totalOptions,
        itemBuilder: (context, index) {
          // Última opción: "No sé / No contesta"
          if (index == question.options.length) {
            return _NoSabeOptionCard(
              onTap: () => _answerQuestion(SequentialQuestionnaire.noSabe),
            );
          }
          final option = question.options[index];
          final label = SequentialQuestionnaire.friendlyOption(
            question.fieldName,
            option,
          );
          return _VisualOptionCard(
            label: label,
            fieldName: question.fieldName,
            optionValue: option,
            onTap: () => _answerQuestion(option),
          );
        },
      );
    }

    // Fallback para preguntas sin visual dedicado: list con íconos
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: totalOptions,
      itemBuilder: (context, index) {
        // Última opción: "No sé / No contesta"
        if (index == question.options.length) {
          return _NoSabeOptionCard(
            onTap: () => _answerQuestion(SequentialQuestionnaire.noSabe),
          );
        }
        final option = question.options[index];
        final label = SequentialQuestionnaire.friendlyOption(
          question.fieldName,
          option,
        );
        return _VisualOptionCard(
          label: label,
          fieldName: question.fieldName,
          optionValue: option,
          onTap: () => _answerQuestion(option),
        );
      },
    );
  }

  void _openPhoto(String path) {
    final allPaths = widget.photos.map((p) => p.path).toList();
    final index = allPaths.indexOf(path);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(
          photoPaths: allPaths,
          initialIndex: index >= 0 ? index : 0,
        ),
      ),
    );
  }

  Widget _buildResults() {
    final candidates = _questionnaire!.candidates;

    if (candidates.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se encontraron coincidencias',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Podés guardar como "sin identificar" para que un experto la revise.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _markUnidentified,
            child: const Text('Guardar sin identificar'),
          ),
        ],
      );
    }

    // Show results
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${candidates.length} resultado${candidates.length > 1 ? 's' : ''}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        if (widget.selectedSpecies != null)
          _SelectedBanner(species: widget.selectedSpecies!),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: candidates.length + 1, // +1 for "no es ninguna"
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              if (index == candidates.length) {
                // "No es ninguna" option
                return OutlinedButton.icon(
                  onPressed: _markUnidentified,
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('No es ninguna de las anteriores'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.textMedium,
                  ),
                );
              }

              final sp = candidates[index];
              final img = SpeciesImages.getFirstImage(sp.scientificName);
              final isSelected = widget.selectedSpecies?.id == sp.id;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.accentGreen, width: 2)
                      : null,
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: img != null
                        ? Image.asset(
                            img,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: AppColors.surfaceLilac,
                            child: const Icon(
                              Icons.local_florist_rounded,
                              color: AppColors.accentGreen,
                              size: 20,
                            ),
                          ),
                  ),
                  title: Text(
                    sp.commonName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    sp.scientificName,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _selectSpecies(sp),
                    icon: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.add_circle_outline_rounded,
                      color: AppColors.accentGreen,
                      size: 24,
                    ),
                    tooltip: 'Seleccionar',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SpeciesDetailScreen(species: sp),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnidentified() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.help_outline_rounded,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin identificar',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escribí el nombre de la planta si lo conocés, '
            'o dejá un comentario para el experto.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nombre o comentario (opcional)',
              filled: true,
              fillColor: AppColors.surfaceLilac,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmUnidentified,
              child: const Text('Confirmar sin identificar'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _mode = _IdentifyMode.results),
            child: const Text('Volver a los resultados'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta para la opción "No sé / No contesta".
/// Estilo diferenciado para distinguirla de las opciones normales.
class _NoSabeOptionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NoSabeOptionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLilac.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceLilac, width: 1),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 36,
                color: AppColors.textLight,
              ),
              SizedBox(height: 6),
              Text(
                'No sé',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta visual de opción para el grid del cuestionario.
/// Muestra una ilustración arriba y un label abajo, con fondo rosa/lila.
/// Para opciones con medidas, muestra el rango como subtítulo.
class _VisualOptionCard extends StatelessWidget {
  final String label;
  final String fieldName;
  final String optionValue;
  final VoidCallback onTap;

  const _VisualOptionCard({
    required this.label,
    required this.fieldName,
    required this.optionValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _splitLabel(label);
    final mainLabel = parts.$1;
    final subtitle = parts.$2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLilac.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceLilac, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration area
              SizedBox(
                width: 52,
                height: 52,
                child: OptionIllustration(
                  fieldName: fieldName,
                  optionValue: optionValue,
                  size: 52,
                ),
              ),
              const SizedBox(height: 6),
              // Main label
              Text(
                mainLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              // Subtitle with measurement range
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMedium,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Separa el label en nombre principal y subtítulo con medidas.
  /// Retorna (mainLabel, subtitle) donde subtitle puede ser null.
  (String, String?) _splitLabel(String label) {
    final parenIdx = label.indexOf('(');
    if (parenIdx > 0) {
      final main = label.substring(0, parenIdx).trim();
      final measure = label.substring(parenIdx + 1, label.length - 1).trim();
      return (main, measure);
    }
    // Fix: reemplazar underscores por espacios
    final cleaned = label.replaceAll('_', ' ');
    return (cleaned, null);
  }
}

/// Banner que muestra la especie seleccionada.
class _SelectedBanner extends StatelessWidget {
  final Specy species;
  const _SelectedBanner({required this.species});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accentGreenLight),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.accentGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seleccionada: ${species.commonName}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visor de foto fullscreen.
class _PhotoViewer extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;
  const _PhotoViewer({required this.photoPaths, this.initialIndex = 0});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _tc = TransformationController();
  late AnimationController _animController;
  late PageController _pageController;
  late int _currentPage;
  bool _isZoomed = false;
  Animation<Matrix4>? _anim;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          if (_anim != null) _tc.value = _anim!.value;
        });
    _tc.addListener(_onTransformChanged);
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

  void _onDoubleTap(TapDownDetails d) {
    if (_tc.value.getMaxScaleOnAxis() > 1.05) {
      _animateTo(Matrix4.identity());
    } else {
      final p = d.localPosition;
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
          -p.dx * 1.5,
          -p.dy * 1.5,
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
        title: widget.photoPaths.length > 1
            ? Text(
                '${_currentPage + 1} / ${widget.photoPaths.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photoPaths.length,
        physics: _isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (i) => setState(() {
          _currentPage = i;
          _tc.value = Matrix4.identity();
        }),
        itemBuilder: (context, index) {
          return GestureDetector(
            onDoubleTapDown: _onDoubleTap,
            onDoubleTap: () {},
            child: InteractiveViewer(
              transformationController: index == _currentPage ? _tc : null,
              minScale: 1.0,
              maxScale: 5.0,
              child: Center(
                child: Image.file(
                  File(widget.photoPaths[index]),
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
        },
      ),
    );
  }
}
