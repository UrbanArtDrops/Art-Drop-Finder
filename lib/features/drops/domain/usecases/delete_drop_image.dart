import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class DeleteDropImage
    extends UseCase<Future<void>, DeleteDropImageParams> {
  final DropExtrasRepository repository;
  const DeleteDropImage(this.repository);

  @override
  Future<void> call(DeleteDropImageParams params) {
    return repository.deleteDropImage(imageId: params.imageId);
  }
}

class DeleteDropImageParams {
  final String imageId;

  const DeleteDropImageParams({required this.imageId});
}
