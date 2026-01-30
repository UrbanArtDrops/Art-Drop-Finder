import 'dart:convert';

import 'package:art_drop_finder/core/error/exceptions.dart';
import 'package:art_drop_finder/features/drops/data/models/art_drop_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtDropLocalDataSource {
  static const _storageKey = 'art_drop_list';
  final SharedPreferences sharedPreferences;
  final List<ArtDropModel> _drops;

  ArtDropLocalDataSource(this.sharedPreferences)
    : _drops = _readDrops(sharedPreferences);

  List<ArtDropModel> listDrops() {
    return List.unmodifiable(_drops);
  }

  ArtDropModel createDrop(ArtDropModel drop) {
    _drops.insert(0, drop);
    _persist();
    return drop;
  }

  ArtDropModel updateDropsAvailable(String id, int dropsAvailable) {
    final index = _drops.indexWhere((drop) => drop.id == id);
    if (index == -1) {
      throw const AppException('Art-Drop nicht gefunden.');
    }

    final existing = _drops[index];
    final clamped = dropsAvailable.clamp(0, existing.dropsTotal);
    final updated = existing.copyWith(dropsAvailable: clamped);
    _drops[index] = updated;
    _persist();
    return updated;
  }

  ArtDropModel markAllFound(String id) {
    return updateDropsAvailable(id, 0);
  }

  void _persist() {
    final payload = jsonEncode(_drops.map((drop) => drop.toMap()).toList());
    sharedPreferences.setString(_storageKey, payload);
  }

  static List<ArtDropModel> _readDrops(SharedPreferences sharedPreferences) {
    final stored = sharedPreferences.getString(_storageKey);
    if (stored == null || stored.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      return decoded
          .map((item) => ArtDropModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
