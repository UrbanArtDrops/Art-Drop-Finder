import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/art_drop_repository.dart';

class UpdateArtDrop extends UseCase<Future<ArtDrop>, UpdateArtDropParams> {
  final ArtDropRepository repository;
  const UpdateArtDrop(this.repository);

  @override
  Future<ArtDrop> call(UpdateArtDropParams params) {
    final updated = params.drop.copyWith(
      title: params.title.trim(),
      description: params.description.trim(),
      locationText: params.locationText.trim(),
      locationLat: params.locationLat,
      locationLng: params.locationLng,
      dropsTotal: params.dropsTotal,
      dropsAvailable: params.dropsTotal,
      dropImagePath: params.dropImagePath,
      environmentImagePath: params.environmentImagePath,
    );
    return repository.updateDrop(updated);
  }
}

class UpdateArtDropParams {
  final ArtDrop drop;
  final String title;
  final String description;
  final String locationText;
  final double locationLat;
  final double locationLng;
  final int dropsTotal;
  final String? dropImagePath;
  final String? environmentImagePath;

  const UpdateArtDropParams({
    required this.drop,
    required this.title,
    required this.description,
    required this.locationText,
    required this.locationLat,
    required this.locationLng,
    required this.dropsTotal,
    this.dropImagePath,
    this.environmentImagePath,
  });
}
