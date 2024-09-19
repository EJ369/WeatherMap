import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_map/models/WeatherData.dart';

class AnimatedMarkerWidget extends StatelessWidget {
  final WeatherData weatherData;
  final VoidCallback onTap;
  final double size;

  const AnimatedMarkerWidget({
    super.key,
    required this.weatherData,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxHeight: size + 30,
      maxWidth: size + 30,
      minWidth: size,
      child: IntrinsicHeight(
        child: Container(
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      weatherData.city,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Archivo',
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Text(
                    weatherData.temperature,
                    style: const TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SvgPicture.asset(
                    weatherData.weatherImagePath,
                    height: 35,
                    width: 35,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weatherData.weatherName,
                    style: const TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
