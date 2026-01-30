import 'package:map_launcher/map_launcher.dart' as map_launcher;

Future<bool> isWazeAvailable() async {
  final available =
      await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.waze);
  return available == true;
}

Future<void> openWazeMarker({
  required double latitude,
  required double longitude,
  required String title,
  required String description,
}) {
  return map_launcher.MapLauncher.showMarker(
    mapType: map_launcher.MapType.waze,
    coords: map_launcher.Coords(latitude, longitude),
    title: title,
    description: description,
  );
}
