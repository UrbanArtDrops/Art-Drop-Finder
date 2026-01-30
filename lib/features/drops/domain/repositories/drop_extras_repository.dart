import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/entities/social_post.dart';

abstract class DropExtrasRepository {
  Future<List<DropClaim>> listDropClaims({required List<String> dropIds});
  Future<DropClaim> createDropClaim(DropClaim claim);
  Future<List<DropImage>> listDropImages({required List<String> dropIds});
  Future<DropImage> createDropImage(DropImage image);
  Future<void> deleteDropImage({required String imageId});
  Future<List<SocialPost>> listSocialPosts({required List<String> dropIds});
}
