import 'package:flutter/foundation.dart';

class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  double musicVolume = 0.7;
  double ambientVolume = 0.6;
  double sfxVolume = 0.8;
  double uiVolume = 0.8;
  double voiceVolume = 1.0;
  bool muted = false;

  void play(String assetId, {String category = 'sfx', double? volume}) {
    if (kDebugMode) {
      debugPrint('AudioManager.play($assetId, category=$category, volume=$volume)');
    }
  }

  void stop(String assetId) {
    if (kDebugMode) debugPrint('AudioManager.stop($assetId)');
  }

  void fade(String assetId, {Duration duration = const Duration(milliseconds: 800)}) {
    if (kDebugMode) debugPrint('AudioManager.fade($assetId, duration=$duration)');
  }

  void setMuted(bool value) {
    muted = value;
  }
}
