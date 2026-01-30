import 'package:flutter/foundation.dart';
import 'package:art_drop_finder/core/usecase/usecase.dart';
import 'package:art_drop_finder/features/drops/data/services/image_storage.dart';
import 'package:art_drop_finder/features/drops/data/services/location_service.dart';
import 'package:art_drop_finder/features/drops/data/services/social_publisher.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/entities/drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/entities/social_post.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/create_drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/create_art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/create_drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/delete_art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/delete_drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_drop_claims.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_art_drops.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_drop_images.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_social_posts.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/mark_all_found.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/update_art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/update_drops_available.dart';
import 'package:image_picker/image_picker.dart';

class DropsController extends ChangeNotifier {
  final CreateArtDrop createArtDrop;
  final CreateDropClaim createDropClaim;
  final CreateDropImage createDropImage;
  final DeleteArtDrop deleteArtDrop;
  final DeleteDropImage deleteDropImage;
  final ListArtDrops listArtDrops;
  final ListDropClaims listDropClaims;
  final ListDropImages listDropImages;
  final ListSocialPosts listSocialPosts;
  final UpdateArtDrop updateArtDrop;
  final UpdateDropsAvailable updateDropsAvailable;
  final MarkAllFound markAllFound;
  final SocialPublisher socialPublisher;
  final LocationService locationService;
  final ImageStorage imageStorage;

  DropsController({
    required this.createArtDrop,
    required this.createDropClaim,
    required this.createDropImage,
    required this.deleteArtDrop,
    required this.deleteDropImage,
    required this.listArtDrops,
    required this.listDropClaims,
    required this.listDropImages,
    required this.listSocialPosts,
    required this.updateArtDrop,
    required this.updateDropsAvailable,
    required this.markAllFound,
    required this.socialPublisher,
    required this.locationService,
    required this.imageStorage,
  });

  List<ArtDrop> _drops = [];
  bool _isPublishing = false;
  Map<String, List<DropClaim>> _dropClaimsById = {};
  Map<String, List<SocialPost>> _socialPostsById = {};
  Map<String, List<String>> _dropImagesById = {};
  Map<String, List<String>> _environmentImagesById = {};
  Map<String, List<DropImage>> _dropImageEntriesById = {};
  Map<String, List<DropImage>> _environmentImageEntriesById = {};

  List<ArtDrop> get drops => List.unmodifiable(_drops);
  bool get isPublishing => _isPublishing;
  List<DropClaim> claimsForDrop(String dropId) =>
      _dropClaimsById[dropId] ?? const <DropClaim>[];
  List<SocialPost> postsForDrop(String dropId) =>
      _socialPostsById[dropId] ?? const <SocialPost>[];
  List<String> dropImagesForDrop(String dropId) =>
      _dropImagesById[dropId] ?? const <String>[];
  List<String> environmentImagesForDrop(String dropId) =>
      _environmentImagesById[dropId] ?? const <String>[];
  List<DropImage> dropImageEntriesForDrop(String dropId) =>
      _dropImageEntriesById[dropId] ?? const <DropImage>[];
  List<DropImage> environmentImageEntriesForDrop(String dropId) =>
      _environmentImageEntriesById[dropId] ?? const <DropImage>[];

  Future<void> load() async {
    try {
      _drops = await listArtDrops(const NoParams());
    } catch (error) {
      debugPrint('Art-Drops konnten nicht geladen werden: $error');
    } finally {
      notifyListeners();
    }
    await _loadExtras();
  }

  Future<void> createAndPublish({
    required String title,
    required String description,
    required String locationText,
    required double locationLat,
    required double locationLng,
    required int dropsTotal,
    List<XFile> dropImageFiles = const [],
    List<XFile> environmentImageFiles = const [],
  }) async {
    _isPublishing = true;
    notifyListeners();

    try {
      final dropImages = await _persistImages(dropImageFiles);
      final environmentImages = await _persistImages(environmentImageFiles);
      final primaryDropImagePath = dropImages.isEmpty
          ? null
          : dropImages.first.path;
      final primaryEnvironmentImagePath = environmentImages.isEmpty
          ? null
          : environmentImages.first.path;
      final createdDrop = await createArtDrop(
        CreateArtDropParams(
          title: title,
          description: description,
          locationText: locationText,
          locationLat: locationLat,
          locationLng: locationLng,
          dropsTotal: dropsTotal,
          dropImagePath: primaryDropImagePath,
          environmentImagePath: primaryEnvironmentImagePath,
        ),
      );
      final imageTasks = <Future<DropImage>>[];
      for (final image in dropImages) {
        imageTasks.add(
          createDropImage(
            CreateDropImageParams(
              dropId: createdDrop.id,
              imagePath: image.path,
              imageType: 'drop',
              imageFormat: image.format,
            ),
          ),
        );
      }
      for (final image in environmentImages) {
        imageTasks.add(
          createDropImage(
            CreateDropImageParams(
              dropId: createdDrop.id,
              imagePath: image.path,
              imageType: 'environment',
              imageFormat: image.format,
            ),
          ),
        );
      }
      if (imageTasks.isNotEmpty) {
        await Future.wait(imageTasks);
      }
      _drops = await listArtDrops(const NoParams());
      await _loadExtras();
      notifyListeners();
      await socialPublisher.publish(
        createdDrop.copyWith(
          dropImagePath: primaryDropImagePath,
          environmentImagePath: primaryEnvironmentImagePath,
        ),
      );
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  Future<void> addImages({
    required String dropId,
    required List<XFile> files,
    required String imageType,
  }) async {
    if (files.isEmpty) {
      return;
    }
    final images = await _persistImages(files);
    if (images.isEmpty) {
      return;
    }
    final tasks = <Future<DropImage>>[];
    for (final image in images) {
      tasks.add(
        createDropImage(
          CreateDropImageParams(
            dropId: dropId,
            imagePath: image.path,
            imageType: imageType,
            imageFormat: image.format,
          ),
        ),
      );
    }
    await Future.wait(tasks);
    await _loadExtras();
  }

  Future<void> removeImage(DropImage image) async {
    if (image.id.isEmpty) {
      return;
    }
    await deleteDropImage(DeleteDropImageParams(imageId: image.id));
    await _loadExtras();
  }

  Future<void> deleteDrop(String id) async {
    await deleteArtDrop(DeleteArtDropParams(id: id));
    _drops = await listArtDrops(const NoParams());
    await _loadExtras();
    notifyListeners();
  }

  Future<void> claimDrop({
    required String dropId,
    required String claimerName,
    String? comment,
  }) async {
    await createDropClaim(
      CreateDropClaimParams(
        dropId: dropId,
        claimerName: claimerName,
        comment: comment,
      ),
    );
    await _loadExtras();
    notifyListeners();
  }

  Future<List<PersistedImage>> _persistImages(List<XFile> files) async {
    if (files.isEmpty) {
      return [];
    }
    final uploads = <PersistedImage>[];
    for (final file in files) {
      final persisted = await imageStorage.persistImage(file);
      if (persisted.path.trim().isNotEmpty) {
        uploads.add(persisted);
      }
    }
    return uploads;
  }

  Future<void> updateAvailable({
    required String id,
    required int available,
  }) async {
    await updateDropsAvailable(
      UpdateDropsAvailableParams(id: id, dropsAvailable: available),
    );
    _drops = await listArtDrops(const NoParams());
    await _loadExtras();
    notifyListeners();
  }

  Future<void> updateDrop({
    required ArtDrop drop,
    required String title,
    required String description,
    required String locationText,
    required double locationLat,
    required double locationLng,
    required int dropsTotal,
  }) async {
    await updateArtDrop(
      UpdateArtDropParams(
        drop: drop,
        title: title,
        description: description,
        locationText: locationText,
        locationLat: locationLat,
        locationLng: locationLng,
        dropsTotal: dropsTotal,
      ),
    );
    _drops = await listArtDrops(const NoParams());
    await _loadExtras();
    notifyListeners();
  }

  Future<void> markFound(String id) async {
    await markAllFound(MarkAllFoundParams(id: id));
    _drops = await listArtDrops(const NoParams());
    await _loadExtras();
    notifyListeners();
  }

  Future<void> _loadExtras() async {
    if (_drops.isEmpty) {
      _dropClaimsById = {};
      _socialPostsById = {};
      _dropImagesById = {};
      _environmentImagesById = {};
      _dropImageEntriesById = {};
      _environmentImageEntriesById = {};
      notifyListeners();
      return;
    }
    try {
      final dropIds = _drops.map((drop) => drop.id).toList();
      final results = await Future.wait([
        listDropClaims(ListDropClaimsParams(dropIds: dropIds)),
        listSocialPosts(ListSocialPostsParams(dropIds: dropIds)),
        listDropImages(ListDropImagesParams(dropIds: dropIds)),
      ]);
      final claims = results[0] as List<DropClaim>;
      final posts = results[1] as List<SocialPost>;
      final images = results[2] as List<DropImage>;
      try {
        _dropClaimsById = _groupClaims(claims);
      } catch (e) {
        debugPrint('Error grouping drop claims: $e');
      }
      try {
        _socialPostsById = _groupPosts(posts);
      } catch (e) {
        debugPrint('Error grouping social posts: $e');
      }
      try {
        final imageBuckets = _groupImages(images);
        _dropImagesById = imageBuckets.dropImagesById;
        _environmentImagesById = imageBuckets.environmentImagesById;
        _dropImageEntriesById = imageBuckets.dropImageEntriesById;
        _environmentImageEntriesById = imageBuckets.environmentImageEntriesById;
      } catch (e) {
        debugPrint('Error assigning drop images by ID: $e');
      }
      try {
        _drops = _applyImagePaths(_drops);
      } catch (e) {
        debugPrint('Error applying image paths to drops: $e');
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Drop-Details konnten nicht geladen werden: $error');
    }
  }

  Map<String, List<DropClaim>> _groupClaims(List<DropClaim> claims) {
    final grouped = <String, List<DropClaim>>{};
    for (final claim in claims) {
      final dropId = claim.dropId.trim();
      if (dropId.isEmpty) {
        continue;
      }
      grouped.putIfAbsent(dropId, () => []).add(claim);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => b.claimedAt.compareTo(a.claimedAt));
    }
    return grouped;
  }

  Map<String, List<SocialPost>> _groupPosts(List<SocialPost> posts) {
    final grouped = <String, List<SocialPost>>{};
    for (final post in posts) {
      grouped.putIfAbsent(post.dropId, () => []).add(post);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return grouped;
  }

  _ImageBuckets _groupImages(List<DropImage> images) {
    final dropImages = <String, List<DropImage>>{};
    final environmentImages = <String, List<DropImage>>{};
    final unknownImages = <String, List<DropImage>>{};

    for (final image in images) {
      final type = _normalizeImageType(image.imageType);
      if (type == _ImageType.drop) {
        dropImages.putIfAbsent(image.artDropId, () => []).add(image);
      } else if (type == _ImageType.environment) {
        environmentImages.putIfAbsent(image.artDropId, () => []).add(image);
      } else {
        unknownImages.putIfAbsent(image.artDropId, () => []).add(image);
      }
    }

    _sortByCreatedAt(dropImages, newestFirst: true);
    _sortByCreatedAt(environmentImages, newestFirst: true);
    _sortByCreatedAt(unknownImages, newestFirst: false);

    final dropPathsById = <String, List<String>>{};
    final envPathsById = <String, List<String>>{};
    final dropEntriesById = <String, List<DropImage>>{};
    final envEntriesById = <String, List<DropImage>>{};

    void addPath(Map<String, List<String>> target, String dropId, String path) {
      if (path.trim().isEmpty) {
        return;
      }
      target.putIfAbsent(dropId, () => []).add(path);
    }

    void addEntry(
      Map<String, List<DropImage>> target,
      String dropId,
      DropImage image,
    ) {
      if (image.imagePath.trim().isEmpty) {
        return;
      }
      target.putIfAbsent(dropId, () => []).add(image);
    }

    void addAll(
      Map<String, List<DropImage>> source,
      Map<String, List<String>> pathTarget,
      Map<String, List<DropImage>> entryTarget,
    ) {
      for (final entry in source.entries) {
        for (final image in entry.value) {
          addPath(pathTarget, entry.key, image.imagePath);
          addEntry(entryTarget, entry.key, image);
        }
      }
    }

    addAll(dropImages, dropPathsById, dropEntriesById);
    addAll(environmentImages, envPathsById, envEntriesById);

    for (final entry in unknownImages.entries) {
      final dropId = entry.key;
      final list = entry.value;
      var index = 0;
      if ((dropPathsById[dropId] ?? []).isEmpty && list.isNotEmpty) {
        addPath(dropPathsById, dropId, list[index].imagePath);
        addEntry(dropEntriesById, dropId, list[index]);
        index++;
      }
      if ((envPathsById[dropId] ?? []).isEmpty && index < list.length) {
        addPath(envPathsById, dropId, list[index].imagePath);
        addEntry(envEntriesById, dropId, list[index]);
        index++;
      }
      for (; index < list.length; index++) {
        addPath(dropPathsById, dropId, list[index].imagePath);
        addEntry(dropEntriesById, dropId, list[index]);
      }
    }

    return _ImageBuckets(
      dropImagesById: dropPathsById,
      environmentImagesById: envPathsById,
      dropImageEntriesById: dropEntriesById,
      environmentImageEntriesById: envEntriesById,
    );
  }

  void _sortByCreatedAt(
    Map<String, List<DropImage>> buckets, {
    required bool newestFirst,
  }) {
    for (final entry in buckets.entries) {
      entry.value.sort(
        (a, b) => newestFirst
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt),
      );
    }
  }

  _ImageType _normalizeImageType(String? rawType) {
    final value = (rawType ?? '').trim().toLowerCase();
    switch (value) {
      case 'drop':
      case 'drop_image':
      case 'dropimage':
      case 'dropfoto':
      case 'drop_foto':
        return _ImageType.drop;
      case 'environment':
      case 'surroundings':
      case 'environment_image':
      case 'umgebung':
      case 'umgebungsfoto':
        return _ImageType.environment;
    }
    return _ImageType.unknown;
  }

  List<ArtDrop> _applyImagePaths(List<ArtDrop> drops) {
    return drops.map((drop) {
      final dropImages = _dropImagesById[drop.id];
      final envImages = _environmentImagesById[drop.id];
      return drop.copyWith(
        dropImagePath: (dropImages != null && dropImages.isNotEmpty)
            ? dropImages.first
            : drop.dropImagePath,
        environmentImagePath: (envImages != null && envImages.isNotEmpty)
            ? envImages.first
            : drop.environmentImagePath,
      );
    }).toList();
  }

  Future<LocationSnapshot> lookupCurrentLocation() {
    return locationService.lookupCurrentLocation();
  }
}

enum _ImageType { drop, environment, unknown }

class _ImageBuckets {
  final Map<String, List<String>> dropImagesById;
  final Map<String, List<String>> environmentImagesById;
  final Map<String, List<DropImage>> dropImageEntriesById;
  final Map<String, List<DropImage>> environmentImageEntriesById;

  const _ImageBuckets({
    required this.dropImagesById,
    required this.environmentImagesById,
    required this.dropImageEntriesById,
    required this.environmentImageEntriesById,
  });
}
