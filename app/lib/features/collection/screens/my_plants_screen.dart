import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/observation_repository.dart';
import '../../../data/repositories/species_repository.dart';
import 'plant_detail_screen.dart';

/// Pantalla "Mis Plantas" - grid de especies con estado bloqueado/desbloqueado.
/// Se actualiza automáticamente al desbloquear una planta y soporta pull-to-refresh.
class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  List<Specy> _allSpecies = [];
  List<Specy> _filtered = [];
  List<Observation> _observations = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilter);
    // Listen for new observations (auto-refresh)
    context.read<ObservationRepository>().addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<ObservationRepository>().removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _loadData();
  }

  Future<void> _loadData() async {
    final speciesRepo = context.read<SpeciesRepository>();
    final obsRepo = context.read<ObservationRepository>();
    final species = await speciesRepo.getAll();
    // Ordenar alfabéticamente por nombre común
    species.sort(
      (a, b) =>
          a.commonName.toLowerCase().compareTo(b.commonName.toLowerCase()),
    );
    final observations = await obsRepo.getAll();
    if (mounted) {
      setState(() {
        _allSpecies = species;
        _observations = observations;
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
        _filtered = _allSpecies.where((sp) {
          return sp.commonName.toLowerCase().contains(query) ||
              sp.scientificName.toLowerCase().contains(query) ||
              sp.family.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  /// Returns the first observation for a given species, or null if not unlocked.
  Observation? _getObservationForSpecies(String speciesId) {
    try {
      return _observations.firstWhere((o) => o.speciesId == speciesId);
    } catch (_) {
      return null;
    }
  }

  int get _unlockedCount {
    final unlockedIds = _observations
        .where((o) => o.speciesId != null)
        .map((o) => o.speciesId!)
        .toSet();
    return unlockedIds.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
            Text(
              '$_unlockedCount de ${_allSpecies.length} desbloqueadas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            // Search field
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
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final species = _filtered[index];
                    final observation = _getObservationForSpecies(species.id);
                    final isUnlocked = observation != null;

                    return _PlantCard(
                      species: species,
                      observation: observation,
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlantDetailScreen(
                                    species: species,
                                    observation: observation,
                                  ),
                                ),
                              );
                            }
                          : null,
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
}

class _PlantCard extends StatelessWidget {
  final Specy species;
  final Observation? observation;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _PlantCard({
    required this.species,
    required this.observation,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.surfaceLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked
              ? Border.all(color: AppColors.accentGreenLight, width: 2)
              : Border.all(color: AppColors.surfaceLilac, width: 1),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Plant icon or photo thumbnail
              _buildIcon(),
              const SizedBox(height: 10),
              // Name or ???
              if (isUnlocked) ...[
                Text(
                  species.commonName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  species.scientificName,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                const Text(
                  '???',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
                const Text(
                  'Por identificar',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isUnlocked && observation != null) {
      final file = File(observation!.photoPath);
      if (file.existsSync()) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.accentGreenLight, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        );
      }
    }

    // Locked or no photo
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.accentGreenLight.withValues(alpha: 0.15)
                : AppColors.surfaceLilac,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(
            Icons.local_florist_rounded,
            size: 32,
            color: isUnlocked ? AppColors.accentGreen : AppColors.textLight,
          ),
        ),
        if (!isUnlocked)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.locked,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.lock, size: 11, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
