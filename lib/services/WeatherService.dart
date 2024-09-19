import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/src/animated_map_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

import '../models/WeatherData.dart';

class WeatherService {
  Future<WeatherData> fetchWeather(LatLng latLng, String city) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=${latLng.latitude}&longitude=${latLng.longitude}&current=temperature_2m,relative_humidity_2m,is_day,weather_code,wind_speed_10m&timezone=auto&models=best_match';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      int weatherCode = data['current']['weather_code'];
      List<String> weatherInfo = getWeatherInfo(weatherCode);
      String image = weatherInfo[0];
      String weatherName = weatherInfo[1];

      double temperature = data['current']['temperature_2m'];
      String temperatureUnit = data['current_units']['temperature_2m'];

      int dayNight = data['current']['is_day'];
      double wind = data['current']['wind_speed_10m'];
      int humidity = data['current']['relative_humidity_2m'];

      String weatherImage;
      if (dayNight == 0 && weatherName == "Clear Sky") {
        weatherImage = "assets/icons/weather_night.svg";
      } else {
        weatherImage = image;
      }

      String temp = ' ${temperature.toStringAsFixed(1)} $temperatureUnit';
      String windSpeed = ' $wind';

      return WeatherData(
        weatherLocation: latLng,
        weatherName: weatherName,
        city: city,
        temperature: temp,
        dayNight: dayNight,
        windSpeed: windSpeed,
        humidity: humidity,
        weatherImagePath: weatherImage,
      );
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<String> fetchCityName(LatLng latLng) async {
    try {
      List<Placemark>? placemarks = await GeocodingPlatform.instance
          ?.placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        List<Placemark> filteredPlacemarks = placemarks
            .where((placemark) => placemark.locality != null)
            .toList();

        if (filteredPlacemarks.isNotEmpty) {
          String cityName = filteredPlacemarks.first.locality ?? "";
          return cityName;
        } else {
          return 'City not found';
        }
      } else {
        return 'City not found';
      }
    } catch (e) {
      print('Error fetching city name: $e');
      return 'Error';
    }
  }

  static List<String> getWeatherInfo(int weatherCode) {
    String imagePath;
    String weatherName;

    if (weatherCode == 0) {
      imagePath = 'assets/icons/weather_sunny.svg';
      weatherName = 'Clear sky';
    } else if (weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
      imagePath = 'assets/icons/weather_cloudy.svg';
      weatherName = 'Partly cloudy';
    } else if (weatherCode == 45 || weatherCode == 48) {
      imagePath = 'assets/icons/weather_fog.svg';
      weatherName = 'Fog';
    } else if (weatherCode >= 51 && weatherCode <= 55) {
      imagePath = 'assets/icons/weather_rain.svg';
      weatherName = 'Drizzle';
    } else if (weatherCode >= 61 && weatherCode <= 65) {
      imagePath = 'assets/icons/weather_rain.svg';
      weatherName = 'Rain';
    } else if (weatherCode >= 71 && weatherCode <= 75) {
      imagePath = 'assets/icons/weather_snow.svg';
      weatherName = 'Snow';
    } else if (weatherCode >= 80 && weatherCode <= 82) {
      imagePath = 'assets/icons/weather_cloudy.svg';
      weatherName = 'Rain showers';
    } else if (weatherCode >= 85 && weatherCode <= 86) {
      imagePath = 'assets/icons/weather_snow.svg';
      weatherName = 'Snow showers';
    } else if (weatherCode == 95) {
      imagePath = 'assets/icons/weather_thunderstorm.svg';
      weatherName = 'Thunderstorm';
    } else if (weatherCode == 96 || weatherCode == 99) {
      imagePath = 'assets/icons/weather_thunderstorm.svg';
      weatherName = 'Thunderstorm with hail';
    } else {
      imagePath = 'Unknown';
      weatherName = 'Unknown weather condition';
    }

    return [imagePath, weatherName];
  }

  Future<LatLng> newFetchCityCoordinates(String city) async {
    final url =
        'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=en&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'] != null && data['results'].toString().isNotEmpty) {
        double latitude = data['results'][0]['latitude'];
        double longitude = data['results'][0]['longitude'];

        LatLng mCoordinates = LatLng(latitude, longitude);
        return mCoordinates;
      } else {
        return const LatLng(0, 0);
        //throw Exception('No results found in the response');
      }
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<List<LatLng>> generateGridPoints(AnimatedMapController animatedMapController) async {
    LatLngBounds bounds =
        animatedMapController.mapController.camera.visibleBounds;
    List<LatLng> points = [];
    int gridSize = 2;

    LatLng center = LatLng(
      (bounds.northEast.latitude + bounds.southWest.latitude) / 2,
      (bounds.northEast.longitude + bounds.southWest.longitude) / 2,
    );

    double latStep =
        (bounds.northEast.latitude - bounds.southWest.latitude) / gridSize;
    double lngStep =
        (bounds.northEast.longitude - bounds.southWest.longitude) / gridSize;

    double offsetFactor = 0.4;

    for (int i = 0; i <= gridSize; i++) {
      for (int j = 0; j <= gridSize; j++) {
        double lat = bounds.southWest.latitude + (i * latStep);
        double lng = bounds.southWest.longitude + (j * lngStep);

        if (lat > center.latitude) {
          lat -= latStep * offsetFactor;
        } else if (lat < center.latitude) {
          lat += latStep * offsetFactor;
        }

        if (lng > center.longitude) {
          lng -= lngStep * offsetFactor;
        } else if (lng < center.longitude) {
          lng += lngStep * offsetFactor;
        }

        LatLng point = LatLng(lat, lng);

        if (!points.contains(point)) {
          points.add(point);
        }
      }
    }

    return points;
  }

  Future<String> capitalizeWords(String input) async {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}