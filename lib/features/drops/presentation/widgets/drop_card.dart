import 'package:flutter/material.dart';
import 'package:art_drop_finder/core/utils/platform_image.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';

class DropCard extends StatelessWidget {
  final ArtDrop drop;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onMarkAllFound;
  final VoidCallback onEdit;

  const DropCard({
    super.key,
    required this.drop,
    required this.onDecrement,
    required this.onIncrement,
    required this.onMarkAllFound,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrement = drop.dropsAvailable > 0;
    const maxDropsTotal = 10000;
    final canIncrement = drop.dropsAvailable < maxDropsTotal;
    final publicLocation = drop.allFound
        ? drop.locationText
        : 'Versteckt, bis alle Drops gefunden sind.';

    final hasDropImage = canShowPlatformImage(drop.dropImagePath);
    final hasEnvironmentImage = canShowPlatformImage(drop.environmentImagePath);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasDropImage) ...[
              Text('Drop-Foto', style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              buildPlatformImage(
                drop.dropImagePath!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
            if (hasEnvironmentImage) ...[
              if (hasDropImage) const SizedBox(height: 12),
              Text('Umgebungsfoto', style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              buildPlatformImage(
                drop.environmentImagePath!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
            if (hasDropImage || hasEnvironmentImage) const SizedBox(height: 12),
            Text(drop.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(drop.description),
            const SizedBox(height: 8),
            Text('Erstellt: ${_formatDate(drop.createdAt)}'),
            const SizedBox(height: 8),
            Text(
              'Verfuegbare Drops: ${drop.dropsAvailable}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('Oeffentlicher Ort: $publicLocation'),
            Text(
              'Künstler-Standort: ${drop.locationText}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: canDecrement ? onDecrement : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${drop.dropsAvailable}'),
                IconButton(
                  onPressed: canIncrement ? onIncrement : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Drop bearbeiten'),
                ),
                TextButton(
                  onPressed: drop.allFound ? null : onMarkAllFound,
                  child: const Text('Alle gefunden markieren'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, '0');
    final local = dateTime.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
