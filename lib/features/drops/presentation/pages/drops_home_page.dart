import 'package:flutter/material.dart';
import 'package:art_drop_finder/features/auth/presentation/pages/login_page.dart';
import 'package:art_drop_finder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';
import 'package:art_drop_finder/features/drops/presentation/pages/drops_page.dart';
import 'package:art_drop_finder/features/drops/presentation/widgets/drops_map_panel.dart';
import 'package:art_drop_finder/features/drops/presentation/widgets/drop_show_card.dart';
import 'package:art_drop_finder/core/widgets/app_logo.dart';

class DropsHomePage extends StatefulWidget {
  final DropsController controller;
  final AuthController authController;
  const DropsHomePage({
    super.key,
    required this.controller,
    required this.authController,
  });

  @override
  State<DropsHomePage> createState() => _DropsHomePageState();
}

class _DropsHomePageState extends State<DropsHomePage> {
  String? _selectedDropId;
  String? _focusDropId;
  int _focusNonce = 0;

  void _showOverlay(String dropId) {
    setState(() => _selectedDropId = dropId);
  }

  void _focusMap(String dropId) {
    setState(() {
      _selectedDropId = null;
      _focusDropId = dropId;
      _focusNonce++;
    });
  }

  Map<String, List<String>> _claimersByDropId(List<ArtDrop> drops) {
    final result = <String, List<String>>{};
    for (final drop in drops) {
      final names = <String>[];
      final claims = List.of(widget.controller.claimsForDrop(drop.id))
        ..sort((a, b) => a.claimedAt.compareTo(b.claimedAt));
      for (final claim in claims) {
        final name = claim.claimerName.trim();
        if (name.isEmpty || names.contains(name)) {
          continue;
        }
        names.add(name);
      }
      result[drop.id] = names;
    }
    return result;
  }

  void _openLogin(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (context) => LoginPage(
          controller: widget.authController,
          onLogin: (artist) {
            navigator.pop();
            navigator.push(
              MaterialPageRoute(
                builder: (_) => DropsPage(
                  controller: widget.controller,
                  artist: artist,
                  onLogout: navigator.pop,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urban Art Drop Finder'),
        actions: [
          TextButton.icon(
            onPressed: () => _openLogin(context),
            icon: const Icon(Icons.login),
            label: const Text('Künstler-Login'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final drops = widget.controller.drops;
          final claimersByDropId = _claimersByDropId(drops);
          const header = AppHeaderSection(
            title: 'Art Drop Finder',
            description:
                'Finde Urban Art-Drops in deiner Naehe, entdecke Fotos und '
                'sieh, wie viele Drops noch verfuegbar sind. '
                'Kuenstler koennen neue Drops veroeffentlichen und verwalten.',
          );
          final listView = drops.isEmpty
              ? const Center(
                  child: Text('Noch keine Art-Drops veroeffentlicht.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16).copyWith(top: 8),
                  itemCount: drops.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final drop = drops[index];
                    return DropShowCard(
                      drop: drop,
                      dropImages: widget.controller.dropImagesForDrop(drop.id),
                      environmentImages: widget.controller
                          .environmentImagesForDrop(drop.id),
                      claims: widget.controller.claimsForDrop(drop.id),
                      posts: widget.controller.postsForDrop(drop.id),
                      onShowOverlay: () => _showOverlay(drop.id),
                      onShowMap: () => _focusMap(drop.id),
                    );
                  },
                );
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 960) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //header,
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Card(
                              color: Colors.grey[300],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  header,
                                  SizedBox(height: 16),
                                  Text(
                                    "Verfügbare Art Drops",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(height: 16),
                                  listView,
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: DropsMapPanel(
                              drops: drops,
                              selectedDropId: _selectedDropId,
                              focusDropId: _focusDropId,
                              focusNonce: _focusNonce,
                              claimersByDropId: claimersByDropId,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  header,
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: listView),
                        SizedBox(
                          height: 320,
                          child: DropsMapPanel(
                            drops: drops,
                            selectedDropId: _selectedDropId,
                            focusDropId: _focusDropId,
                            focusNonce: _focusNonce,
                            claimersByDropId: claimersByDropId,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
