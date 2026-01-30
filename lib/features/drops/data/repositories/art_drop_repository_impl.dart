import 'package:art_drop_finder/features/drops/data/datasources/art_drop_remote_data_source.dart';
import 'package:art_drop_finder/features/drops/data/models/art_drop_model.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class ArtDropRepositoryImpl implements ArtDropRepository {
  final ArtDropRemoteDataSource remoteDataSource;
  const ArtDropRepositoryImpl(this.remoteDataSource);

  @override
  Future<ArtDrop> createDrop(ArtDrop drop) {
    return remoteDataSource.createDrop(ArtDropModel.fromEntity(drop));
  }

  @override
  Future<ArtDrop> updateDrop(ArtDrop drop) {
    return remoteDataSource.updateDrop(ArtDropModel.fromEntity(drop));
  }

  @override
  Future<List<ArtDrop>> listDrops() {
    return remoteDataSource.listDrops();
  }

  @override
  Future<ArtDrop> updateDropsAvailable({
    required String id,
    required int dropsAvailable,
  }) {
    return remoteDataSource.updateDropsAvailable(id, dropsAvailable);
  }

  @override
  Future<ArtDrop> markAllFound(String id) {
    return remoteDataSource.markAllFound(id);
  }

  @override
  Future<void> deleteDrop(String id) {
    return remoteDataSource.deleteDrop(id);
  }
}
