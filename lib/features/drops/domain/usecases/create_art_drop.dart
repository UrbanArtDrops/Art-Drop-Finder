import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class CreateArtDrop extends UseCase<Future<ArtDrop>, CreateArtDropParams> {
  final ArtDropRepository repository;
  const CreateArtDrop(this.repository);

  @override
  Future<ArtDrop> call(CreateArtDropParams params) {
    final drop = ArtDrop(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      artistUserId: params.artistUserId,
      title: params.title.trim(),
      description: params.description.trim(),
      locationText: params.locationText.trim(),
      locationLat: params.locationLat,
      locationLng: params.locationLng,
      dropsTotal: params.dropsTotal,
      dropsAvailable: params.dropsTotal,
      dropImagePath: params.dropImagePath,
      environmentImagePath: params.environmentImagePath,
      createdAt: DateTime.now(),
    );

    return repository.createDrop(drop);
  }
}

class CreateArtDropParams {
  final String title;
  final String description;
  final String locationText;
  final double locationLat;
  final double locationLng;
  final int dropsTotal;
  final String? dropImagePath;
  final String? environmentImagePath;
  final String? artistUserId;

  const CreateArtDropParams({
    required this.title,
    required this.description,
    required this.locationText,
    required this.locationLat,
    required this.locationLng,
    required this.dropsTotal,
    required this.dropImagePath,
    required this.environmentImagePath,
    this.artistUserId,
  });
}
