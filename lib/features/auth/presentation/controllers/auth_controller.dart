import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';
import 'package:art_drop_finder/features/auth/domain/usecases/login_artist.dart';

class AuthController {
  final LoginArtist loginArtist;
  const AuthController(this.loginArtist);

  Future<Artist> login({required String email, required String password}) {
    return loginArtist(LoginArtistParams(email: email, password: password));
  }
}
