class SocialPost {
  final String id;
  final String dropId;
  final String platform;
  final String url;
  final DateTime createdAt;

  const SocialPost({
    required this.id,
    required this.dropId,
    required this.platform,
    required this.url,
    required this.createdAt,
  });

  SocialPost copyWith({
    String? id,
    String? dropId,
    String? platform,
    String? url,
    DateTime? createdAt,
  }) {
    return SocialPost(
      id: id ?? this.id,
      dropId: dropId ?? this.dropId,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
