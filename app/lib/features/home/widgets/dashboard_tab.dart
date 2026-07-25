import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/species_repository.dart';

/// Tab de inicio / dashboard con Kospi saludando.
class DashboardTab extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const DashboardTab({super.key, this.onNavigate});

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar base de datos'),
        content: const Text(
          '¿Estás seguro? Se borrarán todas tus observaciones y datos. '
          'Las especies semilla se volverán a cargar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repo = context.read<SpeciesRepository>();
              await repo.resetAndReseed();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Base de datos limpiada exitosamente'),
                  ),
                );
              }
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Kospi saludando
            Image.asset(
              'assets/images/Kospi/Kospi saludando.png',
              height: 180,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 56,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Speech bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLilac,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLilac.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '¡Hola! ¿Qué deseas hacer?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            // Action cards
            _QuickActionCard(
              icon: Icons.search_rounded,
              title: 'Identificar planta',
              subtitle: 'Responde preguntas para identificar una especie',
              color: AppColors.accentGreen,
              onTap: () => onNavigate?.call(1),
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.eco_rounded,
              title: 'Mis Plantas',
              subtitle: 'Mira las especies que desbloqueaste',
              color: AppColors.primaryLilac,
              onTap: () => onNavigate?.call(2),
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.menu_book_rounded,
              title: 'Catálogo',
              subtitle: 'Explora todas las especies disponibles',
              color: AppColors.accentOrange,
              onTap: () => onNavigate?.call(3),
            ),
            const SizedBox(height: 28),
            // Reset database
            TextButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Limpiar base de datos'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMedium,
              ),
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
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
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
                  color: color.withValues(alpha: 0.15),
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
