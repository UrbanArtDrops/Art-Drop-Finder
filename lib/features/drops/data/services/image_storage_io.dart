import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:art_drop_finder/core/appwrite_client.dart';
import 'package:art_drop_finder/features/drops/data/services/image_sanitizer.dart';
import 'package:art_drop_finder/features/drops/data/services/image_storage_types.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorage {
  final Storage storage;
  final String bucketId;

  ImageStorage({Storage? storage, String? bucketId})
      : storage = storage ?? appwriteStorage,
        bucketId = bucketId ?? appwriteArtDropImagesBucketId;

  Future<PersistedImage> persistImage(XFile file) async {
    final rawName = _resolveFilename(file);
    final bytes = await file.readAsBytes();
    final sanitized = stripImageMetadata(bytes, rawName);
    final stored = await storage.createFile(
      bucketId: bucketId,
      fileId: ID.unique(),
      file: InputFile.fromBytes(
        bytes: sanitized.bytes,
        filename: sanitized.filename,
      ),
    );
    return PersistedImage(
      path: appwriteFileViewUrl(bucketId: bucketId, fileId: stored.$id),
      format: _formatFromFilename(sanitized.filename),
    );
  }

  String _resolveFilename(XFile file) {
    if (file.name.isNotEmpty) {
      return file.name;
    }
    final path = file.path;
    final index = path.lastIndexOf(Platform.pathSeparator);
    if (index == -1 || index == path.length - 1) {
      return 'drop_${DateTime.now().microsecondsSinceEpoch}.jpg';
    }
    return path.substring(index + 1);
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
