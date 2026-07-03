import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/species_repository.dart';
import '../../catalog/screens/catalog_screen.dart';
import '../../collection/screens/my_plants_screen.dart';
import '../../identify/screens/identify_flow_screen.dart';
import '../widgets/dashboard_tab.dart';

/// Pantalla principal con NavigationRail vertical verde a la izquierda.
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

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail verde
          _buildNavRail(),
          // Content area
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                DashboardTab(onNavigate: _navigateTo),
                const IdentifyFlowScreen(),
                const MyPlantsScreen(),
                const CatalogScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail() {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo Kospia
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'KOSPIA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),
            // Nav items
            _NavItem(
              icon: Icons.home_rounded,
              label: 'HOME',
              isSelected: _currentIndex == 0,
              onTap: () => _navigateTo(0),
            ),
            const SizedBox(height: 16),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'IDENTIFICAR',
              isSelected: _currentIndex == 1,
              onTap: () => _navigateTo(1),
            ),
            const SizedBox(height: 16),
            _NavItem(
              icon: Icons.eco_rounded,
              label: 'MIS PLANTAS',
              isSelected: _currentIndex == 2,
              onTap: () => _navigateTo(2),
            ),
            const SizedBox(height: 16),
            _NavItem(
              icon: Icons.menu_book_rounded,
              label: 'CATALOGO',
              isSelected: _currentIndex == 3,
              onTap: () => _navigateTo(3),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 22)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
