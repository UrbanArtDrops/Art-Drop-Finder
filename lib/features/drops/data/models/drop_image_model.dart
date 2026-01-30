import 'package:art_drop_finder/core/utils/typedefs.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';

class DropImageModel extends DropImage {
  static const fieldId = 'id';
  static const fieldDropId = 'artDropId';
  static const fieldImagePath = 'imagePath';
  static const fieldImageType = 'imageType';
  static const fieldImageFormat = 'imageFormat';
  static const fieldCreatedAt = 'createdAt';

  const DropImageModel({
    required super.id,
    required super.artDropId,
    required super.imagePath,
    super.imageType,
    super.imageFormat,
    required super.createdAt,
  });

  factory DropImageModel.fromMap(DataMap map) {
    final rawFormat = _stringFromOptional(map, [fieldImageFormat, 'format']);
    final imageFormat = normalizeImageFormat(rawFormat);
    final imageType =
        _stringFromOptional(map, [fieldImageType, 'type']) ??
            (imageFormat == null ? rawFormat : null);
    return DropImageModel(
      id: _stringFrom(map, [fieldId, r'$id']),
      artDropId: _stringFrom(map, [fieldDropId, 'dropId', 'artDropId']),
      imagePath: _stringFrom(map, [fieldImagePath, 'imagePath']),
      imageType: imageType,
      imageFormat: imageFormat,
      createdAt: _dateFrom(
        map,
        [fieldCreatedAt, 'createdAt', 'created_at', r'$createdAt'],
      ),
    );
  }

  DataMap toMap() {
    return {
      fieldId: id,
      fieldDropId: artDropId,
      fieldImagePath: imagePath,
      fieldImageType: imageType,
      fieldImageFormat: normalizeImageFormat(imageFormat),
      fieldCreatedAt: createdAt.toIso8601String(),
    };
  }

  static String? normalizeImageFormat(String? value) {
    if (value == null) {
      return null;
    }
    switch (value.trim().toLowerCase()) {
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

  static String _stringFrom(DataMap map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return value.toString();
    }
    return '';
  }

  static String? _stringFromOptional(DataMap map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return value.toString();
    }
    return null;
  }

  static DateTime _dateFrom(DataMap map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is DateTime) {
        return value;
      }
      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
