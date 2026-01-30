import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class UpdateDropsAvailable
    extends UseCase<Future<ArtDrop>, UpdateDropsAvailableParams> {
  final ArtDropRepository repository;
  const UpdateDropsAvailable(this.repository);

  @override
  Future<ArtDrop> call(UpdateDropsAvailableParams params) {
    return repository.updateDropsAvailable(
      id: params.id,
      dropsAvailable: params.dropsAvailable,
    );
  }
}

class UpdateDropsAvailableParams {
  final String id;
  final int dropsAvailable;

  const UpdateDropsAvailableParams({
    required this.id,
    required this.dropsAvailable,
  });
}
