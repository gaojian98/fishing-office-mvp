import 'package:flutter/material.dart';

import 'home_layout_utils.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  static const String assetPath = 'assets/images/Home.png';
  static const Size _homeImageSize = Size(1080, 1920);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final stageSize = Size(constraints.maxWidth, constraints.maxHeight);
          final rect = homeContainRect(stageSize, _homeImageSize);
          return ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width,
                  height: rect.height,
                  child: const Image(
                    image: AssetImage(assetPath),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ],
            ),
          );
        },
      );
}
