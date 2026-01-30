import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/repositories/drop_extras_repository.dart';

class ListDropClaims
    extends UseCase<Future<List<DropClaim>>, ListDropClaimsParams> {
  final DropExtrasRepository repository;
  const ListDropClaims(this.repository);

  @override
  Future<List<DropClaim>> call(ListDropClaimsParams params) {
    return repository.listDropClaims(dropIds: params.dropIds);
  }
}

class ListDropClaimsParams {
  final List<String> dropIds;

  const ListDropClaimsParams({required this.dropIds});
}
