import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tab de inicio / dashboard.
class DashboardTab extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const DashboardTab({super.key, this.onNavigate});

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
              title: 'Catalogo',
              subtitle: 'Explora todas las especies disponibles',
              color: AppColors.accentOrange,
              onTap: () => onNavigate?.call(3),
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
