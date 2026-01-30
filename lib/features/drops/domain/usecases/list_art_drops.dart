import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class ListArtDrops extends UseCase<Future<List<ArtDrop>>, NoParams> {
  final ArtDropRepository repository;
  const ListArtDrops(this.repository);

  @override
  Future<List<ArtDrop>> call(NoParams params) {
    return repository.listDrops();
  }
}
