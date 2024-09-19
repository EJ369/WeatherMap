import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:weather_map/widgets/SearchBarWidget.dart';

class FlutterMapWidget extends StatelessWidget {
  final AnimatedMapController animatedMapController;
  final LatLng center;
  final List<AnimatedMarker> markers;
  final TextEditingController searchController;
  final Function() onSearch;
  final Function(MapCamera, bool) onPositionChanged;

  const FlutterMapWidget({
    super.key,
    required this.animatedMapController,
    required this.center,
    required this.markers,
    required this.searchController,
    required this.onSearch,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          FlutterMap(
            mapController: animatedMapController.mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 8,
              onPositionChanged: onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                maxNativeZoom: 18,
              ),
              AnimatedMarkerLayer(
                markers: markers,
              ),
            ],
          ),
          IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.0),
            ),
          ),
          SearchBarWidget(
            searchController: searchController,
            onSearch: onSearch,
          ),
        ],
      ),
    );
  }
}
