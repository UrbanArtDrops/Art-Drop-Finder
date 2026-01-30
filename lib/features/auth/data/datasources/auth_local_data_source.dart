import 'package:art_drop_finder/core/error/exceptions.dart';
import 'package:art_drop_finder/features/auth/data/models/artist_model.dart';

class AuthLocalDataSource {
  static const ArtistModel _defaultArtist = ArtistModel(
    id: 'local-artist',
    name: 'artist@example.com',
    password: '12345678909',
  );

  ArtistModel login({required String email, required String password}) {
    if (email == _defaultArtist.name && password == _defaultArtist.password) {
      return _defaultArtist;
    }

    throw const AppException('Ungueltige Künstler-E-Mail oder Passwort.');
  }
}
