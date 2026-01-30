import 'package:image_picker/image_picker.dart';
import 'package:art_drop_finder/features/drops/data/services/image_storage_types.dart';

class ImageStorage {
  ImageStorage({Object? storage, String? bucketId});

  Future<PersistedImage> persistImage(XFile file) async {
    final filename = file.name.isNotEmpty ? file.name : file.path;
    return PersistedImage(
      path: file.path,
      format: _formatFromFilename(filename),
    );
  }
}

String? _formatFromFilename(String filename) {
  final trimmed = filename.trim();
  final index = trimmed.lastIndexOf('.');
  if (index == -1 || index == trimmed.length - 1) {
    return null;
  }
  switch (trimmed.substring(index + 1).toLowerCase()) {
    case 'jpg':
    case 'jpeg':
      return 'jpeg';
    case 'png':
      return 'png';
    case 'gif':
      return 'gif';
  }
  return null;
}
