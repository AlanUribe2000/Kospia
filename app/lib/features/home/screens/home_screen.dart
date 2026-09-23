import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/species_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/services/session_service.dart';
import '../../catalog/screens/catalog_screen.dart';
import '../../collection/screens/my_plants_screen.dart';
import '../../identify/screens/identify_flow_screen.dart';
import '../../ruler/screens/ruler_screen.dart';
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

    final authController = context.watch<AuthController>();

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail verde
          _buildNavRail(authController.session, authController.isLoading),
          // Content area
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                DashboardTab(onNavigate: _navigateTo),
                const IdentifyFlowScreen(),
                const MyPlantsScreen(),
                const CatalogScreen(),
                const RulerScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail(KospiaSession? session, bool authLoading) {
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
            // Logo Kospia: la flor sobre un cuadrado redondeado con el violeta
            // exacto del video (brandViolet #DEC6F0), el mismo tono que enmarca
            // al logo en la intro. El radio combina con las cards.
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandViolet,
                // Radio 16: igual que las cards del theme, para coherencia.
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/images/logo_symbol.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.eco_rounded,
                  color: AppColors.accentGreen,
                  size: 28,
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
            const SizedBox(height: 16),
            _AccountButton(
              session: session,
              onTap: authLoading ? null : () => _showAccountDialog(session),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            _NavItem(
              icon: Icons.straighten_rounded,
              label: 'REGLA',
              isSelected: _currentIndex == 4,
              onTap: () => _navigateTo(4),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountDialog(KospiaSession? session) async {
    if (session == null || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isLoggingOut = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cuenta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AccountAvatar(session: session, radius: 34),
                  const SizedBox(height: 16),
                  Text(
                    session.displayName.isEmpty
                        ? 'Usuario Kospia'
                        : session.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.email.isEmpty
                        ? 'Sin email disponible'
                        : session.email,
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoggingOut
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
                FilledButton.icon(
                  onPressed: isLoggingOut
                      ? null
                      : () async {
                          setDialogState(() {
                            isLoggingOut = true;
                            errorMessage = null;
                          });
                          try {
                            await context.read<AuthController>().logout();
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } catch (_) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isLoggingOut = false;
                                errorMessage =
                                    'No se pudo cerrar sesión. Intentá nuevamente.';
                              });
                            }
                          }
                        },
                  icon: isLoggingOut
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.session, required this.onTap});

  final KospiaSession? session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Cuenta',
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: _AccountAvatar(session: session, radius: 22),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.session, required this.radius});

  final KospiaSession? session;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = session?.photoUrl ?? '';
    final initial = (session?.displayName.isNotEmpty ?? false)
        ? session!.displayName.trim()[0].toUpperCase()
        : null;

    if (photoUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.brandViolet,
        child: initial == null
            ? const Icon(Icons.person_outline, color: AppColors.accentGreen)
            : Text(
                initial,
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.brandViolet,
      child: ClipOval(
        child: Image.network(
          photoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person_outline,
            size: radius,
            color: AppColors.accentGreen,
          ),
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
