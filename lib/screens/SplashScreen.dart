import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  final bool isIconCentered;

  const SplashScreen({
    super.key,
    required this.isIconCentered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/splash_icon.svg',
              width: 120,
              height: 120,
            ),
            AnimatedAlign(
              alignment: isIconCentered
                  ? Alignment.center
                  : const Alignment(0.2, 0.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: SvgPicture.asset(
                'assets/icons/splash_icon_2.svg',
                width: 90,
                height: 90,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          "Weather Map",
          style: TextStyle(
            fontFamily: 'Archivo',
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ],
    );
  }
}
