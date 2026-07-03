import 'package:flutter/widgets.dart';

class ResponsiveManager {
  const ResponsiveManager({
    required this.designSize,
    required this.mediaSize,
    required this.textScaler,
    required this.orientation,
    required this.safeArea,
  });

  final Size designSize;
  final Size mediaSize;
  final TextScaler textScaler;
  final Orientation orientation;
  final EdgeInsets safeArea;

  factory ResponsiveManager.fromContext(BuildContext context, {Size? designSize}) {
    final media = MediaQuery.of(context);
    return ResponsiveManager(
      designSize: designSize ?? const Size(390, 844),
      mediaSize: media.size,
      textScaler: media.textScaler,
      orientation: media.orientation,
      safeArea: media.padding,
    );
  }

  double get textScaleFactor => textScaler.scale(1);

  double get scaleWidth => mediaSize.width / designSize.width;
  double get scaleHeight => mediaSize.height / designSize.height;
  double get scale => scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

  double px(double value) => value * scale;

  EdgeInsets safeInsets({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      left + safeArea.left,
      top + safeArea.top,
      right + safeArea.right,
      bottom + safeArea.bottom,
    );
  }

  bool get isPortrait => orientation == Orientation.portrait;
}
