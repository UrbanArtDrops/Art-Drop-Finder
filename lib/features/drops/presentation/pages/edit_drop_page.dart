import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:art_drop_finder/core/utils/platform_image.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';

class EditDropPage extends StatefulWidget {
  final DropsController controller;
  final ArtDrop drop;

  const EditDropPage({
    super.key,
    required this.controller,
    required this.drop,
  });

  @override
  State<EditDropPage> createState() => _EditDropPageState();
}

class _EditDropPageState extends State<EditDropPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _dropsTotalController;
  bool _isSaving = false;
  bool _isUpdatingImages = false;
  bool _isDeleting = false;
  double? _locationLat;
  double? _locationLng;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.drop.title);
    _descriptionController = TextEditingController(text: widget.drop.description);
    _locationController = TextEditingController(text: widget.drop.locationText);
    _dropsTotalController =
        TextEditingController(text: widget.drop.dropsTotal.toString());
    _locationLat = widget.drop.locationLat;
    _locationLng = widget.drop.locationLng;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dropsTotalController.dispose();
    super.dispose();
  }

  Future<void> _lookupLocation() async {
    setState(() => _isLocating = true);
    try {
      final snapshot = await widget.controller.lookupCurrentLocation();
      if (!mounted) {
        return;
      }
      _locationController.text = snapshot.text;
      _locationLat = snapshot.latitude;
      _locationLng = snapshot.longitude;
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _addDropImagesFromCamera() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
    );
    if (file == null) {
      return;
    }
    await _addImages(files: [file], imageType: 'drop');
  }

  Future<void> _addDropImagesFromGallery() async {
    final files = await ImagePicker().pickMultiImage(maxWidth: 1600);
    if (files.isEmpty) {
      return;
    }
    await _addImages(files: files, imageType: 'drop');
  }

  Future<void> _addEnvironmentImagesFromCamera() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
    );
    if (file == null) {
      return;
    }
    await _addImages(files: [file], imageType: 'environment');
  }

  Future<void> _addEnvironmentImagesFromGallery() async {
    final files = await ImagePicker().pickMultiImage(maxWidth: 1600);
    if (files.isEmpty) {
      return;
    }
    await _addImages(files: files, imageType: 'environment');
  }

  Future<void> _addImages({
    required List<XFile> files,
    required String imageType,
  }) async {
    if (files.isEmpty) {
      return;
    }
    setState(() => _isUpdatingImages = true);
    try {
      await widget.controller.addImages(
        dropId: widget.drop.id,
        files: files,
        imageType: imageType,
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Bild-Upload fehlgeschlagen: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingImages = false);
      }
    }
  }

  Future<void> _removeImage(DropImage image) async {
    setState(() => _isUpdatingImages = true);
    try {
      await widget.controller.removeImage(image);
    } catch (error) {
      if (mounted) {
        _showMessage('Bild entfernen fehlgeschlagen: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingImages = false);
      }
    }
  }

  Future<void> _save() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    final dropsTotal = int.parse(_dropsTotalController.text);
    final locationLat = _locationLat;
    final locationLng = _locationLng;
    if (locationLat == null || locationLng == null) {
      _showMessage('Telefonstandort nutzen oder Koordinaten eingeben.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.controller.updateDrop(
        drop: widget.drop,
        title: _titleController.text,
        description: _descriptionController.text,
        locationText: _locationController.text,
        locationLat: locationLat,
        locationLng: locationLng,
        dropsTotal: dropsTotal,
      );
      if (!mounted) {
        return;
      }
      _showMessage('Art-Drop aktualisiert.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _claimUrl() {
    final dropId = widget.drop.id;
    final base = Uri.base;
    if (kIsWeb) {
      if (base.fragment.isNotEmpty) {
        final fragment = '/claim?dropId=$dropId';
        return base.replace(fragment: fragment, query: '').toString();
      }
      return base
          .replace(path: '/claim', queryParameters: {'dropId': dropId})
          .toString();
    }
    return base
        .replace(path: '/claim', queryParameters: {'dropId': dropId})
        .toString();
  }

  Future<void> _copyClaimUrl() async {
    final url = _claimUrl();
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      _showMessage('Link kopiert.');
    }
  }

  Future<void> _confirmDelete() async {
    if (_isDeleting) {
      return;
    }
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Art-Drop loeschen?'),
        content: const Text(
          'Dieser Vorgang kann nicht rueckgaengig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) {
      return;
    }
    setState(() => _isDeleting = true);
    try {
      await widget.controller.deleteDrop(widget.drop.id);
      if (!mounted) {
        return;
      }
      _showMessage('Art-Drop geloescht.');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        _showMessage('Loeschen fehlgeschlagen: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Art-Drop bearbeiten'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final dropImages =
              widget.controller.dropImageEntriesForDrop(widget.drop.id);
          final environmentImages = widget.controller
              .environmentImageEntriesForDrop(widget.drop.id);
          final claimUrl = _claimUrl();
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Titel',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Titel eingeben.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.newline,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Beschreibung eingeben.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Ort (versteckt, bis alle Drops gefunden sind)',
                    hintText: 'Telefonstandort nutzen oder Lat/Lng eingeben',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _updateCoordinatesFromText(value),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ort eingeben.';
                    }
                    if (_locationLat == null || _locationLng == null) {
                      return 'Telefonstandort nutzen oder Koordinaten eingeben.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _isLocating ? null : _lookupLocation,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isLocating
                          ? 'Standort wird ermittelt...'
                          : 'Telefonstandort verwenden',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dropsTotalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Anzahl der Drops am Ort',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Zahl groesser als 0 eingeben.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildImageSection(
                  title: 'Drop-Fotos',
                  emptyLabel: 'Keine Drop-Fotos vorhanden.',
                  images: dropImages,
                  onCamera: _isUpdatingImages ? null : _addDropImagesFromCamera,
                  onGallery:
                      _isUpdatingImages ? null : _addDropImagesFromGallery,
                  onRemove: _isUpdatingImages ? null : _removeImage,
                ),
                const SizedBox(height: 20),
                _buildImageSection(
                  title: 'Umgebungsfotos',
                  emptyLabel: 'Keine Umgebungsfotos vorhanden.',
                  images: environmentImages,
                  onCamera: _isUpdatingImages
                      ? null
                      : _addEnvironmentImagesFromCamera,
                  onGallery: _isUpdatingImages
                      ? null
                      : _addEnvironmentImagesFromGallery,
                  onRemove: _isUpdatingImages ? null : _removeImage,
                ),
                const SizedBox(height: 24),
                Text(
                  'Beanspruchungsseite',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        claimUrl,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _copyClaimUrl,
                      icon: const Icon(Icons.copy),
                      tooltip: 'Link kopieren',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: QrImageView(
                    data: claimUrl,
                    size: 160,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Speichern...' : 'Aenderungen speichern',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: (_isSaving || _isUpdatingImages || _isDeleting)
                      ? null
                      : _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(_isDeleting ? 'Loeschen...' : 'Drop loeschen'),
                ),
              ],
              ),
            );
        },
      ),
    );
  }

  Widget _buildImageSection({
    required String title,
    required String emptyLabel,
    required List<DropImage> images,
    required VoidCallback? onCamera,
    required VoidCallback? onGallery,
    required ValueChanged<DropImage>? onRemove,
  }) {
    final titleText = images.isEmpty ? title : '$title (${images.length})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titleText, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          alignment: Alignment.center,
          child: images.isEmpty
              ? Text(emptyLabel)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  itemCount: images.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Stack(
                      children: [
                        buildPlatformImage(
                          image.imagePath,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                              tooltip: 'Entfernen',
                              onPressed: onRemove == null
                                  ? null
                                  : () => onRemove(image),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: onCamera,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Foto aufnehmen'),
            ),
            OutlinedButton.icon(
              onPressed: onGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Aus Galerie waehlen'),
            ),
          ],
        ),
        if (_isUpdatingImages) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  void _updateCoordinatesFromText(String value) {
    if (value.trim().isEmpty) {
      _locationLat = null;
      _locationLng = null;
      return;
    }
    final matches = RegExp(r'(-?\d+(?:[.,]\d+)?)').allMatches(value).toList();
    if (matches.length < 2) {
      return;
    }
    final lat = double.tryParse(matches[0].group(0)!.replaceAll(',', '.'));
    final lng = double.tryParse(matches[1].group(0)!.replaceAll(',', '.'));
    if (lat == null || lng == null) {
      return;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return;
    }
    _locationLat = lat;
    _locationLng = lng;
  }
}
