# Art Drop Finder

Art Drop Finder is a Flutter app for running urban art drop hunts. Artists
publish drop locations and photos, the public sees nearby drops on a map, and
finders can claim a drop via a QR code link.

## Features
- Public map and list of drops with photos and claim counts
- Location privacy: active drops show a 1 km radius; exact pins unlock once all
  drops are claimed
- Artist login to create, edit, and manage drops
- Drop creation with camera/gallery photos, GPS lookup, and drop counts
- Shareable claim page with QR code and claim history
- Mobile map handoff to Waze (Android/iOS)

## Tech stack
- Flutter 3.10+
- Appwrite (Database, Storage, Auth)
- OpenStreetMap tiles via flutter_map
- Geolocator for GPS
- QR generation via qr_flutter

## Getting started

### Prerequisites
- Flutter SDK (>= 3.10.3)
- An Appwrite project (Cloud or self-hosted)

### Configure Appwrite
Update the Appwrite constants in `lib/core/appwrite_client.dart`:
- `appwriteEndpoint`
- `appwriteProjectId`
- `appwriteDatabaseId`
- `appwriteArtDropsCollectionId`
- `appwriteDropClaimsCollectionId`
- `appwriteSocialPostsCollectionId`
- `appwriteDropImagesCollectionId`
- `appwriteArtDropImagesBucketId`

### Recommended database schema
The data layer is tolerant of missing fields, but the schema below matches the
default field names used by the app.

`art_drops`:
- `artistId` (string)
- `artistName` (string, optional)
- `title` (string)
- `description` (string)
- `locationText` (string)
- `locationLat` (double)
- `locationLng` (double)
- `dropsTotal` (int)
- `dropsAvailable` (int, optional)
- `dropImagePath` (string, optional)
- `environmentImagePath` (string, optional)

`drop_claims`:
- `dropId` ()
- `claimerName` (string)
- `comment` (string, optional)
- `claimedAt` (datetime, optional)

`drop_images`:
- `artDropId` (string)
- `imagePath` (string)
- `imageType` (string, optional; e.g. `drop` or `environment`)
- `imageFormat` (string, optional)
- `createdAt` (datetime, optional)

`social_posts`:
- `dropId` (string)
- `platform` (string)
- `url` (string)
- `createdAt` (datetime, optional)

### Storage bucket
Create a storage bucket for drop images and set read permissions so the public
home screen can display images (public read or your preferred access model).

### Artist accounts
Create Appwrite users for artists. Add the `admin` label to users who should be
able to manage all drops.

## Run the app
```bash
flutter pub get
flutter run
```

Run on web:
```bash
flutter run -d chrome
```

## Notes
- The social publishing service is currently a stub in
  `lib/features/drops/data/services/social_publisher.dart`. Replace it with
  real integrations if needed.
- Image metadata is stripped before upload for privacy.
- The claim page is routed at `/claim?dropId=...` (web builds use the hash
  fragment if present).

## License
MIT. See `LICENSE`.
