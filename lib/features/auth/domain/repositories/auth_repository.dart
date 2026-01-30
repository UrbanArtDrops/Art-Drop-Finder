import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';

abstract class AuthRepository {
  Future<Artist> login({required String email, required String password});
}
