import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class ListDropImages
    extends UseCase<Future<List<DropImage>>, ListDropImagesParams> {
  final DropExtrasRepository repository;
  const ListDropImages(this.repository);

  @override
  Future<List<DropImage>> call(ListDropImagesParams params) {
    return repository.listDropImages(dropIds: params.dropIds);
  }
}

class ListDropImagesParams {
  final List<String> dropIds;

  const ListDropImagesParams({required this.dropIds});
}
