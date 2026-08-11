import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/species_images.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/observation_repository.dart';
import '../../../data/repositories/species_repository.dart';

/// Retorna las partes requeridas para completar una especie.
/// No pide espinas si la planta no tiene, ni fruto si no es visible.
List<String> requiredPartsForSpecies(Specy species) {
  final parts = <String>['general', 'hoja', 'flor'];
  if (species.hasSpines) parts.add('espinas');
  if (species.hasFruit) parts.add('fruto');
  return parts;
}

/// Calcula el progreso (0.0 - 1.0) según partes requeridas.
double progressForSpecies(Specy species, Set<String> partsCompleted) {
  final required = requiredPartsForSpecies(species);
  if (required.isEmpty) return 1.0;
  final done = partsCompleted.where((p) => required.contains(p)).length;
  return done / required.length;
}

bool isSpeciesComplete(Specy species, Set<String> partsCompleted) {
  final required = requiredPartsForSpecies(species);
  return required.every((p) => partsCompleted.contains(p));
}

/// Pantalla "Mis Plantas" con progreso dinámico y sección "sin identificar".
class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  List<Specy> _allSpecies = [];
  List<Specy> _filtered = [];
  Map<String, Set<String>> _progressMap = {};
  List<Observation> _unidentifiedObs = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilter);
    context.read<ObservationRepository>().addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<ObservationRepository>().removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => _loadData();

  Future<void> _loadData() async {
    final speciesRepo = context.read<SpeciesRepository>();
    final obsRepo = context.read<ObservationRepository>();

    final species = await speciesRepo.getAll();
    species.sort(
      (a, b) =>
          a.commonName.toLowerCase().compareTo(b.commonName.toLowerCase()),
    );

    final observations = await obsRepo.getAll();
    final progressMap = <String, Set<String>>{};
    final unidentified = <Observation>[];

    for (final obs in observations) {
      if (obs.speciesId == 'unidentified') {
        unidentified.add(obs);
      } else {
        final parts = await obsRepo.getPartsForSpecies(obs.speciesId);
        if (parts.isNotEmpty) {
          progressMap[obs.speciesId] = parts;
        }
      }
    }

    if (mounted) {
      setState(() {
        _allSpecies = species;
        _progressMap = progressMap;
        _unidentifiedObs = unidentified;
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _allSpecies;
      } else {
        _filtered = _allSpecies
            .where(
              (sp) =>
                  sp.commonName.toLowerCase().contains(query) ||
                  sp.scientificName.toLowerCase().contains(query) ||
                  sp.family.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  int get _completedCount {
    int count = 0;
    for (final sp in _allSpecies) {
      final parts = _progressMap[sp.id] ?? {};
      if (isSpeciesComplete(sp, parts)) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Mis Plantas',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$_completedCount de ${_allSpecies.length} completadas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, especie o familia...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLilac,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Unidentified section
            if (_unidentifiedObs.isNotEmpty && _searchController.text.isEmpty)
              _UnidentifiedBanner(count: _unidentifiedObs.length),
            // Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.accentGreen,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final species = _filtered[index];
                    final parts = _progressMap[species.id] ?? {};
                    return _PlantCard(
                      species: species,
                      partsCompleted: parts,
                      onTap: () => _openDetail(species, parts),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Specy species, Set<String> parts) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _PlantProgressDetail(species: species, partsCompleted: parts),
      ),
    );
  }
}

class _UnidentifiedBanner extends StatelessWidget {
  final int count;
  const _UnidentifiedBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.help_outline_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count registro${count > 1 ? 's' : ''} sin identificar',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Specy species;
  final Set<String> partsCompleted;
  final VoidCallback onTap;

  const _PlantCard({
    required this.species,
    required this.partsCompleted,
    required this.onTap,
  });

  double get progress => progressForSpecies(species, partsCompleted);
  bool get isComplete => isSpeciesComplete(species, partsCompleted);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isComplete ? AppColors.surfaceLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComplete
                ? AppColors.accentGreenLight
                : AppColors.surfaceLilac,
            width: isComplete ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(),
              const SizedBox(height: 8),
              Text(
                species.commonName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isComplete ? AppColors.textDark : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                species.scientificName,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 10,
                  color: isComplete
                      ? AppColors.textMedium
                      : AppColors.textLight.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final img = SpeciesImages.getFirstImage(species.scientificName);
    Widget imageWidget;
    if (img != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          img,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderIcon(),
        ),
      );
    } else {
      imageWidget = _placeholderIcon();
    }
    if (!isComplete) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _placeholderIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceLilac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.local_florist_rounded,
        size: 28,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildProgressBar() {
    final percent = (progress * 100).toInt();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isComplete ? AppColors.accentGreen : AppColors.textLight,
              ),
            ),
            if (isComplete)
              const Icon(
                Icons.check_circle,
                size: 12,
                color: AppColors.accentGreen,
              ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.surfaceLilac,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? AppColors.accentGreen : AppColors.accentGreenLight,
            ),
          ),
        ),
      ],
    );
  }
}

/// Detalle de progreso: muestra partes requeridas y fotos del usuario.
class _PlantProgressDetail extends StatefulWidget {
  final Specy species;
  final Set<String> partsCompleted;

  const _PlantProgressDetail({
    required this.species,
    required this.partsCompleted,
  });

  @override
  State<_PlantProgressDetail> createState() => _PlantProgressDetailState();
}

class _PlantProgressDetailState extends State<_PlantProgressDetail> {
  Map<String, List<ObservationPhoto>> _photosByPart = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final repo = context.read<ObservationRepository>();
    final photos = await repo.getAllPhotosForSpecies(widget.species.id);
    final grouped = <String, List<ObservationPhoto>>{};
    for (final photo in photos) {
      grouped.putIfAbsent(photo.plantPart, () => []).add(photo);
    }
    if (mounted) setState(() => _photosByPart = grouped);
  }

  void _openFullPhoto(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullPhotoViewer(photoPath: path)),
    );
  }

  void _openCatalogImage(String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullAssetViewer(assetPath: assetPath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = SpeciesImages.getFirstImage(widget.species.scientificName);
    final catalogImages = SpeciesImages.getImages(
      widget.species.scientificName,
    );
    final requiredParts = requiredPartsForSpecies(widget.species);
    final progress = progressForSpecies(widget.species, widget.partsCompleted);
    final isComplete = isSpeciesComplete(widget.species, widget.partsCompleted);

    final partsMeta = <(String, String, IconData)>[
      ('general', 'General', Icons.nature_rounded),
      ('hoja', 'Hoja', Icons.eco_rounded),
      ('espinas', 'Espinas', Icons.grass_rounded),
      ('flor', 'Flor', Icons.local_florist_rounded),
      ('fruto', 'Fruto', Icons.spa_rounded),
    ];

    // Only show parts that are required for this species
    final visibleParts = partsMeta
        .where((p) => requiredParts.contains(p.$1))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.species.commonName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: GestureDetector(
                onTap: img != null ? () => _openCatalogImage(img) : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: img != null
                      ? Image.asset(
                          img,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLilac,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_florist_rounded,
                            size: 48,
                            color: AppColors.textLight,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                widget.species.commonName,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            Center(
              child: Text(
                widget.species.scientificName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Progress
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceLilac,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete
                            ? AppColors.accentGreen
                            : AppColors.accentGreenLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isComplete
                        ? AppColors.accentGreen
                        : AppColors.textMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isComplete
                  ? '¡Planta completa!'
                  : 'Faltan ${requiredParts.where((p) => !widget.partsCompleted.contains(p)).length} parte${requiredParts.where((p) => !widget.partsCompleted.contains(p)).length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: isComplete
                    ? AppColors.accentGreen
                    : AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            // Parts
            Text(
              'Partes requeridas',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...(visibleParts.map((part) {
              final isDone = widget.partsCompleted.contains(part.$1);
              final userPhotos = _photosByPart[part.$1] ?? [];
              return _PartSlot(
                partLabel: part.$2,
                partIcon: part.$3,
                isDone: isDone,
                userPhotos: userPhotos,
                onTapPhoto: _openFullPhoto,
              );
            })),
            const SizedBox(height: 24),
            // Catalog images
            if (catalogImages.isNotEmpty) ...[
              Text(
                'Fotos del catálogo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: catalogImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _openCatalogImage(catalogImages[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        catalogImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
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
}

class _PartSlot extends StatelessWidget {
  final String partLabel;
  final IconData partIcon;
  final bool isDone;
  final List<ObservationPhoto> userPhotos;
  final ValueChanged<String> onTapPhoto;

  const _PartSlot({
    required this.partLabel,
    required this.partIcon,
    required this.isDone,
    required this.userPhotos,
    required this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.accentGreen.withValues(alpha: 0.08)
              : AppColors.surfaceLilac.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? AppColors.accentGreenLight : AppColors.surfaceLilac,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  partIcon,
                  size: 20,
                  color: isDone ? AppColors.accentGreen : AppColors.textLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    partLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDone ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
                if (userPhotos.isNotEmpty)
                  Text(
                    '${userPhotos.length} foto${userPhotos.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isDone ? AppColors.accentGreen : AppColors.textLight,
                  size: 20,
                ),
              ],
            ),
            if (userPhotos.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: userPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final photo = userPhotos[index];
                    return GestureDetector(
                      onTap: () => onTapPhoto(photo.photoPath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(photo.photoPath),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: AppColors.surfaceLilac,
                            child: const Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Visor fullscreen para fotos del usuario (File).
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

/// Visor fullscreen para fotos del catálogo (Asset).
class _FullAssetViewer extends StatefulWidget {
  final String assetPath;
  const _FullAssetViewer({required this.assetPath});

  @override
  State<_FullAssetViewer> createState() => _FullAssetViewerState();
}

class _FullAssetViewerState extends State<_FullAssetViewer>
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
      ),
      body: GestureDetector(
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {},
        child: InteractiveViewer(
          transformationController: _tc,
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: Image.asset(
              widget.assetPath,
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
