import 'package:flutter/material.dart';

class DeskLayer extends StatelessWidget {
  const DeskLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox.expand(),
    );
  }
}
