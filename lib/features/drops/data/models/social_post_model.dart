import 'package:art_drop_finder/core/utils/typedefs.dart';
import 'package:art_drop_finder/features/drops/domain/entities/social_post.dart';

class SocialPostModel extends SocialPost {
  static const fieldId = 'id';
  static const fieldDropId = 'dropId';
  static const fieldPlatform = 'platform';
  static const fieldUrl = 'url';
  static const fieldCreatedAt = 'createdAt';

  const SocialPostModel({
    required super.id,
    required super.dropId,
    required super.platform,
    required super.url,
    required super.createdAt,
  });

  factory SocialPostModel.fromMap(DataMap map) {
    return SocialPostModel(
      id: _stringFrom(map, [fieldId, r'$id']),
      dropId: _stringFrom(map, [fieldDropId, 'artDropId', 'drop_id']),
      platform: _stringFrom(
        map,
        [fieldPlatform, 'channel', 'socialPlatform'],
      ),
      url: _stringFrom(map, [fieldUrl, 'postUrl', 'link']),
      createdAt: _dateFrom(
        map,
        [fieldCreatedAt, 'createdAt', 'created_at', r'$createdAt'],
      ),
    );
  }

  DataMap toMap() {
    return {
      fieldId: id,
      fieldDropId: dropId,
      fieldPlatform: platform,
      fieldUrl: url,
      fieldCreatedAt: createdAt.toIso8601String(),
    };
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
