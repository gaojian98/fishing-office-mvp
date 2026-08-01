import 'package:flutter/foundation.dart';

class HotspotDebugState {
  HotspotDebugState._();

  static final ValueNotifier<String> lastTap =
      ValueNotifier<String>('Last tap: none');
}
