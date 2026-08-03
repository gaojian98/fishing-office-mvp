import 'package:flutter/foundation.dart';

class RuntimeDebug {
  RuntimeDebug._();

  static bool enabled = false;

  static void log(String message, {int? wrapWidth}) {
    if (!enabled || !kDebugMode) return;
    debugPrint(message, wrapWidth: wrapWidth);
  }
}
