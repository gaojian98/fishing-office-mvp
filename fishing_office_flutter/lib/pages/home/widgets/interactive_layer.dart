import 'package:flutter/material.dart';

import 'json_element_layer.dart';

class InteractiveLayer extends StatelessWidget {
  const InteractiveLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const JsonElementLayer(
      layerId: 'interactive_objects',
      renderButtons: true,
    );
  }
}
