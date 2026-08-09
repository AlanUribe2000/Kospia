import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/species_images.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/species_repository.dart';
import '../../../data/services/identification_engine.dart';
import '../../catalog/screens/species_detail_screen.dart';

/// Paso 2: Identificar la planta - elegir del catálogo o responder cuestionario.
class StepIdentify extends StatefulWidget {
  final Specy? selectedSpecies;
  final ValueChanged<Specy> onSpeciesSelected;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final List<String> photoPaths;

  const StepIdentify({
    super.key,
    required this.selectedSpecies,
    required this.onSpeciesSelected,
    required this.onNext,
    required this.onBack,
    required this.photoPaths,
  });

  @override
  State<StepIdentify> createState() => _StepIdentifyState();
}

enum _IdentifyMode { choose, catalog, questionnaire }

class _StepIdentifyState extends State<StepIdentify> {
  _IdentifyMode _mode = _IdentifyMode.choose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Kospi thinking
          Image.asset(
            'assets/images/Kospi/Kospi pensando.png',
            height: 80,
            errorBuilder: (_, __, ___) => const SizedBox(height: 80),
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectedSpecies != null
                ? '¡Planta seleccionada!'
                : '¿Qué planta es?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            widget.selectedSpecies != null
                ? widget.selectedSpecies!.commonName
                : 'Elegí del catálogo o respondé el cuestionario',
            style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Content based on mode
          Expanded(child: _buildContent()),
          // Navigation buttons
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
                  onPressed: widget.onNext,
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _IdentifyMode.choose:
        return _buildChooseMode();
      case _IdentifyMode.catalog:
        return _CatalogPicker(
          onSelected: (sp) {
            widget.onSpeciesSelected(sp);
            setState(() => _mode = _IdentifyMode.choose);
          },
          onBack: () => setState(() => _mode = _IdentifyMode.choose),
        );
      case _IdentifyMode.questionnaire:
        return _QuestionnairePicker(
          photoPaths: widget.photoPaths,
          onSelected: (sp) {
            widget.onSpeciesSelected(sp);
            setState(() => _mode = _IdentifyMode.choose);
          },
          onBack: () => setState(() => _mode = _IdentifyMode.choose),
        );
    }
  }

  Widget _buildChooseMode() {
    return Column(
      children: [
        // Selected species preview
        if (widget.selectedSpecies != null) ...[
          _SelectedSpeciesCard(species: widget.selectedSpecies!),
          const SizedBox(height: 16),
          const Text(
            '¿Querés cambiar?',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
        // Option cards
        _OptionCard(
          icon: Icons.menu_book_rounded,
          title: 'Elegir del catálogo',
          subtitle: 'Buscá la planta por nombre',
          onTap: () => setState(() => _mode = _IdentifyMode.catalog),
        ),
        const SizedBox(height: 12),
        _OptionCard(
          icon: Icons.quiz_rounded,
          title: 'Responder cuestionario',
          subtitle: 'Te guiamos con preguntas',
          onTap: () => setState(() => _mode = _IdentifyMode.questionnaire),
        ),
      ],
    );
  }
}

class _SelectedSpeciesCard extends StatelessWidget {
  final Specy species;
  const _SelectedSpeciesCard({required this.species});

  @override
  Widget build(BuildContext context) {
    final img = SpeciesImages.getFirstImage(species.scientificName);
    return Card(
      color: AppColors.accentGreen.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: img != null
                  ? Image.asset(img, width: 44, height: 44, fit: BoxFit.cover)
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreenLight.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_florist_rounded,
                        color: AppColors.accentGreen,
                        size: 22,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.commonName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    species.scientificName,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.accentGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accentGreen),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sub-widget: buscador de catálogo inline.
class _CatalogPicker extends StatefulWidget {
  final ValueChanged<Specy> onSelected;
  final VoidCallback onBack;

  const _CatalogPicker({required this.onSelected, required this.onBack});

  @override
  State<_CatalogPicker> createState() => _CatalogPickerState();
}

class _CatalogPickerState extends State<_CatalogPicker> {
  List<Specy> _allSpecies = [];
  List<Specy> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = context.read<SpeciesRepository>();
    final species = await repo.getAll();
    species.sort(
      (a, b) =>
          a.commonName.toLowerCase().compareTo(b.commonName.toLowerCase()),
    );
    if (mounted) {
      setState(() {
        _allSpecies = species;
        _filtered = species;
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _allSpecies
          : _allSpecies
                .where(
                  (sp) =>
                      sp.commonName.toLowerCase().contains(q) ||
                      sp.scientificName.toLowerCase().contains(q) ||
                      sp.family.toLowerCase().contains(q),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back + search
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Volver',
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar planta...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLilac,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Species list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final sp = _filtered[index];
                    final img = SpeciesImages.getFirstImage(sp.scientificName);
                    return ListTile(
                      dense: true,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        sp.scientificName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => widget.onSelected(sp),
                        icon: const Icon(
                          Icons.add_circle_rounded,
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
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Sub-widget: cuestionario Akinator inline.
class _QuestionnairePicker extends StatefulWidget {
  final ValueChanged<Specy> onSelected;
  final VoidCallback onBack;
  final List<String> photoPaths;

  const _QuestionnairePicker({
    required this.onSelected,
    required this.onBack,
    required this.photoPaths,
  });

  @override
  State<_QuestionnairePicker> createState() => _QuestionnairePickerState();
}

class _QuestionnairePickerState extends State<_QuestionnairePicker> {
  IdentificationEngine? _engine;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    final db = context.read<AppDatabase>();
    final questions = await db.getAllQuestions();
    final optionsByQuestion = <String, List<QuestionOption>>{};
    for (final q in questions) {
      optionsByQuestion[q.id] = await db.getOptionsForQuestion(q.id);
    }
    final allTraits = await db.getAllTraits();
    final allSpecies = await db.getAllSpecies();

    if (mounted) {
      setState(() {
        _engine = IdentificationEngine(
          allQuestions: questions,
          optionsByQuestion: optionsByQuestion,
          allTraits: allTraits,
          allSpecies: allSpecies,
        );
        _loading = false;
      });
    }
  }

  void _selectOption(String questionId, String optionId) {
    setState(() {
      _engine!.applyAnswer(questionId, optionId);
    });
  }

  void _openPhoto(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _PhotoViewerScreen(photoPath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final engine = _engine!;

    // If we have candidates to show
    if (engine.isFinished) {
      return _buildResults(engine.candidates);
    }

    // Show current question
    final question = engine.getNextQuestion();
    if (question == null) {
      return _buildResults(engine.candidates);
    }

    final options = engine.getRelevantOptions(question.id);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Pregunta ${engine.questionsAsked + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '${engine.candidates.length} candidatos',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          question.questionText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        // Photo thumbnails for reference
        if (widget.photoPaths.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photoPaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openPhoto(context, widget.photoPaths[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.photoPaths[index]),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final opt = options[index];
              return OutlinedButton(
                onPressed: () => _selectOption(question.id, opt.id),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(opt.optionText),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults(List<Specy> candidates) {
    if (candidates.isEmpty) {
      return Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 8),
          const Text('No se encontraron coincidencias'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: widget.onBack, child: const Text('Volver')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Text(
              '${candidates.length} resultado${candidates.length > 1 ? 's' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: candidates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final sp = candidates[index];
              final img = SpeciesImages.getFirstImage(sp.scientificName);
              return ListTile(
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  sp.scientificName,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => widget.onSelected(sp),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Elegir', style: TextStyle(fontSize: 12)),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SpeciesDetailScreen(species: sp),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Visor de foto a pantalla completa con zoom.
class _PhotoViewerScreen extends StatefulWidget {
  final String photoPath;

  const _PhotoViewerScreen({required this.photoPath});

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen>
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
