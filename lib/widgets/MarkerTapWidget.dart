import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_map/models/WeatherData.dart';

class MarkerTapWidget extends StatelessWidget {
  final WeatherData weatherData;

  const MarkerTapWidget({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    String image;
    if (weatherData.dayNight == 1) {
      image = "assets/icons/day.svg";
    } else {
      image = "assets/icons/night.svg";
    }
    return AlertDialog(
      title: Column(
        children: [
          Row(
            children: [
              Text(
                weatherData.city,
                style:
                    const TextStyle(fontFamily: 'Archivo', fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10,
              ),
              SvgPicture.asset(
                image,
                height: 25,
                width: 25,
              ),
              const Spacer(),
              SvgPicture.asset(
                "assets/icons/humidity.svg",
                height: 23,
                width: 24,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${weatherData.humidity}%",
                style: const TextStyle(
                    fontFamily: 'Archivo', fontSize: 15, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/temp_icon.svg",
                height: 25,
                width: 20,
              ),
              Text(
                weatherData.temperature,
                style: const TextStyle(
                    fontFamily: 'Archivo', fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/wind.svg",
                    height: 22,
                    width: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    weatherData.windSpeed,
                    style: const TextStyle(
                        fontFamily: 'Archivo', fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            weatherData.weatherImagePath,
            height: 100,
            width: 100,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            weatherData.weatherName,
            style: const TextStyle(fontFamily: 'Archivo', fontSize: 18, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
