import 'package:appwrite/appwrite.dart';

// IDs are provided via compile-time environment variables (e.g. --dart-define).
const String appwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
const String appwriteProjectId = String.fromEnvironment('appwriteProjectId');
const String appwriteDatabaseId = String.fromEnvironment('appwriteDatabaseId');
const String appwriteArtDropsCollectionId = 'art_drops';
const String appwriteDropClaimsCollectionId = 'drop_claims';
const String appwriteSocialPostsCollectionId = 'social_posts';
const String appwriteDropImagesCollectionId = 'drop_images';
const String appwriteArtDropImagesBucketId =
    String.fromEnvironment('appwriteArtDropImagesBucketId');
const bool appwriteArtDropIncludeIdField = false;
const bool appwriteArtDropIncludeCreatedAtField = false;
const bool appwriteArtDropIncludeDropsAvailableField = false;
const bool appwriteArtDropIncludeDropImagePathField = false;
const bool appwriteArtDropIncludeEnvironmentImagePathField = false;
const bool appwriteDropImagesIncludeTypeField = true;
const String appwriteDropImagesTypeField = 'imageType';
const bool appwriteArtDropUseDocumentPermissions = true;
const bool appwriteArtDropPublicRead = true;

final Client client = Client()
  ..setProject(appwriteProjectId)
  ..setEndpoint(appwriteEndpoint);

final Databases appwriteDatabases = Databases(client);
final TablesDB appwriteTablesDb = TablesDB(client);
final Account appwriteAccount = Account(client);
final Storage appwriteStorage = Storage(client);

String appwriteFileViewUrl({required String bucketId, required String fileId}) {
  final base = appwriteEndpoint.endsWith('/')
      ? appwriteEndpoint.substring(0, appwriteEndpoint.length - 1)
      : appwriteEndpoint;
  final encodedProject = Uri.encodeQueryComponent(appwriteProjectId);
  return '$base/storage/buckets/$bucketId/files/$fileId/view?project=$encodedProject';
}
