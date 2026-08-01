import 'dart:ui';

Rect homeContainRect(Size outer, Size inner) {
  final scale = outer.width / inner.width < outer.height / inner.height
      ? outer.width / inner.width
      : outer.height / inner.height;
  final width = inner.width * scale;
  final height = inner.height * scale;
  final left = (outer.width - width) / 2;
  final top = (outer.height - height) / 2;
  return Rect.fromLTWH(left, top, width, height);
}
