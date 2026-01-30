import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';

class ArtistModel extends Artist {
  final String password;
  const ArtistModel({
    required super.id,
    required super.name,
    required this.password,
  });
}
