import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// Best-effort device location for features (weather, "nearby" listings)
/// that read better with a real fix than a fallback. Every failure path
/// (permission denied, location services off, timeout) returns null rather
/// than throwing — callers are expected to fall back gracefully, never to
/// block on this.
class LocationService {
  Future<Position?> getCurrentPosition() async {
    Position? lastKnownPosition;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      // A cached fix is preferable to a fabricated server default and gives
      // us a reliable fallback indoors, where a fresh GPS fix can take time.
      lastKnownPosition = await Geolocator.getLastKnownPosition();

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      return lastKnownPosition;
    }
  }
}

@Riverpod(keepAlive: true)
LocationService locationService(LocationServiceRef ref) => LocationService();
