import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  static const String assetPath = 'assets/images/Home.png';

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Image(
          image: AssetImage(assetPath),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
