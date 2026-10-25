import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/species_images.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/observation_repository.dart';
import '../../../data/repositories/species_repository.dart';
import '../../auth/services/session_service.dart';
import '../widgets/photo_thumbnail.dart';

/// Retorna las partes requeridas para completar una especie.
/// Espinas son opcionales (no bloquean completado). Fruto solo si es visible.
List<String> requiredPartsForSpecies(Specy species) {
  final parts = <String>['general', 'hoja', 'flor'];
  if (species.hasFruit) parts.add('fruto');
  return parts;
}

/// Retorna todas las partes visibles para una especie (requeridas + opcionales).
/// Incluye espinas si la planta las tiene, aunque no sean obligatorias.
List<String> allVisiblePartsForSpecies(Specy species) {
  final parts = <String>['general', 'hoja'];
  if (species.hasSpines) parts.add('espinas');
  parts.add('flor');
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

/// Pantalla "Mis Plantas" con progreso dinámico y accesos a pendientes y
/// rechazadas. La grilla solo cuenta observaciones validadas.
class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key, this.onNavigate});

  /// Permite enrutar "Volver a intentar" a la pestaña Identificar del shell.
  final void Function(int)? onNavigate;

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

/// Sub-vista interna del panel "Mis Plantas". Permite alternar entre la grilla
/// y las listas de pendientes/rechazadas en el MISMO panel, sin Navigator.push,
/// para que la barra lateral verde (fuera de esta pantalla) quede siempre
/// visible.
enum _MyPlantsView { grid, pending, rejected }

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  List<Specy> _allSpecies = [];
  List<Specy> _filtered = [];
  Map<String, Set<String>> _progressMap = {};
  int _pendingCount = 0;
  int _rejectedCount = 0;
  bool _loading = true;
  bool _sortByProgress = false;
  _MyPlantsView _view = _MyPlantsView.grid;
  final TextEditingController _searchController = TextEditingController();

  // Suscripciones reactivas a PowerSync: se re-emiten ante escrituras locales
  // Y ante el sync entrante del servidor, por lo que "Mis Plantas" se refresca
  // solo sin pull-to-refresh. Ver item H del diagnóstico.
  StreamSubscription<Map<String, Set<String>>>? _progressSub;
  StreamSubscription<int>? _pendingSub;
  StreamSubscription<int>? _rejectedSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _progressSub?.cancel();
    _pendingSub?.cancel();
    _rejectedSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final speciesRepo = context.read<SpeciesRepository>();
    final obsRepo = context.read<ObservationRepository>();
    final sessionService = context.read<SessionService>();

    final species = await speciesRepo.getAll();
    species.sort(
      (a, b) =>
          a.commonName.toLowerCase().compareTo(b.commonName.toLowerCase()),
    );

    final session = await sessionService.loadSession();
    final userId = session?.userId ?? '';

    if (mounted) {
      setState(() {
        _allSpecies = species;
        _loading = false;
      });
      _applyFilter();
    }

    // (Re)suscribirse a los streams reactivos del repositorio.
    _progressSub?.cancel();
    _pendingSub?.cancel();
    _rejectedSub?.cancel();
    _progressSub = obsRepo.watchPartsGroupedBySpecies().listen((
      partsBySpecies,
    ) {
      if (!mounted) return;
      setState(() => _progressMap = Map.of(partsBySpecies));
      _applyFilter();
    });
    if (userId.isNotEmpty) {
      _pendingSub = obsRepo.watchPendingCount(userId).listen((count) {
        if (mounted) setState(() => _pendingCount = count);
      });
      _rejectedSub = obsRepo.watchRejectedCount(userId).listen((count) {
        if (mounted) setState(() => _rejectedCount = count);
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_allSpecies);
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
      if (_sortByProgress) {
        _filtered.sort((a, b) {
          final partsA = _progressMap[a.id] ?? {};
          final partsB = _progressMap[b.id] ?? {};
          final progressA = progressForSpecies(a, partsA);
          final progressB = progressForSpecies(b, partsB);
          // Descendente por progreso
          final cmp = progressB.compareTo(progressA);
          if (cmp != 0) return cmp;
          // A igualdad, alfabético por nombre
          return a.commonName.toLowerCase().compareTo(
            b.commonName.toLowerCase(),
          );
        });
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

    // Sub-vistas Pendientes/Rechazadas dentro del mismo panel. El 'atrás'
    // (encabezado interno y gesto Android) vuelve a la grilla sin salir del
    // shell, por lo que la barra lateral nunca se tapa.
    if (_view == _MyPlantsView.pending) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          setState(() => _view = _MyPlantsView.grid);
        },
        child: _PendingListScreen(
          onBack: () => setState(() => _view = _MyPlantsView.grid),
        ),
      );
    }
    if (_view == _MyPlantsView.rejected) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          setState(() => _view = _MyPlantsView.grid);
        },
        child: _RejectedListScreen(
          onBack: () => setState(() => _view = _MyPlantsView.grid),
        ),
      );
    }

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$_completedCount de ${_allSpecies.length} completadas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _sortByProgress = !_sortByProgress);
                    _applyFilter();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _sortByProgress
                          ? AppColors.accentGreen.withValues(alpha: 0.1)
                          : AppColors.surfaceLilac,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _sortByProgress
                            ? AppColors.accentGreenLight
                            : AppColors.surfaceLilac,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 16,
                          color: _sortByProgress
                              ? AppColors.accentGreen
                              : AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sortByProgress ? 'Por progreso' : 'Alfabético',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _sortByProgress
                                ? AppColors.accentGreen
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            // Chips de estado: pendientes y rechazadas (ocultos si cuenta 0).
            _buildStatusChips(),
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

  Widget _buildStatusChips() {
    if (_pendingCount == 0 && _rejectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (_pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _StatusChip(
                label: 'Pendientes',
                count: _pendingCount,
                color: AppColors.warning,
                icon: Icons.schedule_rounded,
                onTap: _openPendingList,
              ),
            ),
          if (_rejectedCount > 0)
            _StatusChip(
              label: 'Rechazadas',
              count: _rejectedCount,
              color: AppColors.error,
              icon: Icons.error_outline_rounded,
              onTap: _openRejectedList,
            ),
        ],
      ),
    );
  }

  void _openPendingList() {
    setState(() => _view = _MyPlantsView.pending);
  }

  void _openRejectedList() {
    setState(() => _view = _MyPlantsView.rejected);
  }
}

/// Chip de estado (pendientes/rechazadas) con contador.
class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
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
          cacheWidth: 192,
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
  // Fotos agrupadas por parte; se actualiza solo vía Stream (item H).
  Map<String, List<ObservationPhoto>> _photosByPart = {};

  Map<String, List<ObservationPhoto>> _groupByPart(
    List<ObservationPhoto> photos,
  ) {
    final grouped = <String, List<ObservationPhoto>>{};
    for (final photo in photos) {
      grouped.putIfAbsent(photo.plantPart, () => []).add(photo);
    }
    return grouped;
  }

  void _openFullPhoto(String path) {
    // Gather all user photos for slide support
    final allPhotoPaths = _photosByPart.values
        .expand((photos) => photos.map((p) => p.photoPath))
        .toList();
    final index = allPhotoPaths.indexOf(path);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullPhotoViewer(
          photoPaths: allPhotoPaths,
          initialIndex: index >= 0 ? index : 0,
        ),
      ),
    );
  }

  void _openCatalogImage(String assetPath) {
    final catalogImages = SpeciesImages.getImages(
      widget.species.scientificName,
    );
    final index = catalogImages.indexOf(assetPath);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullAssetViewer(
          assetPaths: catalogImages,
          initialIndex: index >= 0 ? index : 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = SpeciesImages.getFirstImage(widget.species.scientificName);
    final catalogImages = SpeciesImages.getImages(
      widget.species.scientificName,
    );
    final requiredParts = requiredPartsForSpecies(widget.species);
    final allVisible = allVisiblePartsForSpecies(widget.species);
    final progress = progressForSpecies(widget.species, widget.partsCompleted);
    final isComplete = isSpeciesComplete(widget.species, widget.partsCompleted);

    final partsMeta = <(String, String, IconData)>[
      ('general', 'General', Icons.nature_rounded),
      ('hoja', 'Hoja', Icons.eco_rounded),
      ('espinas', 'Espinas', Icons.grass_rounded),
      ('flor', 'Flor', Icons.local_florist_rounded),
      ('fruto', 'Fruto', Icons.spa_rounded),
    ];

    // Show all visible parts (required + optional like espinas)
    final visibleParts = partsMeta
        .where((p) => allVisible.contains(p.$1))
        .toList();

    final repo = context.read<ObservationRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.species.commonName)),
      body: StreamBuilder<List<ObservationPhoto>>(
        stream: repo.watchAllPhotosForSpecies(widget.species.id),
        builder: (context, snapshot) {
          _photosByPart = _groupByPart(
            snapshot.data ?? const <ObservationPhoto>[],
          );
          return SingleChildScrollView(
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
                              cacheWidth: 360,
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...(visibleParts.map((part) {
                  final isDone = widget.partsCompleted.contains(part.$1);
                  final userPhotos = _photosByPart[part.$1] ?? [];
                  final isOptional = !requiredParts.contains(part.$1);
                  return _PartSlot(
                    partLabel: isOptional ? '${part.$2} (opcional)' : part.$2,
                    partIcon: part.$3,
                    isDone: isDone,
                    isOptional: isOptional,
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
                            cacheWidth: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PartSlot extends StatelessWidget {
  final String partLabel;
  final IconData partIcon;
  final bool isDone;
  final bool isOptional;
  final List<ObservationPhoto> userPhotos;
  final ValueChanged<String> onTapPhoto;

  const _PartSlot({
    required this.partLabel,
    required this.partIcon,
    required this.isDone,
    this.isOptional = false,
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
                      : isOptional
                      ? Icons.remove_circle_outline_rounded
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
/// Visor fullscreen para fotos del usuario (File) con slide.
class _FullPhotoViewer extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;
  const _FullPhotoViewer({required this.photoPaths, this.initialIndex = 0});

  @override
  State<_FullPhotoViewer> createState() => _FullPhotoViewerState();
}

class _FullPhotoViewerState extends State<_FullPhotoViewer>
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

/// Visor fullscreen para fotos del catálogo (Asset) con slide.
class _FullAssetViewer extends StatefulWidget {
  final List<String> assetPaths;
  final int initialIndex;
  const _FullAssetViewer({required this.assetPaths, this.initialIndex = 0});

  @override
  State<_FullAssetViewer> createState() => _FullAssetViewerState();
}

class _FullAssetViewerState extends State<_FullAssetViewer>
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
        title: widget.assetPaths.length > 1
            ? Text(
                '${_currentPage + 1} / ${widget.assetPaths.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.assetPaths.length,
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
                child: Image.asset(
                  widget.assetPaths[index],
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

/// Pantalla que muestra todas las identificaciones en estado pendiente
/// (incluidas las que aún no tienen especie propuesta).
class _PendingListScreen extends StatefulWidget {
  const _PendingListScreen({required this.onBack});

  /// Vuelve a la grilla de "Mis Plantas" (cambia el sub-estado del panel) en
  /// lugar de Navigator.pop, para no tapar la barra lateral.
  final VoidCallback onBack;

  @override
  State<_PendingListScreen> createState() => _PendingListScreenState();
}

class _PendingListScreenState extends State<_PendingListScreen> {
  // userId se resuelve una vez; el Stream del repo refresca automáticamente
  // ante escrituras locales y sync entrante (item H).
  Future<String> _userIdFuture = Future.value('');

  @override
  void initState() {
    super.initState();
    _userIdFuture = _resolveUserId();
  }

  Future<String> _resolveUserId() async {
    final session = await context.read<SessionService>().loadSession();
    return session?.userId ?? '';
  }

  void _openPhoto(List<PhotoStatusItem> photos, String photoId) {
    final item = photos.firstWhere(
      (p) => p.photo.id == photoId,
      orElse: () => photos.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullPhotoByIdViewer(
          photoId: item.photo.id,
          localPath: item.photo.photoPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ObservationRepository>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubViewHeader(title: 'Pendientes', onBack: widget.onBack),
          Expanded(
            child: FutureBuilder<String>(
              future: _userIdFuture,
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userId = userSnap.data!;
                if (userId.isEmpty) {
                  return const Center(
                    child: Text('No hay fotografías pendientes'),
                  );
                }
                return StreamBuilder<List<PhotoStatusItem>>(
                  stream: repo.watchPendingPhotos(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final photos = snapshot.data!;
                    if (photos.isEmpty) {
                      return const Center(
                        child: Text('No hay fotografías pendientes'),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: photos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _PhotoStatusCard(
                          item: photos[index],
                          isRejected: false,
                          onTapPhoto: (id) => _openPhoto(photos, id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla que muestra las identificaciones rechazadas con su motivo.
class _RejectedListScreen extends StatefulWidget {
  const _RejectedListScreen({required this.onBack});

  /// Vuelve a la grilla de "Mis Plantas" (cambia el sub-estado del panel) en
  /// lugar de Navigator.pop, para no tapar la barra lateral.
  final VoidCallback onBack;

  @override
  State<_RejectedListScreen> createState() => _RejectedListScreenState();
}

class _RejectedListScreenState extends State<_RejectedListScreen> {
  // userId se resuelve una vez; el Stream del repo refresca automáticamente
  // ante escrituras locales, sync entrante y el soft-dismiss local (item H/I).
  Future<String> _userIdFuture = Future.value('');

  @override
  void initState() {
    super.initState();
    _userIdFuture = _resolveUserId();
  }

  Future<String> _resolveUserId() async {
    final session = await context.read<SessionService>().loadSession();
    return session?.userId ?? '';
  }

  void _openPhoto(List<PhotoStatusItem> photos, String photoId) {
    final item = photos.firstWhere(
      (p) => p.photo.id == photoId,
      orElse: () => photos.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullPhotoByIdViewer(
          photoId: item.photo.id,
          localPath: item.photo.photoPath,
        ),
      ),
    );
  }

  /// Oculta localmente todas las rechazadas (soft-dismiss). No borra nada del
  /// servidor; el Stream re-emite y la lista se vacía sola.
  Future<void> _confirmClear(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar rechazadas'),
        content: const Text(
          '¿Querés ocultar todas las fotografías rechazadas? '
          'Solo se ocultan en este dispositivo, no se borran del servidor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Limpiar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<ObservationRepository>().dismissAllRejected(userId);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ObservationRepository>();
    return SafeArea(
      child: FutureBuilder<String>(
        future: _userIdFuture,
        builder: (context, userSnap) {
          if (!userSnap.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubViewHeader(title: 'Rechazadas', onBack: widget.onBack),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }
          final userId = userSnap.data!;
          if (userId.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubViewHeader(title: 'Rechazadas', onBack: widget.onBack),
                const Expanded(
                  child: Center(child: Text('No hay fotografías rechazadas')),
                ),
              ],
            );
          }
          return StreamBuilder<List<PhotoStatusItem>>(
            stream: repo.watchRejectedPhotos(userId),
            builder: (context, snapshot) {
              final photos = snapshot.data ?? const <PhotoStatusItem>[];
              final hasPhotos = photos.isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubViewHeader(
                    title: 'Rechazadas',
                    onBack: widget.onBack,
                    action: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Limpiar rechazadas',
                      onPressed: hasPhotos ? () => _confirmClear(userId) : null,
                    ),
                  ),
                  Expanded(
                    child: !snapshot.hasData
                        ? const Center(child: CircularProgressIndicator())
                        : !hasPhotos
                        ? const Center(
                            child: Text('No hay fotografías rechazadas'),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: photos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _PhotoStatusCard(
                                item: photos[index],
                                isRejected: true,
                                onTapPhoto: (id) => _openPhoto(photos, id),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Encabezado interno para las sub-vistas del panel (Pendientes/Rechazadas).
/// Reemplaza al AppBar de pantalla completa: trae el botón 'atrás' (que cambia
/// el sub-estado, no hace Navigator.pop) y evita duplicar el chrome del shell.
class _SubViewHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? action;

  const _SubViewHeader({
    required this.title,
    required this.onBack,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
      child: Row(
        children: [
          BackButton(onPressed: onBack),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Etiqueta legible de la parte de la planta.
String _plantPartLabel(String part) {
  switch (part) {
    case 'general':
      return 'General';
    case 'hoja':
      return 'Hoja';
    case 'flor':
      return 'Flor';
    case 'espinas':
      return 'Espinas';
    case 'fruto':
      return 'Fruto';
    default:
      return part;
  }
}

/// Tarjeta por-foto para las vistas Pendientes y Rechazadas.
/// Muestra la parte, la miniatura, la fecha y — en rechazadas — el comentario.
class _PhotoStatusCard extends StatelessWidget {
  final PhotoStatusItem item;
  final bool isRejected;
  final ValueChanged<String> onTapPhoto;

  const _PhotoStatusCard({
    required this.item,
    required this.isRejected,
    required this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final photo = item.photo;
    final hasSpecies = item.speciesCommonName != null;
    final notes = item.observationNotes.trim();
    final date = photo.capturedAt;
    final dateStr =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    final comment = item.photo.validationComment?.trim();
    final statusColor = isRejected ? AppColors.error : AppColors.warning;
    final statusLabel = isRejected ? 'Rechazada' : 'En revisión';
    final statusIcon = isRejected
        ? Icons.error_outline_rounded
        : Icons.schedule_rounded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => onTapPhoto(photo.id),
                  child: PhotoThumbnail(
                    photoId: photo.id,
                    localPath: photo.photoPath,
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasSpecies) ...[
                        Text(
                          item.speciesCommonName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        if (item.speciesScientificName != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            item.speciesScientificName!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                      ] else ...[
                        Text(
                          notes.isNotEmpty
                              ? 'Sin especie — $notes'
                              : 'Sin especie',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        _plantPartLabel(photo.plantPart),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Capturada el $dateStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isRejected) ...[
              const SizedBox(height: 10),
              Text(
                comment != null && comment.isNotEmpty
                    ? comment
                    : 'Sin motivo especificado.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
