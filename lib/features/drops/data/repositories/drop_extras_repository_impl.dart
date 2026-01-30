import 'package:art_drop_finder/features/drops/data/datasources/drop_extras_remote_data_source.dart';
import 'package:art_drop_finder/features/drops/data/models/drop_claim_model.dart';
import 'package:art_drop_finder/features/drops/data/models/drop_image_model.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/entities/social_post.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class DropExtrasRepositoryImpl implements DropExtrasRepository {
  final DropExtrasRemoteDataSource remoteDataSource;

  const DropExtrasRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DropClaim>> listDropClaims({required List<String> dropIds}) {
    return remoteDataSource.listDropClaimsForDrops(dropIds);
  }

  @override
  Future<DropClaim> createDropClaim(DropClaim claim) {
    return remoteDataSource.createDropClaim(
      DropClaimModel(
        id: claim.id,
        dropId: claim.dropId,
        claimerName: claim.claimerName,
        comment: claim.comment,
        claimedAt: claim.claimedAt,
      ),
    );
  }

  @override
  Future<List<DropImage>> listDropImages({required List<String> dropIds}) {
    return remoteDataSource.listDropImagesForDrops(dropIds);
  }

  @override
  Future<DropImage> createDropImage(DropImage image) {
    return remoteDataSource.createDropImage(
      DropImageModel(
        id: image.id,
        artDropId: image.artDropId,
        imagePath: image.imagePath,
        imageType: image.imageType,
        imageFormat: image.imageFormat,
        createdAt: image.createdAt,
      ),
    );
  }

  @override
  Future<void> deleteDropImage({required String imageId}) {
    return remoteDataSource.deleteDropImage(imageId);
  }

  @override
  Future<List<SocialPost>> listSocialPosts({required List<String> dropIds}) {
    return remoteDataSource.listSocialPostsForDrops(dropIds);
  }
}
