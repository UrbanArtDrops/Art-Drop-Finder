import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class MarkAllFound extends UseCase<Future<ArtDrop>, MarkAllFoundParams> {
  final ArtDropRepository repository;
  const MarkAllFound(this.repository);

  @override
  Future<ArtDrop> call(MarkAllFoundParams params) {
    return repository.markAllFound(params.id);
  }
}

class MarkAllFoundParams {
  final String id;
  const MarkAllFoundParams({required this.id});
}
