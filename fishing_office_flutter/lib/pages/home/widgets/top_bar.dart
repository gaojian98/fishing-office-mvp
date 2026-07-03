import 'package:flutter/material.dart';

import 'json_element_layer.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const JsonElementLayer(
      layerId: 'top_buttons',
      renderButtons: true,
    );
  }
}
