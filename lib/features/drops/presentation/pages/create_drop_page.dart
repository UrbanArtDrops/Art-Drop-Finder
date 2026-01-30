import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:art_drop_finder/core/utils/platform_image.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';

class CreateDropPage extends StatefulWidget {
  final DropsController controller;
  const CreateDropPage({super.key, required this.controller});

  @override
  State<CreateDropPage> createState() => _CreateDropPageState();
}

class _CreateDropPageState extends State<CreateDropPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dropsTotalController = TextEditingController(text: '1');
  final List<XFile> _dropPhotos = [];
  final List<XFile> _environmentPhotos = [];
  bool _isLocating = false;
  double? _locationLat;
  double? _locationLng;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dropsTotalController.dispose();
    super.dispose();
  }

  Future<void> _addDropImageFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, maxWidth: 1600);
    if (file == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _dropPhotos.add(file));
  }

  Future<void> _addEnvironmentImageFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, maxWidth: 1600);
    if (file == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _environmentPhotos.add(file));
  }

  Future<void> _addDropImagesFromGallery() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(maxWidth: 1600);
    if (files.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _dropPhotos.addAll(files));
  }

  Future<void> _addEnvironmentImagesFromGallery() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(maxWidth: 1600);
    if (files.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _environmentPhotos.addAll(files));
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

  Future<void> _publish() async {
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

    try {
      await widget.controller.createAndPublish(
        title: _titleController.text,
        description: _descriptionController.text,
        locationText: _locationController.text,
        locationLat: locationLat,
        locationLng: locationLng,
        dropsTotal: dropsTotal,
        dropImageFiles: List<XFile>.from(_dropPhotos),
        environmentImageFiles: List<XFile>.from(_environmentPhotos),
      );
      if (!mounted) {
        return;
      }
      _clearForm();
      _showMessage('Art-Drop veroeffentlicht.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.toString());
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _dropsTotalController.text = '1';
    _locationLat = null;
    _locationLng = null;
    setState(() {
      _dropPhotos.clear();
      _environmentPhotos.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isPublishing = widget.controller.isPublishing;
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Neuer Art-Drop',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'Gib dem Drop einen Namen und eine Stimmung',
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
                  hintText: 'Beschreibe den Art-Drop und wie man ihn findet.',
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
                  label:
                      Text(
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
              _buildPhotoPicker(
                title: 'Fotos des Drops',
                emptyLabel: 'Keine Drop-Fotos ausgewaehlt',
                photos: _dropPhotos,
                onCamera: _addDropImageFromCamera,
                onGallery: _addDropImagesFromGallery,
                onRemove: (index) => setState(() => _dropPhotos.removeAt(index)),
              ),
              const SizedBox(height: 20),
              _buildPhotoPicker(
                title: 'Fotos der Umgebung',
                emptyLabel: 'Keine Umgebungsfotos ausgewaehlt',
                photos: _environmentPhotos,
                onCamera: _addEnvironmentImageFromCamera,
                onGallery: _addEnvironmentImagesFromGallery,
                onRemove:
                    (index) => setState(() => _environmentPhotos.removeAt(index)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isPublishing ? null : _publish,
                icon: isPublishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.publish),
                label: Text(
                  isPublishing
                      ? 'Veroeffentliche...'
                      : 'In sozialen Kanaelen veroeffentlichen',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Posts enthalten Titel, Beschreibung und Fotos. Der Ort bleibt '
                'versteckt, bis alle Drops gefunden sind.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoPicker({
    required String title,
    required String emptyLabel,
    required List<XFile> photos,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required ValueChanged<int> onRemove,
  }) {
    final titleText =
        photos.isEmpty ? title : '$title (${photos.length})';
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
          child: photos.isEmpty
              ? Text(emptyLabel)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  itemCount: photos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Stack(
                      children: [
                        buildPlatformImage(
                          photo.path,
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
                              onPressed: () => onRemove(index),
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
