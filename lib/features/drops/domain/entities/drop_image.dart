class DropImage {
  final String id;
  final String artDropId;
  final String imagePath;
  final String? imageType;
  final String? imageFormat;
  final DateTime createdAt;

  const DropImage({
    required this.id,
    required this.artDropId,
    required this.imagePath,
    this.imageType,
    this.imageFormat,
    required this.createdAt,
  });

  DropImage copyWith({
    String? id,
    String? dropId,
    String? imagePath,
    String? imageType,
    String? imageFormat,
    DateTime? createdAt,
  }) {
    return DropImage(
      id: id ?? this.id,
      artDropId: dropId ?? artDropId,
      imagePath: imagePath ?? this.imagePath,
      imageType: imageType ?? this.imageType,
      imageFormat: imageFormat ?? this.imageFormat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
