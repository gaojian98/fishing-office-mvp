import 'package:flutter/material.dart';

import 'json_element_layer.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const JsonElementLayer(
      layerId: 'bottom_buttons',
      renderButtons: true,
    );
  }
}
