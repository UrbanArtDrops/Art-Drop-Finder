import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';

abstract class ArtDropRepository {
  Future<ArtDrop> createDrop(ArtDrop drop);
  Future<ArtDrop> updateDrop(ArtDrop drop);
  Future<List<ArtDrop>> listDrops();
  Future<ArtDrop> updateDropsAvailable({
    required String id,
    required int dropsAvailable,
  });
  Future<ArtDrop> markAllFound(String id);
  Future<void> deleteDrop(String id);
}
