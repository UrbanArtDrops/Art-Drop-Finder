import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class CreateDropImage
    extends UseCase<Future<DropImage>, CreateDropImageParams> {
  final DropExtrasRepository repository;
  const CreateDropImage(this.repository);

  @override
  Future<DropImage> call(CreateDropImageParams params) {
    final image = DropImage(
      id: '',
      artDropId: params.dropId,
      imagePath: params.imagePath.trim(),
      imageType: params.imageType?.trim(),
      imageFormat: params.imageFormat?.trim(),
      createdAt: DateTime.now(),
    );
    return repository.createDropImage(image);
  }
}

class CreateDropImageParams {
  final String dropId;
  final String imagePath;
  final String? imageType;
  final String? imageFormat;

  const CreateDropImageParams({
    required this.dropId,
    required this.imagePath,
    this.imageType,
    this.imageFormat,
  });
}
