import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/species_repository.dart';
import '../../catalog/screens/species_detail_screen.dart';

/// Lista de notificaciones de validación recibidas desde el servidor.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    context.read<NotificationRepository>().addListener(_onChanged);
  }

  @override
  void dispose() {
    context.read<NotificationRepository>().removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => _load();

  Future<void> _load() async {
    final repo = context.read<NotificationRepository>();
    final items = await repo.getAll();
    if (mounted) {
      setState(() {
        _notifications = items;
        _loading = false;
      });
    }
  }

  Future<void> _onTap(NotificationItem item) async {
    final repo = context.read<NotificationRepository>();

    if (item.isUnread) {
      try {
        await repo.markAsRead(item.id);
      } catch (_) {
        // El estado real baja luego por PowerSync; no bloqueamos el deep-link.
      }
    }

    if (!mounted) return;

    // Deep-link: validadas y corregidas abren el detalle de la especie.
    if (item.type == AppConstants.notificationValidated ||
        item.type == AppConstants.notificationSpeciesChanged) {
      final speciesId = item.newSpeciesId;
      if (speciesId == null || speciesId.isEmpty) return;

      final species = await context.read<SpeciesRepository>().getById(
        speciesId,
      );
      if (!mounted || species == null) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpeciesDetailScreen(species: species),
        ),
      );
    }
    // Rechazadas: se consultan desde "Mis Plantas" > Rechazadas.
  }

  @override
  Widget build(BuildContext context) {
    // Contenido del área derecha del shell (sin Scaffold/AppBar propios) para
    // que la barra lateral verde quede siempre visible. El título va en un
    // encabezado interno en lugar de un AppBar.
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Avisos',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? const Center(child: Text('No tenés avisos todavía'))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.accentGreen,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _NotificationCard(
                          item: _notifications[index],
                          onTap: () => _onTap(_notifications[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  (IconData, Color) get _iconData {
    switch (item.type) {
      case AppConstants.notificationValidated:
        return (Icons.check_circle_rounded, AppColors.success);
      case AppConstants.notificationRejected:
        return (Icons.error_outline_rounded, AppColors.error);
      case AppConstants.notificationSpeciesChanged:
        return (Icons.swap_horiz_rounded, AppColors.warning);
      default:
        return (Icons.notifications_rounded, AppColors.textLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconData;
    final isUnread = item.isUnread;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? color.withValues(alpha: 0.4)
                : AppColors.surfaceLilac,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _relativeDate(item.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) {
      return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    }
    if (diff.inHours >= 1) {
      return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    }
    if (diff.inMinutes >= 1) {
      return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    }
    return 'Recién';
  }
}
