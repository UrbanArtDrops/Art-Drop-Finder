import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';
import 'package:art_drop_finder/features/auth/domain/repositories/auth_repository.dart';

class LoginArtist extends UseCase<Future<Artist>, LoginArtistParams> {
  final AuthRepository repository;
  const LoginArtist(this.repository);

  @override
  Future<Artist> call(LoginArtistParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginArtistParams {
  final String email;
  final String password;

  const LoginArtistParams({
    required this.email,
    required this.password,
  });
}
