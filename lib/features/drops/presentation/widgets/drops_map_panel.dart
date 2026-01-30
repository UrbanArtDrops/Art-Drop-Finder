import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:art_drop_finder/core/map_launcher_adapter.dart';
import 'package:art_drop_finder/core/utils/platform_image.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';

class DropsMapPanel extends StatefulWidget {
  final List<ArtDrop> drops;
  final String? selectedDropId;
  final String? focusDropId;
  final int focusNonce;
  final Map<String, List<String>> claimersByDropId;

  const DropsMapPanel({
    super.key,
    required this.drops,
    required this.claimersByDropId,
    this.selectedDropId,
    this.focusDropId,
    this.focusNonce = 0,
  });

  @override
  State<DropsMapPanel> createState() => _DropsMapPanelState();
}

class _DropsMapPanelState extends State<DropsMapPanel> {
  static const double _pinSize = 36;
  static const double _popupWidth = 260;
  static const double _popupHeight = 380;
  static const double _popupImageHeight = 90;

  final MapController _controller = MapController();
  LatLngBounds? _bounds;
  bool _mapReady = false;
  String? _pendingSelectionId;
  String? _pendingFocusId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildBounds();
  }

  @override
  void didUpdateWidget(DropsMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drops != widget.drops) {
      _rebuildBounds();
    }
    if (oldWidget.selectedDropId != widget.selectedDropId) {
      _queueSelection(widget.selectedDropId);
    }
    if (oldWidget.focusNonce != widget.focusNonce) {
      _queueFocus(widget.focusDropId);
    }
  }

  void _handleMapReady() {
    _mapReady = true;
    _fitBounds();
    _showPendingSelection();
    _showPendingFocus();
  }

  void _rebuildBounds() {
    if (!mounted) {
      return;
    }
    final bounds = _boundsForDrops(widget.drops);
    setState(() {
      _bounds = bounds;
    });
    _fitBounds();
    _showPendingSelection();
    _showPendingFocus();
  }

  void _fitBounds() {
    if (!_mapReady || _bounds == null) {
      return;
    }
    if (widget.selectedDropId != null) {
      return;
    }
    final bounds = _bounds!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapReady || widget.selectedDropId != null) {
        return;
      }
      _controller.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
    });
  }

  void _queueSelection(String? dropId) {
    if (dropId == null) {
      return;
    }
    _pendingSelectionId = dropId;
    _showPendingSelection();
  }

  void _queueFocus(String? dropId) {
    if (dropId == null) {
      return;
    }
    _pendingFocusId = dropId;
    _showPendingFocus();
  }

  void _showPendingSelection() {
    final dropId = _pendingSelectionId;
    if (dropId == null || !_mapReady) {
      return;
    }
    final drop = _findDrop(dropId);
    if (drop == null) {
      return;
    }
    _pendingSelectionId = null;
    _focusOnDrop(drop);
  }

  void _showPendingFocus() {
    final dropId = _pendingFocusId;
    if (dropId == null || !_mapReady) {
      return;
    }
    final drop = _findDrop(dropId);
    if (drop == null) {
      return;
    }
    _pendingFocusId = null;
    _focusOnDrop(drop);
  }

  ArtDrop? _findDrop(String id) {
    for (final drop in widget.drops) {
      if (drop.id == id) {
        return drop;
      }
    }
    return null;
  }

  void _focusOnDrop(ArtDrop drop) {
    if (!_mapReady) {
      return;
    }
    final target = LatLng(drop.locationLat, drop.locationLng);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapReady) {
        return;
      }
      _controller.move(target, 13);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canLaunchExternal = _supportsExternalLaunch();
    final markers = _buildMarkers(context, scheme, canLaunchExternal);
    final circles = _buildCircles(scheme);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                      initialCenter: _initialCenter(),
                      initialZoom: _initialZoom(),
                      onMapReady: _handleMapReady,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'art_drop_finder',
                      ),
                      if (circles.isNotEmpty) CircleLayer(circles: circles),
                      if (markers.isNotEmpty) MarkerLayer(markers: markers),
                      _AttributionOverlay(),
                    ],
                  ),
                ),
                if (widget.drops.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Noch keine Drop-Standorte.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MapLegendDot(label: 'Vollstaendig', color: scheme.secondary),
              const SizedBox(width: 12),
              _MapLegendRing(
                label: 'Aktiv (1 km Radius)',
                color: scheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            canLaunchExternal
                ? 'Tippe auf einen Pin, um Waze zu oeffnen.'
                : 'Tippe auf einen Pin fuer Details.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  LatLng _initialCenter() {
    if (_bounds != null) {
      return _bounds!.center;
    }
    return const LatLng(20, 0);
  }

  double _initialZoom() {
    return _bounds == null ? 2 : 12;
  }

  List<Marker> _buildMarkers(
    BuildContext context,
    ColorScheme scheme,
    bool canLaunchExternal,
  ) {
    final markers = <Marker>[];
    for (final drop in widget.drops) {
      final isSelected = widget.selectedDropId == drop.id;
      final showPin = drop.allFound;
      final width = isSelected ? _popupWidth : (showPin ? _pinSize : 1.0);
      final height = isSelected
          ? _popupHeight + (showPin ? _pinSize : 0.0)
          : (showPin ? _pinSize : 1.0);
      markers.add(
        Marker(
          point: LatLng(drop.locationLat, drop.locationLng),
          width: width,
          height: height,
          alignment: Alignment.bottomCenter,
          child: _DropMarker(
            drop: drop,
            claimers: widget.claimersByDropId[drop.id] ?? const <String>[],
            isSelected: isSelected,
            showPin: showPin,
            pinColor: drop.allFound ? scheme.secondary : scheme.primary,
            popupWidth: _popupWidth,
            popupHeight: _popupHeight,
            popupImageHeight: _popupImageHeight,
            pinSize: _pinSize,
            onOpenExternal: showPin && canLaunchExternal
                ? () => unawaited(_openInMaps(context, drop))
                : null,
          ),
        ),
      );
    }
    return markers;
  }

  List<CircleMarker> _buildCircles(ColorScheme scheme) {
    final circles = <CircleMarker>[];
    for (final drop in widget.drops) {
      if (drop.allFound) {
        continue;
      }
      circles.add(
        CircleMarker(
          point: LatLng(drop.locationLat, drop.locationLng),
          radius: 1000,
          useRadiusInMeter: true,
          color: scheme.primary.withValues(alpha: 0.15),
          borderStrokeWidth: 1,
          borderColor: scheme.primary.withValues(alpha: 0.6),
        ),
      );
    }
    return circles;
  }

  bool _supportsExternalLaunch() {
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}

class _DropMarker extends StatelessWidget {
  final ArtDrop drop;
  final List<String> claimers;
  final bool isSelected;
  final bool showPin;
  final Color pinColor;
  final double popupWidth;
  final double popupHeight;
  final double popupImageHeight;
  final double pinSize;
  final VoidCallback? onOpenExternal;

  const _DropMarker({
    required this.drop,
    required this.claimers,
    required this.isSelected,
    required this.showPin,
    required this.pinColor,
    required this.popupWidth,
    required this.popupHeight,
    required this.popupImageHeight,
    required this.pinSize,
    this.onOpenExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected) ...[
          SizedBox(
            height: popupHeight,
            child: _DropPopup(
              drop: drop,
              claimers: claimers,
              width: popupWidth,
              maxHeight: popupHeight,
              imageHeight: popupImageHeight,
            ),
          ),
          if (showPin) const SizedBox(height: 6),
        ],
        if (showPin)
          _DropPin(color: pinColor, size: pinSize, onTap: onOpenExternal),
      ],
    );
  }
}

class _DropPopup extends StatelessWidget {
  final ArtDrop drop;
  final List<String> claimers;
  final double width;
  final double maxHeight;
  final double imageHeight;

  const _DropPopup({
    required this.drop,
    required this.claimers,
    required this.width,
    required this.maxHeight,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDropImage = canShowPlatformImage(drop.dropImagePath);
    final hasEnvironmentImage = canShowPlatformImage(drop.environmentImagePath);
    return SizedBox(
      height: maxHeight,
      width: width,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(drop.title, style: theme.textTheme.labelLarge),
              if (drop.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  drop.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (hasDropImage || hasEnvironmentImage)
                const SizedBox(height: 6),
              if (hasDropImage) ...[
                Text('Drop-Foto', style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                buildPlatformImage(
                  drop.dropImagePath!,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
              if (hasEnvironmentImage) ...[
                if (hasDropImage) const SizedBox(height: 8),
                Text('Umgebungsfoto', style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                buildPlatformImage(
                  drop.environmentImagePath!,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
              if (claimers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Beansprucht von', style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < claimers.length; i++)
                      Chip(
                        avatar: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          child: Text(
                            '${i + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        label: Text(claimers[i]),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DropPin extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const _DropPin({required this.color, required this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pin = Icon(Icons.location_on, color: color, size: size);
    if (onTap == null) {
      return pin;
    }
    return GestureDetector(onTap: onTap, child: pin);
  }
}

class _AttributionOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Align(
      alignment: Alignment.bottomRight,
      child: IgnorePointer(
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('(c) OpenStreetMap contributors', style: style),
        ),
      ),
    );
  }
}

Future<void> _openInMaps(BuildContext context, ArtDrop drop) async {
  if (kIsWeb) {
    return;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      break;
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
    case TargetPlatform.fuchsia:
      return;
  }
  final isAvailable = await isWazeAvailable();
  if (!context.mounted) {
    return;
  }
  if (isAvailable != true) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Waze ist nicht verfuegbar.')));
    return;
  }
  await openWazeMarker(
    latitude: drop.locationLat,
    longitude: drop.locationLng,
    title: drop.title,
    description: drop.allFound
        ? 'Alle Drops beansprucht.'
        : 'Aktiver Drop (1 km Radius).',
  );
}

LatLngBounds? _boundsForDrops(List<ArtDrop> drops) {
  if (drops.isEmpty) {
    return null;
  }
  double minLat = drops.first.locationLat;
  double maxLat = drops.first.locationLat;
  double minLng = drops.first.locationLng;
  double maxLng = drops.first.locationLng;

  for (final drop in drops.skip(1)) {
    minLat = math.min(minLat, drop.locationLat);
    maxLat = math.max(maxLat, drop.locationLat);
    minLng = math.min(minLng, drop.locationLng);
    maxLng = math.max(maxLng, drop.locationLng);
  }

  var latSpan = (maxLat - minLat).abs();
  var lngSpan = (maxLng - minLng).abs();
  if (latSpan < 0.01) {
    minLat -= 0.005;
    maxLat += 0.005;
    latSpan = maxLat - minLat;
  }
  if (lngSpan < 0.01) {
    minLng -= 0.005;
    maxLng += 0.005;
    lngSpan = maxLng - minLng;
  }

  final latPadding = math.max(latSpan * 0.15, 0.01);
  final lngPadding = math.max(lngSpan * 0.15, 0.01);

  return LatLngBounds(
    LatLng(minLat - latPadding, minLng - lngPadding),
    LatLng(maxLat + latPadding, maxLng + lngPadding),
  );
}

class _MapLegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _MapLegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _MapLegendRing extends StatelessWidget {
  final String label;
  final Color color;

  const _MapLegendRing({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
