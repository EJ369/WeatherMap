import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  Future<LatLng> getCurrentLocation(String purpose) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (purpose == "Click") {
        return const LatLng(0.0, 0.0);
      } else {
        return const LatLng(28.6358, 77.2245);
      }
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (purpose == "Click") {
        return const LatLng(0.0, 0.0);
      } else {
        return const LatLng(28.6358, 77.2245);
      }
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (purpose == "Click") {
        return const LatLng(0.0, 0.0);
      } else {
        return const LatLng(28.6358, 77.2245);
      }
    }
  }

  Future<void> setLastLocation(double latitude, double longitude) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("last_latitude", latitude);
    prefs.setDouble("last_longitude", longitude);
  }

  Future<LatLng> getLastLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    double lastLatitude = prefs.getDouble("last_latitude") ?? 28.6358;
    double lastLongitude = prefs.getDouble("last_longitude") ?? 77.2245;
    return LatLng(lastLatitude, lastLongitude);
  }
}

class Result<T> {
  final LatLng? data;
  final String? error;

  Result.success(this.data) : error = null;
  Result.error(this.error) : data = null;
}
