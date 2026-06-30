import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/species_repository.dart';
import '../../catalog/screens/catalog_screen.dart';
import '../../collection/screens/new_observation_screen.dart';
import '../../collection/screens/observations_list_screen.dart';
import '../../identify/screens/identify_screen.dart';

/// Pantalla principal con bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedDatabase();
  }

  Future<void> _seedDatabase() async {
    final repo = context.read<SpeciesRepository>();
    await repo.seedIfEmpty();
    if (mounted) setState(() => _seeded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          CatalogScreen(),
          IdentifyScreen(),
          ObservationsListScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_rounded),
            label: 'Catalogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Identificar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_rounded),
            label: 'Registros',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewObservationScreen()),
          );
        },
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: const Text(
          'Registrar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Tab de inicio / dashboard.
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Kospia', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 4),
            Text(
              'Flora Patagonica',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.accentGreen),
            ),
            const SizedBox(height: 32),
            _QuickActionCard(
              icon: Icons.camera_alt_rounded,
              title: 'Nueva observacion',
              subtitle: 'Saca una foto y registra ubicacion',
              color: AppColors.accentOrange,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NewObservationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.search_rounded,
              title: 'Identificar planta',
              subtitle: 'Responde preguntas para identificar una especie',
              color: AppColors.accentGreen,
              onTap: () {
                // Navigate to identify tab
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.local_florist_rounded,
              title: 'Catalogo de especies',
              subtitle: '6 especies de la estepa patagonica',
              color: AppColors.primaryLilac,
              onTap: () {
                // Navigate to catalog tab
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
