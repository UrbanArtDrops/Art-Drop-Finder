import 'dart:async';
import 'dart:developer' as debug;

import 'package:flutter/material.dart';
import 'package:art_drop_finder/core/utils/platform_image_web.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/entities/social_post.dart';

class DropShowCard extends StatefulWidget {
  final ArtDrop drop;
  final List<String> dropImages;
  final List<String> environmentImages;
  final List<DropClaim> claims;
  final List<SocialPost> posts;
  final VoidCallback? onShowOverlay;
  final VoidCallback? onShowMap;

  const DropShowCard({
    super.key,
    required this.drop,
    this.dropImages = const <String>[],
    this.environmentImages = const <String>[],
    this.claims = const <DropClaim>[],
    this.posts = const <SocialPost>[],
    this.onShowOverlay,
    this.onShowMap,
  });

  @override
  State<DropShowCard> createState() => _DropShowCardState();
}

class _DropShowCardState extends State<DropShowCard> {
  bool _showClaimers = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    final artistName = (widget.drop.artistName ?? '').trim();
    final artistLabel = artistName.isEmpty
        ? 'Unbekannter Künstler'
        : artistName;

    final slides = _buildSlides(
      widget.drop,
      dropImages: widget.dropImages,
      environmentImages: widget.environmentImages,
    );
    final sortedClaims = List<DropClaim>.from(widget.claims)
      ..sort((a, b) => a.claimedAt.compareTo(b.claimedAt));
    final claimCount = _countClaims(widget.claims);
    debug.log(
      'Building DropShowCard for drop ${widget.drop.id} with $claimCount claims and ${slides.length} slides',
      name: 'DropShowCard.build',
      error: widget.claims,
    );

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (slides.isNotEmpty) _DropImageCarousel(slides: slides),
            if (slides.isNotEmpty) const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.drop.title,
                  style: theme.textTheme.titleLarge!.copyWith(fontSize: 32),
                ),
                //const SizedBox(height: 6),
                Text(
                  'Künstler: $artistLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.drop.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ToggleButtons(
                      isSelected: [_showClaimers, false],
                      fillColor: Colors.black,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (index) {
                        // on pressed show list of claimers für index 0
                        if (index == 1) {
                          setState(() => _showClaimers = !_showClaimers);
                          widget.onShowOverlay?.call();
                        }
                        if (index == 0) {
                          widget.onShowOverlay?.call();
                        }
                      },
                      children: [
                        Container(
                          color: Colors.grey[300],
                          width: constraints.maxWidth / 2 - 1.5,
                          height: 80,
                          child: Column(
                            // on pressed show list of claimers
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Offene Drops",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                (widget.drop.dropsTotal - widget.claims.length)
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.grey[300],
                          width: constraints.maxWidth / 2 - 1.5,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Beansprucht",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.claims.length.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                //const SizedBox(height: 12),
                if (_showClaimers) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Bereits beansprucht von:',
                    style: theme.textTheme.titleMedium,
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final claim = sortedClaims[index];
                      final localTime = claim.claimedAt.toLocal();
                      final dateLabel = localizations.formatFullDate(localTime);
                      final timeLabel = localizations.formatTimeOfDay(
                        TimeOfDay.fromDateTime(localTime),
                        alwaysUse24HourFormat: use24HourFormat,
                      );
                      return Card(
                        color: Colors.grey[300],
                        child: ListTile(
                          title: Text(claim.claimerName),
                          subtitle: Text('$dateLabel, $timeLabel'),
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${index + 1}'),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          minVerticalPadding: 6,
                        ),
                      );
                    },
                    itemCount: sortedClaims.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onShowMap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Auf Karte anzeigen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_DropImageSlide> _buildSlides(
    ArtDrop drop, {
    required List<String> dropImages,
    required List<String> environmentImages,
  }) {
    final slides = <_DropImageSlide>[];
    final dropPaths = dropImages.isNotEmpty
        ? dropImages
        : (canShowPlatformImage(drop.dropImagePath)
              ? [drop.dropImagePath!]
              : const <String>[]);
    final environmentPaths = environmentImages.isNotEmpty
        ? environmentImages
        : (canShowPlatformImage(drop.environmentImagePath)
              ? [drop.environmentImagePath!]
              : const <String>[]);

    for (final path in dropPaths) {
      if (!canShowPlatformImage(path)) {
        continue;
      }
      slides.add(_DropImageSlide(label: 'Drop-Foto', path: path));
    }
    for (final path in environmentPaths) {
      if (!canShowPlatformImage(path)) {
        continue;
      }
      slides.add(_DropImageSlide(label: 'Umgebungsfoto', path: path));
    }
    return slides;
  }

  int _countClaims(List<DropClaim> claims) => claims.length;
}

class _SquareStatButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onPressed;

  const _SquareStatButton({
    required this.label,
    required this.value,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              const SizedBox(height: 6),
              Text(value, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropImageSlide {
  final String label;
  final String path;

  const _DropImageSlide({required this.label, required this.path});
}

class _DropImageCarousel extends StatefulWidget {
  final List<_DropImageSlide> slides;

  const _DropImageCarousel({required this.slides});

  @override
  State<_DropImageCarousel> createState() => _DropImageCarouselState();
}

class _DropImageCarouselState extends State<_DropImageCarousel> {
  late final PageController _controller;
  int _pageIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant _DropImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      if (_pageIndex >= widget.slides.length) {
        _pageIndex = 0;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients && widget.slides.isNotEmpty) {
          _controller.jumpToPage(_pageIndex);
        }
      });
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.slides.length < 2) {
      return;
    }
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_controller.hasClients || widget.slides.isEmpty) {
        return;
      }
      final nextIndex = (_pageIndex + 1) % widget.slides.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (index) => setState(() => _pageIndex = index),
            itemBuilder: (context, index) {
              final slide = slides[index];
              return buildPlatformImage(slide.path, fit: BoxFit.cover);
            },
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: i == _pageIndex ? 18 : 6,
                  decoration: BoxDecoration(
                    color: i == _pageIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
