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
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 8)),
      );
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
LocationService locationService(LocationServiceRef ref) => LocationService();
