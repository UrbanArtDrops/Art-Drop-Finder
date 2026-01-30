class ArtDrop {
  final String id;
  final String? artistUserId;
  final String? artistName;
  final String title;
  final String description;
  final String locationText;
  final double locationLat;
  final double locationLng;
  final int dropsTotal;
  final int dropsAvailable;
  final String? dropImagePath;
  final String? environmentImagePath;
  final DateTime createdAt;

  const ArtDrop({
    required this.id,
    this.artistUserId,
    this.artistName,
    required this.title,
    required this.description,
    required this.locationText,
    required this.locationLat,
    required this.locationLng,
    required this.dropsTotal,
    required this.dropsAvailable,
    this.dropImagePath,
    this.environmentImagePath,
    required this.createdAt,
  });

  bool get allFound => dropsAvailable <= 0;

  ArtDrop copyWith({
    String? id,
    String? artistUserId,
    String? artistName,
    String? title,
    String? description,
    String? locationText,
    double? locationLat,
    double? locationLng,
    int? dropsTotal,
    int? dropsAvailable,
    String? dropImagePath,
    String? environmentImagePath,
    DateTime? createdAt,
  }) {
    return ArtDrop(
      id: id ?? this.id,
      artistUserId: artistUserId ?? this.artistUserId,
      artistName: artistName ?? this.artistName,
      title: title ?? this.title,
      description: description ?? this.description,
      locationText: locationText ?? this.locationText,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      dropsTotal: dropsTotal ?? this.dropsTotal,
      dropsAvailable: dropsAvailable ?? this.dropsAvailable,
      dropImagePath: dropImagePath ?? this.dropImagePath,
      environmentImagePath:
          environmentImagePath ?? this.environmentImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
