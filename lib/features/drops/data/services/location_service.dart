import 'package:geolocator/geolocator.dart';
import 'package:art_drop_finder/core/error/exceptions.dart';

class LocationSnapshot {
  final double latitude;
  final double longitude;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
  });

  String get text =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

class LocationService {
  const LocationService();

  Future<LocationSnapshot> lookupCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException('Ortungsdienste sind deaktiviert.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const AppException('Standortfreigabe verweigert.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AppException(
        'Standortfreigabe dauerhaft verweigert. Bitte in den Einstellungen aktivieren.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
