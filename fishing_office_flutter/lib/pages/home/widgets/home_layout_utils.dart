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

Rect homeDesignRectToStageRect({
  required Rect designRect,
  required Size stageSize,
  required Size designSize,
}) {
  final fitRect = homeContainRect(stageSize, designSize);
  final scale = fitRect.width / designSize.width;
  return Rect.fromLTWH(
    fitRect.left + designRect.left * scale,
    fitRect.top + designRect.top * scale,
    designRect.width * scale,
    designRect.height * scale,
  );
}
