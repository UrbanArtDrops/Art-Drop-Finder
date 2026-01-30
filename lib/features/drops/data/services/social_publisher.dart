import 'package:flutter/foundation.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';

class SocialPublisher {
  final String facebookGroup;
  final String instagramInbox;

  const SocialPublisher({
    this.facebookGroup = 'Art Drop Finder',
    this.instagramInbox = 'ArtDropFinder',
  });

  Future<void> publish(ArtDrop drop) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final photo =
        drop.dropImagePath ?? drop.environmentImagePath ?? 'no photo';
    debugPrint(
      'Published "${drop.title}" with photo "$photo" to '
      'Facebook group "$facebookGroup" and Instagram inbox "$instagramInbox".',
    );
  }
}
