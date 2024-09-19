import 'package:latlong2/latlong.dart';

class WeatherData {
  final LatLng weatherLocation;
  final String weatherName;
  final String city;
  final String temperature;
  final int dayNight;
  final String windSpeed;
  final int humidity;
  final String weatherImagePath;

  WeatherData({
    required this.weatherLocation,
    required this.weatherName,
    required this.city,
    required this.temperature,
    required this.dayNight,
    required this.windSpeed,
    required this.humidity,
    required this.weatherImagePath,
  });
}