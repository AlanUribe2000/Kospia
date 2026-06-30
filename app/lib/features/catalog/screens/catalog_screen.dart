import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/species_repository.dart';
import 'species_detail_screen.dart';

/// Pantalla de catalogo de especies.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Specy> _species = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    final repo = context.read<SpeciesRepository>();
    final species = await repo.getAll();
    if (mounted) {
      setState(() {
        _species = species;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Catalogo', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 4),
            Text(
              'Especies de flora patagonica',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _species.isEmpty
                  ? const Center(child: Text('No hay especies cargadas'))
                  : ListView.separated(
                      itemCount: _species.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final sp = _species[index];
                        return _SpeciesCard(
                          species: sp,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SpeciesDetailScreen(species: sp),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final Specy species;
  final VoidCallback onTap;

  const _SpeciesCard({required this.species, required this.onTap});

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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: AppColors.accentGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.commonName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      species.scientificName,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      species.family,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
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
