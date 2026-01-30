import 'dart:core' as debug;
import 'dart:core';

import 'package:appwrite/appwrite.dart';
import 'package:art_drop_finder/core/appwrite_client.dart';
import 'package:art_drop_finder/features/drops/data/models/drop_claim_model.dart';
import 'package:art_drop_finder/features/drops/data/models/drop_image_model.dart';
import 'package:art_drop_finder/features/drops/data/models/social_post_model.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class DropExtrasRemoteDataSource {
  final TablesDB tablesDb;
  final String databaseId;
  final String claimsCollectionId;
  final String postsCollectionId;
  final String imagesCollectionId;

  DropExtrasRemoteDataSource({
    TablesDB? tablesDb,
    this.databaseId = appwriteDatabaseId,
    this.claimsCollectionId = appwriteDropClaimsCollectionId,
    this.postsCollectionId = appwriteSocialPostsCollectionId,
    this.imagesCollectionId = appwriteDropImagesCollectionId,
  }) : tablesDb = tablesDb ?? appwriteTablesDb;

  Future<List<DropClaimModel>> listDropClaimsForDrops(
    List<String> dropIds,
  ) async {
    if (dropIds.isEmpty) {
      return [];
    }
    final normalizedDropIds = dropIds
        .map((dropId) => dropId.trim())
        .where((dropId) => dropId.isNotEmpty)
        .toList();
    if (normalizedDropIds.isEmpty) {
      return [];
    }
    final numericDropIds = <int>[];
    for (final dropId in normalizedDropIds) {
      final parsed = int.tryParse(dropId);
      if (parsed != null) {
        numericDropIds.add(parsed);
      }
    }
    final documents = <models.Row>[];
    final primaryDocuments = await _listByDropId(
      collectionId: claimsCollectionId,
      dropIdField: DropClaimModel.fieldDropId,
      dropIds: normalizedDropIds,
    );
    documents.addAll(primaryDocuments);
    if (primaryDocuments.isEmpty && numericDropIds.isNotEmpty) {
      documents.addAll(
        await _listByDropId(
          collectionId: claimsCollectionId,
          dropIdField: DropClaimModel.fieldDropId,
          dropIds: numericDropIds,
        ),
      );
    }
    var fallbackDocuments = await _listByDropId(
      collectionId: claimsCollectionId,
      dropIdField: 'artDropId',
      dropIds: normalizedDropIds,
    );
    if (fallbackDocuments.isEmpty && numericDropIds.isNotEmpty) {
      fallbackDocuments = await _listByDropId(
        collectionId: claimsCollectionId,
        dropIdField: 'artDropId',
        dropIds: numericDropIds,
      );
    }
    documents.addAll(fallbackDocuments);
    var pluralDocuments = await _listByDropId(
      collectionId: claimsCollectionId,
      dropIdField: 'artDrops',
      dropIds: normalizedDropIds,
    );
    if (pluralDocuments.isEmpty && numericDropIds.isNotEmpty) {
      pluralDocuments = await _listByDropId(
        collectionId: claimsCollectionId,
        dropIdField: 'artDrops',
        dropIds: numericDropIds,
      );
    }
    documents.addAll(pluralDocuments);
    final combined = _dedupeRows(documents);
    return combined.map(_mapClaimRow).toList();
  }

  Future<DropClaimModel> createDropClaim(DropClaimModel claim) async {
    final dropIdValue = claim.dropId.trim();
    final nameValue = claim.claimerName.trim();
    final baseData = <String, dynamic>{
      DropClaimModel.fieldClaimedAt: claim.claimedAt.toIso8601String(),
    };
    final comment = claim.comment?.trim();
    if (comment != null && comment.isNotEmpty) {
      baseData[DropClaimModel.fieldComment] = comment;
    }
    baseData.removeWhere((_, value) => value == null);
    final nameFields = <String>[];
    void addNameField(String field) {
      if (field.isEmpty || nameFields.contains(field)) {
        return;
      }
      nameFields.add(field);
    }

    addNameField(DropClaimModel.fieldClaimerName);
    addNameField('claimantName');
    addNameField('claimerName');

    AppwriteException? lastError;
    for (final nameField in nameFields) {
      final dataWithName = Map<String, dynamic>.from(baseData)
        ..[nameField] = nameValue;
      try {
        return await _createClaimWithDropIdFallback(
          dropIdValue: dropIdValue,
          baseData: dataWithName,
        );
      } on AppwriteException catch (error) {
        lastError = error;
        if (_isMissingAnyAttribute(error, nameFields)) {
          continue;
        }
        if (_isMissingAttribute(error, nameField)) {
          continue;
        }
        rethrow;
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    throw AppwriteException('Unable to create claim', 400);
  }

  Future<List<SocialPostModel>> listSocialPostsForDrops(
    List<String> dropIds,
  ) async {
    if (dropIds.isEmpty) {
      return [];
    }
    final documents = await _listByDropId(
      collectionId: postsCollectionId,
      dropIdField: SocialPostModel.fieldDropId,
      dropIds: dropIds,
    );
    final fallbackDocuments = documents.isEmpty
        ? await _listByDropId(
            collectionId: postsCollectionId,
            dropIdField: 'artDropId',
            dropIds: dropIds,
          )
        : <models.Row>[];
    final combined = _dedupeRows([...documents, ...fallbackDocuments]);
    return combined.map(_mapPostRow).toList();
  }

  Future<List<DropImageModel>> listDropImagesForDrops(
    List<String> dropIds,
  ) async {
    if (dropIds.isEmpty) {
      return [];
    }
    final normalizedDropIds = dropIds
        .map((dropId) => dropId.trim())
        .where((dropId) => dropId.isNotEmpty)
        .toList();
    if (normalizedDropIds.isEmpty) {
      return [];
    }
    try {
      final documents = await _listByDropId(
        collectionId: imagesCollectionId,
        dropIdField: DropImageModel.fieldDropId,
        dropIds: normalizedDropIds,
      );
      final fallbackDocuments = documents.isEmpty
          ? await _listByDropId(
              collectionId: imagesCollectionId,
              dropIdField: 'dropId',
              dropIds: normalizedDropIds,
            )
          : <models.Row>[];
      final combined = _dedupeRows([...documents, ...fallbackDocuments]);
      return combined.map(_mapImageRow).toList();
    } catch (e) {
      if (kDebugMode) {
        debug.print('Error fetching drop images: $e');
      }
      return [];
    }
  }

  Future<DropImageModel> createDropImage(DropImageModel image) async {
    final dropIdValue = image.artDropId.trim();
    final imageType = image.imageType?.trim();
    final data = <String, dynamic>{
      DropImageModel.fieldDropId: dropIdValue,
      DropImageModel.fieldImagePath: image.imagePath,
      DropImageModel.fieldCreatedAt: image.createdAt.toIso8601String(),
    };
    final imageFormat = DropImageModel.normalizeImageFormat(image.imageFormat);
    if (imageFormat != null) {
      data[DropImageModel.fieldImageFormat] = imageFormat;
    }
    if (appwriteDropImagesIncludeTypeField &&
        imageType != null &&
        imageType.isNotEmpty) {
      data[appwriteDropImagesTypeField] = imageType;
    }
    data.removeWhere((_, value) => value == null);
    try {
      final row = await tablesDb.createRow(
        databaseId: databaseId,
        tableId: imagesCollectionId,
        rowId: ID.unique(),
        data: data,
      );
      return _mapImageRow(row);
    } on AppwriteException catch (error) {
      if (data.containsKey(appwriteDropImagesTypeField) &&
          _isMissingAttribute(error, appwriteDropImagesTypeField)) {
        final fallbackData = Map<String, dynamic>.from(data)
          ..remove(appwriteDropImagesTypeField);
        final row = await tablesDb.createRow(
          databaseId: databaseId,
          tableId: imagesCollectionId,
          rowId: ID.unique(),
          data: fallbackData,
        );
        return _mapImageRow(row);
      }
      rethrow;
    }
  }

  Future<void> deleteDropImage(String imageId) async {
    await tablesDb.deleteRow(
      databaseId: databaseId,
      tableId: imagesCollectionId,
      rowId: imageId,
    );
  }

  Future<List<models.Row>> _listByDropId({
    required String collectionId,
    required String dropIdField,
    required List<dynamic> dropIds,
  }) async {
    try {
      final result = await tablesDb.listRows(
        databaseId: databaseId,
        tableId: collectionId,
        queries: [
          Query.equal(dropIdField, dropIds),
          Query.orderDesc(r'$createdAt'),
        ],
      );
      return result.rows;
    } on AppwriteException catch (error) {
      if (_isMissingAttribute(error, dropIdField)) {
        return [];
      }
      rethrow;
    }
  }

  DropClaimModel _mapClaimRow(models.Row row) {
    final data = Map<String, dynamic>.from(row.data);
    data[DropClaimModel.fieldId] = row.$id;
    data[r'$createdAt'] = row.$createdAt;
    return DropClaimModel.fromMap(data);
  }

  SocialPostModel _mapPostRow(models.Row row) {
    final data = Map<String, dynamic>.from(row.data);
    data[SocialPostModel.fieldId] = row.$id;
    data[r'$createdAt'] = row.$createdAt;
    return SocialPostModel.fromMap(data);
  }

  DropImageModel _mapImageRow(models.Row row) {
    final data = Map<String, dynamic>.from(row.data);
    data[DropImageModel.fieldId] = row.$id;
    data[r'$createdAt'] = row.$createdAt;
    return DropImageModel.fromMap(data);
  }

  List<models.Row> _dedupeRows(List<models.Row> rows) {
    final seen = <String>{};
    final deduped = <models.Row>[];
    for (final row in rows) {
      if (seen.add(row.$id)) {
        deduped.add(row);
      }
    }
    return deduped;
  }

  Future<DropClaimModel> _createClaimRow({
    required String dropIdField,
    required Object dropIdValue,
    required Map<String, dynamic> baseData,
  }) async {
    final data = Map<String, dynamic>.from(baseData)
      ..[dropIdField] = dropIdValue;
    while (true) {
      try {
        final row = await tablesDb.createRow(
          databaseId: databaseId,
          tableId: claimsCollectionId,
          rowId: ID.unique(),
          data: data,
        );
        return _mapClaimRow(row);
      } on AppwriteException catch (error) {
        if (data.containsKey(DropClaimModel.fieldComment) &&
            _isMissingAttribute(error, DropClaimModel.fieldComment)) {
          data.remove(DropClaimModel.fieldComment);
          continue;
        }
        if (data.containsKey(DropClaimModel.fieldClaimedAt) &&
            _isMissingAttribute(error, DropClaimModel.fieldClaimedAt)) {
          data.remove(DropClaimModel.fieldClaimedAt);
          continue;
        }
        rethrow;
      }
    }
  }

  Future<DropClaimModel> _createClaimWithDropIdFallback({
    required String dropIdValue,
    required Map<String, dynamic> baseData,
  }) async {
    AppwriteException? lastError;
    for (final field in [
      DropClaimModel.fieldDropId,
      'artDropId',
      'artDrops',
    ]) {
      try {
        return await _createClaimRow(
          dropIdField: field,
          dropIdValue: dropIdValue,
          baseData: baseData,
        );
      } on AppwriteException catch (error) {
        lastError = error;
        if (field == 'artDrops' && _isInvalidStructure(error)) {
          try {
            return await _createClaimRow(
              dropIdField: field,
              dropIdValue: [dropIdValue],
              baseData: baseData,
            );
          } on AppwriteException catch (nestedError) {
            lastError = nestedError;
            if (_isMissingAttribute(nestedError, field)) {
              continue;
            }
            rethrow;
          }
        }
        if (_isMissingAttribute(error, field)) {
          continue;
        }
        rethrow;
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    throw AppwriteException('Unable to create claim', 400);
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

  bool _isInvalidStructure(AppwriteException error) {
    final type = (error.type ?? '').toLowerCase();
    if (type.contains('invalid_structure')) {
      return true;
    }
    final message = (error.message ?? '').toLowerCase();
    return message.contains('invalid structure') ||
        message.contains('invalid document') ||
        message.contains('invalid data');
  }

  bool _isMissingAnyAttribute(
    AppwriteException error,
    List<String> fields,
  ) {
    for (final field in fields) {
      if (_isMissingAttribute(error, field)) {
        return true;
      }
    }
    return false;
  }
}
