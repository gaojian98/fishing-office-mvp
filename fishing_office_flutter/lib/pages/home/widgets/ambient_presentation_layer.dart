import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_color.dart';
import '../../../core/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/runtime/app_runtime.dart';

class AmbientPresentationLayer extends ConsumerStatefulWidget {
  const AmbientPresentationLayer({
    super.key,
    required this.runtime,
    required this.uiRuntime,
  });

  final AppRuntime runtime;
  final UiRuntimeSnapshot uiRuntime;

  @override
  ConsumerState<AmbientPresentationLayer> createState() =>
      _AmbientPresentationLayerState();
}

class _AmbientPresentationLayerState
    extends ConsumerState<AmbientPresentationLayer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion;
  bool _appVisible = true;
  String _lastAmbientCue = '';
  String _lastFishingCue = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AmbientPresentationLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAmbientAudio());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    if (!_appVisible) {
      ref.read(audioManagerProvider).fade(
            'ambient_office_sea',
            duration: const Duration(milliseconds: 500),
          );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncAmbientAudio());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsManagerProvider);
    final state = AmbientEnvironmentState.fromRuntime(
      runtime: widget.runtime,
      uiRuntime: widget.uiRuntime,
      quality: settings.valueOf('quality'),
      musicEnabled: settings.isEnabled('music'),
      soundEnabled: settings.isEnabled('sound'),
    );
    if (state.lowQuality && _motion.isAnimating) {
      _motion.stop();
    } else if (!state.lowQuality && !_motion.isAnimating) {
      _motion.repeat(reverse: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAmbientAudio());

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _LightAndWeatherOverlay(state: state),
          if (!state.lowQuality) _SeaMotion(motion: _motion, state: state),
          if (state.showClouds) _CloudDrift(motion: _motion),
          if (state.showBirds) _BirdDrift(motion: _motion),
          if (state.hasFestival) _FestivalGlow(motion: _motion),
          _ResidentHint(state: state),
          if (state.isFishingWaiting) _WaitingAtmosphere(state: state),
          if (state.isFishingWaiting || state.isFishHooked)
            _FloatPulse(motion: _motion, state: state),
        ],
      ),
    );
  }

  void _syncAmbientAudio() {
    if (!mounted || !_appVisible) return;
    final settings = ref.read(settingsManagerProvider);
    final audio = ref.read(audioManagerProvider);
    final state = AmbientEnvironmentState.fromRuntime(
      runtime: widget.runtime,
      uiRuntime: widget.uiRuntime,
      quality: settings.valueOf('quality'),
      musicEnabled: settings.isEnabled('music'),
      soundEnabled: settings.isEnabled('sound'),
    );
    if (!state.musicEnabled) {
      audio.fade('ambient_office_sea');
      _lastAmbientCue = '';
    } else {
      final cue = state.audioCue;
      if (cue != _lastAmbientCue) {
        audio.playAmbient(cue, volume: state.lowQuality ? 0.25 : 0.45);
        _lastAmbientCue = cue;
      }
    }
    if (!state.soundEnabled) return;
    final fishingCue = state.fishingAudioCue;
    if (fishingCue.isNotEmpty && fishingCue != _lastFishingCue) {
      audio.play(fishingCue, category: 'sfx', volume: 0.45);
      _lastFishingCue = fishingCue;
    }
  }
}

class AmbientEnvironmentState {
  const AmbientEnvironmentState({
    required this.timeOfDay,
    required this.weatherType,
    required this.weatherLabel,
    required this.festivalLabel,
    required this.festivalTags,
    required this.windLevel,
    required this.residentActivity,
    required this.fishingState,
    required this.waitingHints,
    required this.lowQuality,
    required this.musicEnabled,
    required this.soundEnabled,
  });

  factory AmbientEnvironmentState.fromRuntime({
    required AppRuntime runtime,
    required UiRuntimeSnapshot uiRuntime,
    required String quality,
    required bool musicEnabled,
    required bool soundEnabled,
  }) {
    final hints = <String>[
      ...runtime.waitingEvents,
      if (uiRuntime.residentDialogue.isNotEmpty) uiRuntime.residentDialogue,
      if (uiRuntime.dailySummary.isNotEmpty) uiRuntime.dailySummary,
    ];
    return AmbientEnvironmentState(
      timeOfDay: uiRuntime.timeOfDay,
      weatherType: uiRuntime.weatherType,
      weatherLabel: uiRuntime.weatherLabel,
      festivalLabel: uiRuntime.festivalLabel,
      festivalTags: uiRuntime.festivalTags,
      windLevel: uiRuntime.windLevel,
      residentActivity: uiRuntime.residentActivity,
      fishingState: runtime.fishing.state,
      waitingHints: _dedupe(hints).take(4).toList(growable: false),
      lowQuality: quality == 'low',
      musicEnabled: musicEnabled,
      soundEnabled: soundEnabled,
    );
  }

  final String timeOfDay;
  final String weatherType;
  final String weatherLabel;
  final String festivalLabel;
  final List<String> festivalTags;
  final int windLevel;
  final String residentActivity;
  final String fishingState;
  final List<String> waitingHints;
  final bool lowQuality;
  final bool musicEnabled;
  final bool soundEnabled;

  bool get hasFestival => festivalTags.isNotEmpty || festivalLabel != '今日无节日';
  bool get isFishingWaiting => fishingState == 'waiting';
  bool get isFishHooked => fishingState == 'fishHooked';
  bool get isRainy =>
      weatherType.contains('rain') ||
      weatherType.contains('storm') ||
      weatherType.contains('typhoon') ||
      weatherLabel.contains('雨') ||
      weatherLabel.contains('暴');
  bool get isMisty => weatherType.contains('fog') || weatherLabel.contains('雾');
  bool get isNight => timeOfDay == 'night';
  bool get isDusk => timeOfDay == 'dusk';
  bool get showBirds => !lowQuality && !isRainy && !isNight;
  bool get showClouds => !lowQuality && !weatherType.contains('thunder');

  Color get lightOverlay {
    if (isNight) return const Color(0xAA05101B);
    if (isDusk) return const Color(0x26F2A64C);
    if (timeOfDay == 'morning') return const Color(0x18F2C94C);
    return Colors.transparent;
  }

  Color get weatherOverlay {
    if (isRainy) return const Color(0x220B3A5D);
    if (isMisty) return const Color(0x28F4F1E8);
    return Colors.transparent;
  }

  double get seaMotionOffset {
    final base = windLevel.clamp(1, 8).toDouble();
    return lowQuality ? 0 : 2 + base;
  }

  String get audioCue {
    if (hasFestival) return 'ambient_festival_soft';
    if (weatherType.contains('thunder') || weatherLabel.contains('雷')) {
      return 'ambient_rain_thunder_safe';
    }
    if (isRainy) return 'ambient_rain_window';
    if (windLevel >= 5) return 'ambient_sea_wind';
    return 'ambient_office_sea';
  }

  String get fishingAudioCue {
    if (isFishHooked) return 'sfx_float_dip_reserved';
    if (isFishingWaiting && waitingHints.isNotEmpty) {
      return 'sfx_waiting_water_reserved';
    }
    return '';
  }

  static List<String> _dedupe(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final text = value.trim();
      if (text.isEmpty || seen.contains(text)) continue;
      seen.add(text);
      result.add(text);
    }
    return result;
  }
}

class _LightAndWeatherOverlay extends StatelessWidget {
  const _LightAndWeatherOverlay({required this.state});

  final AmbientEnvironmentState state;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          color: state.lightOverlay,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          color: state.weatherOverlay,
        ),
      ],
    );
  }
}

class _SeaMotion extends StatelessWidget {
  const _SeaMotion({required this.motion, required this.state});

  final Animation<double> motion;
  final AmbientEnvironmentState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        final offset = (motion.value - 0.5) * state.seaMotionOffset;
        return Positioned(
          left: 404,
          top: 635 + offset,
          width: 656,
          height: 690,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.00),
                  AppColor.secondary.withValues(alpha: 0.035),
                  Colors.white.withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CloudDrift extends StatelessWidget {
  const _CloudDrift({required this.motion});

  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        final dx = (motion.value - 0.5) * 24;
        return Positioned(
          left: 642 + dx,
          top: 440,
          width: 250,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.00),
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BirdDrift extends StatelessWidget {
  const _BirdDrift({required this.motion});

  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        final dx = (motion.value - 0.5) * 48;
        final opacity = 0.26 + (motion.value * 0.12);
        return Positioned(
          left: 625 + dx,
          top: 390,
          child: Text(
            '⌁  ⌁',
            style: TextStyle(
              color: Colors.white.withValues(alpha: opacity),
              fontSize: 22,
              height: 1,
            ),
          ),
        );
      },
    );
  }
}

class _FestivalGlow extends StatelessWidget {
  const _FestivalGlow({required this.motion});

  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        return Positioned(
          left: 62,
          top: 84,
          width: 330,
          height: 96,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColor.accent.withValues(
                    alpha: 0.10 + motion.value * 0.07,
                  ),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResidentHint extends StatelessWidget {
  const _ResidentHint({required this.state});

  final AmbientEnvironmentState state;

  @override
  Widget build(BuildContext context) {
    final text = state.residentActivity.trim();
    if (text.isEmpty) return const SizedBox.shrink();
    return Positioned(
      left: 420,
      top: 1125,
      width: 420,
      child: _AmbientPill(text: text, opacity: 0.24),
    );
  }
}

class _WaitingAtmosphere extends StatelessWidget {
  const _WaitingAtmosphere({required this.state});

  final AmbientEnvironmentState state;

  @override
  Widget build(BuildContext context) {
    if (state.waitingHints.isEmpty) return const SizedBox.shrink();
    return Positioned(
      left: 520,
      top: 760,
      width: 455,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AmbientPill(text: state.weatherLabel, opacity: 0.30),
          const SizedBox(height: 10),
          for (final hint in state.waitingHints.take(3)) ...[
            _AmbientPill(text: hint, opacity: 0.34),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FloatPulse extends StatelessWidget {
  const _FloatPulse({required this.motion, required this.state});

  final Animation<double> motion;
  final AmbientEnvironmentState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        final scale = state.isFishHooked ? 1.14 : 1 + (motion.value * 0.08);
        final opacity = state.isFishHooked ? 0.45 : 0.18 + motion.value * 0.08;
        return Positioned(
          left: 748,
          top: 852 + ((motion.value - 0.5) * 8),
          width: 44,
          height: 72,
          child: Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.accent.withValues(alpha: opacity),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AmbientPill extends StatelessWidget {
  const _AmbientPill({
    required this.text,
    required this.opacity,
  });

  final String text;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF06233A).withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColor.accent.withValues(alpha: opacity * 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.small.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            height: 1.25,
          ),
        ),
      ),
    );
  }
}
