import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/social_post.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class ListSocialPosts
    extends UseCase<Future<List<SocialPost>>, ListSocialPostsParams> {
  final DropExtrasRepository repository;
  const ListSocialPosts(this.repository);

  @override
  Future<List<SocialPost>> call(ListSocialPostsParams params) {
    return repository.listSocialPosts(dropIds: params.dropIds);
  }
}

class ListSocialPostsParams {
  final List<String> dropIds;

  const ListSocialPostsParams({required this.dropIds});
}
