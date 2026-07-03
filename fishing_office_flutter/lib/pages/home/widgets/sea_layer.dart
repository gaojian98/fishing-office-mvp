import 'package:flutter/material.dart';

import 'json_element_layer.dart';

class SeaLayer extends StatelessWidget {
  const SeaLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const JsonElementLayer(
      layerId: 'animated_sea',
      renderButtons: false,
      renderAnimatedObjects: true,
    );
  }
}
