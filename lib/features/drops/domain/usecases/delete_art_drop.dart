import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class DeleteArtDrop extends UseCase<Future<void>, DeleteArtDropParams> {
  final ArtDropRepository repository;
  const DeleteArtDrop(this.repository);

  @override
  Future<void> call(DeleteArtDropParams params) {
    return repository.deleteDrop(params.id);
  }
}

class DeleteArtDropParams {
  final String id;

  const DeleteArtDropParams({required this.id});
}
