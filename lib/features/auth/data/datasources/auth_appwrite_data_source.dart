import 'package:appwrite/appwrite.dart';
import 'package:art_drop_finder/core/appwrite_client.dart';
import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';

class AuthAppwriteDataSource {
  final Account account;

  AuthAppwriteDataSource({Account? account})
      : account = account ?? appwriteAccount;

  Future<Artist> login({
    required String email,
    required String password,
  }) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (error) {
      if (error.type == 'user_session_already_exists') {
        await account.deleteSession(sessionId: 'current');
        await account.createEmailPasswordSession(
          email: email,
          password: password,
        );
      } else {
        rethrow;
      }
    }
    final user = await account.get();
    final displayName = user.name.isNotEmpty ? user.name : user.email;
    final labels = user.labels;
    return Artist(
      id: user.$id,
      name: displayName,
      labels: labels.isEmpty ? const <String>[] : labels,
    );
  }
}
