import 'package:appwrite/appwrite.dart';
import 'package:art_drop_finder/core/appwrite_client.dart';
import 'package:art_drop_finder/features/drops/data/models/art_drop_model.dart';
import 'package:appwrite/models.dart' as models;

class ArtDropRemoteDataSource {
  final TablesDB tablesDb;
  final Account account;
  final String databaseId;
  final String collectionId;

  ArtDropRemoteDataSource({
    TablesDB? tablesDb,
    Account? account,
    this.databaseId = appwriteDatabaseId,
    this.collectionId = appwriteArtDropsCollectionId,
  })  : tablesDb = tablesDb ?? appwriteTablesDb,
        account = account ?? appwriteAccount;

  Future<List<ArtDropModel>> listDrops() async {
    final result = await tablesDb.listRows(
      databaseId: databaseId,
      tableId: collectionId,
      queries: [Query.orderDesc(r'$createdAt')],
    );

    return result.rows.map(_mapRow).toList();
  }

  Future<ArtDropModel> createDrop(ArtDropModel drop) async {
    final user = await account.get();
    final documentId = drop.id.isEmpty ? ID.unique() : drop.id;
    final displayName = user.name.isNotEmpty ? user.name : user.email;
    final data =
        _buildData(drop, artistUserId: user.$id, artistName: displayName);
    if (appwriteArtDropIncludeIdField) {
      data[ArtDropModel.fieldId] = documentId;
    }
    final permissions = appwriteArtDropUseDocumentPermissions
        ? <String>[
            Permission.read(
              appwriteArtDropPublicRead
                  ? Role.any()
                  : Role.user(user.$id),
            ),
            Permission.update(Role.user(user.$id)),
            Permission.update(Role.label('admin')),
            Permission.delete(Role.user(user.$id)),
            Permission.delete(Role.label('admin')),
          ]
        : null;
    try {
      final row = await tablesDb.createRow(
        databaseId: databaseId,
        tableId: collectionId,
        rowId: documentId,
        data: data,
        permissions: permissions,
      );
      return _mapRow(row);
    } on AppwriteException catch (error) {
      if (data.containsKey(ArtDropModel.fieldArtistName) &&
          _isMissingAttribute(error, ArtDropModel.fieldArtistName)) {
        data.remove(ArtDropModel.fieldArtistName);
        final row = await tablesDb.createRow(
          databaseId: databaseId,
          tableId: collectionId,
          rowId: documentId,
          data: data,
          permissions: permissions,
        );
        return _mapRow(row);
      }
      rethrow;
    }
  }

  Future<ArtDropModel> updateDrop(ArtDropModel drop) async {
    final data = _buildUpdateData(drop);
    try {
      final row = await tablesDb.updateRow(
        databaseId: databaseId,
        tableId: collectionId,
        rowId: drop.id,
        data: data,
      );
      return _mapRow(row);
    } on AppwriteException catch (error) {
      if (data.containsKey(ArtDropModel.fieldArtistName) &&
          _isMissingAttribute(error, ArtDropModel.fieldArtistName)) {
        data.remove(ArtDropModel.fieldArtistName);
        final row = await tablesDb.updateRow(
          databaseId: databaseId,
          tableId: collectionId,
          rowId: drop.id,
          data: data,
        );
        return _mapRow(row);
      }
      rethrow;
    }
  }

  Future<ArtDropModel> updateDropsAvailable(
    String id,
    int dropsAvailable,
  ) async {
    final updateField = appwriteArtDropIncludeDropsAvailableField
        ? ArtDropModel.fieldDropsAvailable
        : ArtDropModel.fieldDropsTotal;
    final row = await tablesDb.updateRow(
      databaseId: databaseId,
      tableId: collectionId,
      rowId: id,
      data: {updateField: dropsAvailable},
    );

    return _mapRow(row);
  }

  Future<ArtDropModel> markAllFound(String id) {
    return updateDropsAvailable(id, 0);
  }

  Future<void> deleteDrop(String id) async {
    await tablesDb.deleteRow(
      databaseId: databaseId,
      tableId: collectionId,
      rowId: id,
    );
  }

  ArtDropModel _mapRow(models.Row row) {
    final data = Map<String, dynamic>.from(row.data);
    data[ArtDropModel.fieldId] = row.$id;
    data[r'$createdAt'] = row.$createdAt;
    return ArtDropModel.fromMap(data);
  }

  Map<String, dynamic> _buildData(
    ArtDropModel drop, {
    required String artistUserId,
    required String artistName,
  }) {
    if (artistUserId.isEmpty) {
      throw StateError('Fehlende artistId fuer das Erstellen des Art-Drops.');
    }
    final data = <String, dynamic>{
      ArtDropModel.fieldArtistUserId: artistUserId,
      ArtDropModel.fieldArtistName:
          artistName.isNotEmpty ? artistName : null,
      ArtDropModel.fieldTitle: drop.title,
      ArtDropModel.fieldDescription:
          drop.description.isEmpty ? null : drop.description,
      ArtDropModel.fieldLocationText: drop.locationText,
      ArtDropModel.fieldLocationLat: drop.locationLat,
      ArtDropModel.fieldLocationLng: drop.locationLng,
      ArtDropModel.fieldDropsTotal: drop.dropsTotal,
    };
    if (appwriteArtDropIncludeDropsAvailableField) {
      data[ArtDropModel.fieldDropsAvailable] = drop.dropsAvailable;
    }
    if (appwriteArtDropIncludeDropImagePathField &&
        drop.dropImagePath != null) {
      data[ArtDropModel.fieldDropImagePath] = drop.dropImagePath;
    }
    if (appwriteArtDropIncludeEnvironmentImagePathField &&
        drop.environmentImagePath != null) {
      data[ArtDropModel.fieldEnvironmentImagePath] =
          drop.environmentImagePath;
    }
    if (appwriteArtDropIncludeIdField) {
      data[ArtDropModel.fieldId] = drop.id;
    }
    if (appwriteArtDropIncludeCreatedAtField) {
      data[ArtDropModel.fieldCreatedAt] = drop.createdAt.toIso8601String();
    }
    data.removeWhere((_, value) => value == null);
    return data;
  }

  Map<String, dynamic> _buildUpdateData(ArtDropModel drop) {
    final data = <String, dynamic>{
      ArtDropModel.fieldTitle: drop.title,
      ArtDropModel.fieldDescription:
          drop.description.isEmpty ? null : drop.description,
      ArtDropModel.fieldLocationText: drop.locationText,
      ArtDropModel.fieldLocationLat: drop.locationLat,
      ArtDropModel.fieldLocationLng: drop.locationLng,
      ArtDropModel.fieldDropsTotal: drop.dropsTotal,
    };
    if (appwriteArtDropIncludeDropsAvailableField) {
      data[ArtDropModel.fieldDropsAvailable] = drop.dropsAvailable;
    }
    if (appwriteArtDropIncludeDropImagePathField &&
        drop.dropImagePath != null) {
      data[ArtDropModel.fieldDropImagePath] = drop.dropImagePath;
    }
    if (appwriteArtDropIncludeEnvironmentImagePathField &&
        drop.environmentImagePath != null) {
      data[ArtDropModel.fieldEnvironmentImagePath] =
          drop.environmentImagePath;
    }
    if (drop.artistUserId != null && drop.artistUserId!.isNotEmpty) {
      data[ArtDropModel.fieldArtistUserId] = drop.artistUserId;
    }
    if (drop.artistName != null && drop.artistName!.isNotEmpty) {
      data[ArtDropModel.fieldArtistName] = drop.artistName;
    }
    data.removeWhere((_, value) => value == null);
    return data;
  }

  bool _isMissingAttribute(AppwriteException error, String field) {
    final message = (error.message ?? '').toLowerCase();
    final lowerField = field.toLowerCase();
    if (!message.contains(lowerField)) {
      return false;
    }
    if (message.contains('attribute not found in schema') ||
        message.contains('unknown attribute') ||
        message.contains('attribute does not exist')) {
      return true;
    }
    final type = (error.type ?? '').toLowerCase();
    return type.contains('query_invalid') || type.contains('invalid_structure');
  }
}
