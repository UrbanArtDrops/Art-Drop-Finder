import 'package:flutter/material.dart';
import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';
import 'package:art_drop_finder/features/drops/presentation/pages/edit_drop_page.dart';
import 'package:art_drop_finder/features/drops/presentation/widgets/drop_card.dart';

class ManageDropsPage extends StatelessWidget {
  final DropsController controller;
  final Artist artist;
  const ManageDropsPage({
    super.key,
    required this.controller,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final allDrops = controller.drops;
        final drops = artist.isAdmin
            ? allDrops
            : allDrops
                .where((drop) => drop.artistUserId == artist.id)
                .toList();
        if (drops.isEmpty) {
          return const Center(
            child: Text(
              'Noch keine Art-Drops. Erstelle einen zum Veroeffentlichen.',
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: drops.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final drop = drops[index];
            return DropCard(
              drop: drop,
              onDecrement: () => _updateAvailability(
                context,
                controller,
                drop,
                drop.dropsAvailable - 1,
              ),
              onIncrement: () => _updateAvailability(
                context,
                controller,
                drop,
                drop.dropsAvailable + 1,
              ),
              onEdit: () => _openEditPage(context, controller, drop),
              onMarkAllFound: () => _markAllFound(context, controller, drop.id),
            );
          },
        );
      },
    );
  }

  Future<void> _updateAvailability(
    BuildContext context,
    DropsController controller,
    ArtDrop drop,
    int newValue,
  ) async {
    const maxDropsTotal = 10000;
    final clamped = newValue.clamp(0, maxDropsTotal);
    try {
      await controller.updateAvailable(id: drop.id, available: clamped);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aktualisierung fehlgeschlagen: $error')),
      );
    }
  }

  Future<void> _markAllFound(
    BuildContext context,
    DropsController controller,
    String dropId,
  ) async {
    try {
      await controller.markFound(dropId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aktualisierung fehlgeschlagen: $error')),
      );
    }
  }

  void _openEditPage(
    BuildContext context,
    DropsController controller,
    ArtDrop drop,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditDropPage(controller: controller, drop: drop),
      ),
    );
  }
}
