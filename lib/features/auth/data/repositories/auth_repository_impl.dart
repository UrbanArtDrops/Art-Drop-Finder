import 'package:art_drop_finder/features/auth/data/datasources/auth_appwrite_data_source.dart';
import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';
import 'package:art_drop_finder/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthAppwriteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Artist> login({required String email, required String password}) {
    return remoteDataSource.login(email: email, password: password);
  }
}
