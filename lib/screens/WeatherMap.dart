import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_map/models/WeatherData.dart';
import 'package:weather_map/services/LocationService.dart';
import 'package:weather_map/services/WeatherService.dart';
import 'package:weather_map/widgets/AnimatedMarkerWidget.dart';
import 'package:weather_map/widgets/FlutterMapWidget.dart';
import 'package:weather_map/widgets/MarkerTapWidget.dart';
import 'package:weather_map/widgets/SnackBarWidget.dart';

class WeatherMap extends StatefulWidget {
  const WeatherMap({super.key});

  @override
  WeatherMapState createState() => WeatherMapState();
}

class WeatherMapState extends State<WeatherMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);
  final TextEditingController _searchController = TextEditingController();
  final List<AnimatedMarker> _markers = [];
  Timer? _debounceTimer;
  bool isLoading = false;
  late LatLng _center;

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getLastLocation();
    getLocation("Normal");
  }

  Future<void> getLastLocation() async {
    LocationService locationService = LocationService();
    LatLng lastLocation = await locationService.getLastLocation();
    setState(() {
      _center = lastLocation;

      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        await getCoordinates();
        locationService.setLastLocation(_center.latitude, _center.longitude);
      });
    });
  }

  void _onMarkerTap(BuildContext context, WeatherData weatherData) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MarkerTapWidget(weatherData: weatherData);
      },
    );
  }

  void _onSearch(BuildContext context) async {
    WeatherService weatherService = WeatherService();
    LocationService locationService = LocationService();
    final inputCity = _searchController.text;
    if (inputCity.isNotEmpty) {
      try {
        String city = await weatherService.capitalizeWords(inputCity);
        final coordinates = await weatherService.newFetchCityCoordinates(city);
        if (coordinates.toString().isNotEmpty &&
            (coordinates.latitude != 0.0 && coordinates.longitude != 0.0)) {
          _animatedMapController.animateTo(
            dest: coordinates,
            zoom: 9,
          );
          Future.delayed(const Duration(milliseconds: 500), () async {
            getCoordinates();
            locationService.setLastLocation(
                coordinates.latitude, coordinates.longitude);
          });
        } else {
          SnackBarWidget.showSnackBar(context, "Place not found");
        }
      } catch (e) {
        print('Error fetching coordinates: $e');
      }
    }
  }

  Future<void> addMarker(WeatherData weatherData) async {
    setState(() {
      _markers.add(
        AnimatedMarker(
          point: weatherData.weatherLocation,
          rotate: true,
          builder: (_, animation) {
            double size = 90.0 * animation.value;
            double maxSize = 120.0 * animation.value;
            return AnimatedMarkerWidget(
              weatherData: weatherData,
              onTap: () {
                _onMarkerTap(context, weatherData);
              },
              size: size,
            );
          },
        ),
      );
    });
  }

  Future<void> getLocation(String purpose) async {
    LocationService weatherLocation = LocationService();
    LatLng latLng = await weatherLocation.getCurrentLocation(purpose);
    if (purpose == "Click") {
      if (latLng.latitude == 0.0 && latLng.longitude == 0.0) {
        SnackBarWidget.showSnackBar(context, "Unable to get location");
      } else {
        setState(() {
          _animatedMapController.animateTo(
            dest: LatLng(latLng.latitude, latLng.longitude),
            zoom: 9,
          );
        });
        _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
          await getCoordinates();
          weatherLocation.setLastLocation(latLng.latitude, latLng.longitude);
        });
      }
    } else {
      if (latLng.latitude != 0.0 && latLng.longitude != 0.0) {
        setState(() {
          _animatedMapController.animateTo(
            dest: LatLng(latLng.latitude, latLng.longitude),
            zoom: 9,
          );
        });

        _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
          await getCoordinates();
          weatherLocation.setLastLocation(latLng.latitude, latLng.longitude);
        });
      }
    }
  }

  Future<void> getCoordinates() async {
    WeatherService weatherService = WeatherService();
    setState(() {
      isLoading = true;
    });

    try {
      List<LatLng> gridPoints =
          await weatherService.generateGridPoints(_animatedMapController);
      Set<String> fetchedCities = {};

      for (LatLng latLng in gridPoints) {
        try {
          String city = await weatherService.fetchCityName(latLng);
          if (!fetchedCities.contains(city) && city != "City not found") {
            try {
              LatLng latLng1 =
                  await weatherService.newFetchCityCoordinates(city);
              if (latLng1.latitude != 0.0 && latLng1.longitude != 0.0) {
                WeatherData weatherData =
                    await weatherService.fetchWeather(latLng1, city);
                addMarker(weatherData);
                fetchedCities.add(city);
              }
            } catch (e) {
              print("Error fetching coordinates for city: $city - $e");
              continue;
            }
          }
        } catch (e) {
          print("Error in processing LatLng $latLng: $e");
          continue;
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onPositionChanged(MapCamera position, bool hasGesture) {
    LocationService locationService = LocationService();
    if (hasGesture) {
      _debounceTimer?.cancel();

      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        await getCoordinates();
        locationService.setLastLocation(
            position.center.latitude, position.center.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMapWidget(
          animatedMapController: _animatedMapController,
          center: _center,
          markers: _markers,
          searchController: _searchController,
          onSearch: () {
            _onSearch(context);
          },
          onPositionChanged: _onPositionChanged),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (isLoading)
            const Positioned(
              bottom: 100,
              right: 25,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.black,
              ),
            ),
          Positioned(
            bottom: 30,
            right: 15,
            child: FloatingActionButton(
              onPressed: () {
                getLocation("Click");
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
