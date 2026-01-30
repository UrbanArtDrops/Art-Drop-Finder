import 'package:art_drop_finder/core/utils/typedefs.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';

class DropClaimModel extends DropClaim {
  static const fieldId = 'id';
  static const fieldDropId = 'dropId';
  static const fieldClaimerName = 'claimerName';
  static const fieldComment = 'comment';
  static const fieldClaimedAt = 'claimedAt';

  const DropClaimModel({
    required super.id,
    required super.dropId,
    required super.claimerName,
    super.comment,
    required super.claimedAt,
  });

  factory DropClaimModel.fromMap(DataMap map) {
    return DropClaimModel(
      id: _stringFrom(map, [fieldId, r'$id']),
      dropId: _stringFrom(map, [
        fieldDropId,
        'artDropId',
        'drop_id',
        'artDrops',
      ]),
      claimerName: _stringFrom(
        map,
        [
          fieldClaimerName,
          'claimantName',
          'claimer',
          'name',
          'claimer_name',
        ],
      ),
      comment: _stringFromOptional(map, [
        fieldComment,
        'note',
        'message',
        'claimerComment',
      ]),
      claimedAt: _dateFrom(
        map,
        [fieldClaimedAt, 'createdAt', 'created_at', r'$createdAt'],
      ),
    );
  }

  DataMap toMap() {
    return {
      fieldId: id,
      fieldDropId: dropId,
      fieldClaimerName: claimerName,
      fieldComment: comment,
      fieldClaimedAt: claimedAt.toIso8601String(),
    };
  }

  static String _stringFrom(DataMap map, List<String> keys) {
    for (final key in keys) {
      final resolved = _stringFromValue(map[key]);
      if (resolved != null && resolved.isNotEmpty) {
        return resolved;
      }
    }
    return '';
  }

  static String? _stringFromOptional(DataMap map, List<String> keys) {
    for (final key in keys) {
      final resolved = _stringFromValue(map[key]);
      if (resolved != null && resolved.isNotEmpty) {
        return resolved;
      }
    }
    return null;
  }

  static String? _stringFromValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value.isNotEmpty ? value : null;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is Map) {
      final candidate = value[r'$id'] ?? value['id'];
      if (candidate != null) {
        final resolved = _stringFromValue(candidate);
        if (resolved != null && resolved.isNotEmpty) {
          return resolved;
        }
      }
    }
    if (value is List) {
      for (final entry in value) {
        final resolved = _stringFromValue(entry);
        if (resolved != null && resolved.isNotEmpty) {
          return resolved;
        }
      }
      return null;
    }
    return value.toString();
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
