import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/observation_repository.dart';

/// Pantalla que muestra las observaciones guardadas localmente.
class ObservationsListScreen extends StatefulWidget {
  const ObservationsListScreen({super.key});

  @override
  State<ObservationsListScreen> createState() => _ObservationsListScreenState();
}

class _ObservationsListScreenState extends State<ObservationsListScreen> {
  List<Observation> _observations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    final repo = context.read<ObservationRepository>();
    final observations = await repo.getAll();
    if (mounted) {
      setState(() {
        _observations = observations;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Observaciones')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _observations.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadObservations,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _observations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _ObservationCard(
                          observation: _observations[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_camera_outlined,
              size: 64, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text('No hay observaciones aun',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Registra tu primera planta!',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final Observation observation;

  const _ObservationCard({required this.observation});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final file = File(observation.photoPath);
    final hasPhoto = file.existsSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          if (hasPhoto)
            Image.file(
              file,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 100,
              color: AppColors.surfaceLilac,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppColors.textLight),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and sync status
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14,
                        color: AppColors.textMedium),
                    const SizedBox(width: 4),
                    Text(dateFormat.format(observation.capturedAt),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMedium)),
                    const Spacer(),
                    _SyncBadge(status: observation.syncStatus),
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: AppColors.accentGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Lat: ${observation.latitude.toStringAsFixed(4)}, '
                      'Lon: ${observation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                // Notes
                if (observation.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(observation.notes,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final String status;

  const _SyncBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'synced':
        color = AppColors.success;
        icon = Icons.cloud_done_rounded;
        label = 'Sincronizado';
        break;
      case 'conflict':
        color = AppColors.error;
        icon = Icons.warning_rounded;
        label = 'Conflicto';
        break;
      default:
        color = AppColors.warning;
        icon = Icons.cloud_upload_rounded;
        label = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 10, color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
