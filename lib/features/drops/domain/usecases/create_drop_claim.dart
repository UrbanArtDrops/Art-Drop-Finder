import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class CreateDropClaim
    extends UseCase<Future<DropClaim>, CreateDropClaimParams> {
  final DropExtrasRepository repository;
  const CreateDropClaim(this.repository);

  @override
  Future<DropClaim> call(CreateDropClaimParams params) {
    final comment = params.comment?.trim();
    final normalizedComment =
        comment == null || comment.isEmpty ? null : comment;
    final claim = DropClaim(
      id: '',
      dropId: params.dropId,
      claimerName: params.claimerName.trim(),
      comment: normalizedComment,
      claimedAt: DateTime.now(),
    );
    return repository.createDropClaim(claim);
  }
}

class CreateDropClaimParams {
  final String dropId;
  final String claimerName;
  final String? comment;

  const CreateDropClaimParams({
    required this.dropId,
    required this.claimerName,
    this.comment,
  });
}
