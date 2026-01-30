import 'package:art_drop_finder/core/utils/typedefs.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';

class ArtDropModel extends ArtDrop {
  static const fieldId = 'id';
  static const fieldArtistUserId = 'artistId';
  static const fieldArtistName = 'artistName';
  static const fieldTitle = 'title';
  static const fieldDescription = 'description';
  static const fieldLocationText = 'locationText';
  static const fieldLocationLat = 'locationLat';
  static const fieldLocationLng = 'locationLng';
  static const fieldDropsTotal = 'dropsTotal';
  static const fieldDropsAvailable = 'dropsAvailable';
  static const fieldDropImagePath = 'dropImagePath';
  static const fieldEnvironmentImagePath = 'environmentImagePath';
  static const fieldImagePath = 'imagePath';
  static const fieldCreatedAt = 'createdAt';

  const ArtDropModel({
    required super.id,
    super.artistUserId,
    super.artistName,
    required super.title,
    required super.description,
    required super.locationText,
    required super.locationLat,
    required super.locationLng,
    required super.dropsTotal,
    required super.dropsAvailable,
    super.dropImagePath,
    super.environmentImagePath,
    required super.createdAt,
  });

  factory ArtDropModel.fromEntity(ArtDrop drop) {
    return ArtDropModel(
      id: drop.id,
      artistUserId: drop.artistUserId,
      artistName: drop.artistName,
      title: drop.title,
      description: drop.description,
      locationText: drop.locationText,
      locationLat: drop.locationLat,
      locationLng: drop.locationLng,
      dropsTotal: drop.dropsTotal,
      dropsAvailable: drop.dropsAvailable,
      dropImagePath: drop.dropImagePath,
      environmentImagePath: drop.environmentImagePath,
      createdAt: drop.createdAt,
    );
  }

  factory ArtDropModel.fromMap(DataMap map) {
    final dropsTotal = _intFrom(map, [
      fieldDropsTotal,
      'dropsTotal',
      'drops_total',
    ]);
    final dropsAvailable = _intFromOptional(map, [
      fieldDropsAvailable,
      'dropsAvailable',
      'drops_available',
    ]);
    final dropImagePath = _stringFromOptional(map, [
      fieldDropImagePath,
      'dropImagePath',
      'drop_image_path',
      fieldImagePath,
      'imagePath',
      'image_path',
      'image_file_id',
    ]);
    return ArtDropModel(
      id: _stringFrom(map, [fieldId, r'$id']),
      artistUserId: _stringFromOptional(map, [
        fieldArtistUserId,
        'artistUserId',
        'artist_user_id',
      ]),
      artistName: _stringFromOptional(map, [
        fieldArtistName,
        'artistName',
        'artist_name',
      ]),
      title: _stringFrom(map, [fieldTitle, 'title']),
      description: _stringFrom(map, [fieldDescription, 'description']),
      locationText: _stringFrom(map, [
        fieldLocationText,
        'locationText',
        'location_text',
      ]),
      locationLat: _doubleFrom(map, [
        fieldLocationLat,
        'locationLat',
        'location_lat',
      ]),
      locationLng: _doubleFrom(map, [
        fieldLocationLng,
        'locationLng',
        'location_lng',
      ]),
      dropsTotal: dropsTotal,
      dropsAvailable: dropsAvailable ?? dropsTotal,
      dropImagePath: dropImagePath,
      environmentImagePath: _stringFromOptional(map, [
        fieldEnvironmentImagePath,
        'environmentImagePath',
        'environment_image_path',
        'surroundingsImagePath',
        'surroundings_image_path',
      ]),
      createdAt: _dateFrom(map, [
        fieldCreatedAt,
        'createdAt',
        'created_at',
        r'$createdAt',
      ]),
    );
  }

  DataMap toMap() {
    return {
      fieldId: id,
      fieldArtistUserId: artistUserId,
      fieldArtistName: artistName,
      fieldTitle: title,
      fieldDescription: description,
      fieldLocationText: locationText,
      fieldLocationLat: locationLat,
      fieldLocationLng: locationLng,
      fieldDropsTotal: dropsTotal,
      fieldDropsAvailable: dropsAvailable,
      fieldDropImagePath: dropImagePath,
      fieldEnvironmentImagePath: environmentImagePath,
      fieldCreatedAt: createdAt.toIso8601String(),
    };
  }

  @override
  ArtDropModel copyWith({
    String? id,
    String? artistUserId,
    String? artistName,
    String? title,
    String? description,
    String? locationText,
    double? locationLat,
    double? locationLng,
    int? dropsTotal,
    int? dropsAvailable,
    String? dropImagePath,
    String? environmentImagePath,
    DateTime? createdAt,
  }) {
    return ArtDropModel(
      id: id ?? this.id,
      artistUserId: artistUserId ?? this.artistUserId,
      artistName: artistName ?? this.artistName,
      title: title ?? this.title,
      description: description ?? this.description,
      locationText: locationText ?? this.locationText,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      dropsTotal: dropsTotal ?? this.dropsTotal,
      dropsAvailable: dropsAvailable ?? this.dropsAvailable,
      dropImagePath: dropImagePath ?? this.dropImagePath,
      environmentImagePath: environmentImagePath ?? this.environmentImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
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

  static int _intFrom(DataMap map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }

  static int? _intFromOptional(DataMap map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static double _doubleFrom(DataMap map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
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
