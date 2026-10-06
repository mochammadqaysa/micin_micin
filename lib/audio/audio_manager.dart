import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, HSLColor;
import 'audio_bus.dart';

/// Sound effect types available in Micin Micin.
enum SoundType {
  buttonClick,
  levelComplete,
  particlePing,
  filterPass,
  gravityInvert,
  levelReset,
}

/// Central audio manager coordinating background music loops, vertical stems,
/// and organic sound effects through a hierarchical bus mixer.
class AudioManager {
  // Bus Mixer Hierarchy
  late final AudioBus masterBus;
  late final AudioBus musicBus;
  late final AudioBus ambienceBus;
  late final AudioBus sfxBus;
  late final AudioBus interactionBus;

  // Audio Players
  final AudioPlayer _bgmPlayer;
  final AudioPlayer _chimesPlayer;
  final AudioPlayer _sfxPlayer;
  final List<AudioPlayer> _interactionPlayers;
  int _nextInteractionIndex = 0;

  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  bool _isInitialized = false;

  // Adaptive Layer 2 Automation
  double _currentProgressRatio = 0.0;
  double _layer2GainDb = -40.0;

  // Debounce Clocks
  DateTime _lastParticleSoundTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastFilterSoundTime = DateTime.fromMillisecondsSinceEpoch(0);

  // Sidechain Ducking Timer
  Timer? _duckingTimer;

  // Pentatonic scale pitch factors: C (1.0), D (1.125), E (1.25), G (1.5), A (1.667), C' (2.0)
  static const List<double> _pentatonicIntervals = [1.0, 1.125, 1.25, 1.5, 1.667, 2.0];

  AudioManager({
    AudioPlayer? bgmPlayer,
    AudioPlayer? chimesPlayer,
    AudioPlayer? sfxPlayer,
    List<AudioPlayer>? interactionPlayers,
  })  : _bgmPlayer = bgmPlayer ?? AudioPlayer(),
        _chimesPlayer = chimesPlayer ?? AudioPlayer(),
        _sfxPlayer = sfxPlayer ?? AudioPlayer(),
        _interactionPlayers = interactionPlayers ??
            List.generate(4, (_) => AudioPlayer()) {
    _initBuses();
  }

  void _initBuses() {
    masterBus = AudioBus(
      type: AudioBusType.master,
      name: 'Master',
      gainDb: -3.0, // Headroom target below 0 dBFS (~ -16 LUFS)
    );

    musicBus = AudioBus(
      type: AudioBusType.music,
      name: 'Music',
      parent: masterBus,
      gainDb: -4.0,
    );

    ambienceBus = AudioBus(
      type: AudioBusType.ambience,
      name: 'Ambience',
      parent: masterBus,
      gainDb: -6.0,
    );

    sfxBus = AudioBus(
      type: AudioBusType.sfx,
      name: 'SFX',
      parent: masterBus,
      gainDb: -2.0,
    );

    interactionBus = AudioBus(
      type: AudioBusType.interaction,
      name: 'Interaction',
      parent: masterBus,
      gainDb: -4.0,
    );
  }

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isInitialized => _isInitialized;
  double get currentProgressRatio => _currentProgressRatio;

  /// Preloads audio resources and sets up loop release modes.
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _chimesPlayer.setReleaseMode(ReleaseMode.loop);
      await _applyBusVolumes();
      _isInitialized = true;
    } catch (e) {
      debugPrint('AudioManager init warning: $e');
    }
  }

  /// Recalculates and pushes effective linear volumes down to audio players.
  Future<void> _applyBusVolumes() async {
    try {
      if (_isMusicEnabled) {
        await _bgmPlayer.setVolume(musicBus.effectiveLinearVolume);
        final layer2Vol = AudioBus.dbToLinear(musicBus.effectiveGainDb + _layer2GainDb);
        await _chimesPlayer.setVolume(layer2Vol);
      } else {
        await _bgmPlayer.setVolume(0.0);
        await _chimesPlayer.setVolume(0.0);
      }

      final sfxVol = _isSoundEnabled ? sfxBus.effectiveLinearVolume : 0.0;
      await _sfxPlayer.setVolume(sfxVol);

      final interactVol = _isSoundEnabled ? interactionBus.effectiveLinearVolume : 0.0;
      for (final player in _interactionPlayers) {
        await player.setVolume(interactVol);
      }
    } catch (e) {
      debugPrint('AudioManager _applyBusVolumes warning: $e');
    }
  }

  /// Starts background music: Layer 1 (Base Ambience) + Layer 2 (Adaptive Chimes).
  Future<void> playBgm() async {
    if (!_isMusicEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      await _applyBusVolumes();

      // Start Layer 2 stem if available
      try {
        await _chimesPlayer.play(AssetSource('audio/chimes_loop.wav'));
        await _chimesPlayer.setVolume(AudioBus.dbToLinear(musicBus.effectiveGainDb + _layer2GainDb));
      } catch (_) {
        // Graceful fallback if chimes stem is not present
      }
    } catch (e) {
      debugPrint('AudioManager playBgm warning: $e');
    }
  }

  /// Pauses or stops all background music stems.
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      await _chimesPlayer.stop();
    } catch (e) {
      debugPrint('AudioManager stopBgm warning: $e');
    }
  }

  /// Updates target progress ratio [0.0..1.0] and adapts Layer 2 chimes volume.
  Future<void> updateProgress(double completionRatio) async {
    _currentProgressRatio = completionRatio.clamp(0.0, 1.0);
    // Smooth logarithmic fade-in curve: -40 dB (silent) up to 0 dB relative to MusicBus
    if (_currentProgressRatio <= 0.05) {
      _layer2GainDb = -40.0;
    } else {
      _layer2GainDb = -40.0 + (40.0 * math.pow(_currentProgressRatio, 0.7));
    }

    if (_isMusicEnabled) {
      final layer2Linear = AudioBus.dbToLinear(musicBus.effectiveGainDb + _layer2GainDb);
      try {
        await _chimesPlayer.setVolume(layer2Linear);
      } catch (e) {
        debugPrint('AudioManager updateProgress warning: $e');
      }
    }
  }

  /// Plays a short sound effect with automatic sidechain ducking on level complete.
  Future<void> playSfx(SoundType type) async {
    if (!_isSoundEnabled) return;
    try {
      final fileName = switch (type) {
        SoundType.buttonClick => 'audio/click.wav',
        SoundType.levelComplete => 'audio/ok.mp3',
        SoundType.particlePing => 'audio/particle_ping.wav',
        SoundType.filterPass => 'audio/filter_pass.wav',
        SoundType.gravityInvert => 'audio/gravity_invert.wav',
        SoundType.levelReset => 'audio/level_reset.wav',
      };

      if (type == SoundType.levelComplete) {
        // Trigger smooth sidechain ducking on music bus (-10 dB)
        duckMusic(active: true, duckDb: -10.0, attack: const Duration(milliseconds: 15));
        _duckingTimer?.cancel();
        _duckingTimer = Timer(const Duration(milliseconds: 1400), () {
          duckMusic(active: false, release: const Duration(milliseconds: 400));
        });
      }

      await _sfxPlayer.setVolume(sfxBus.effectiveLinearVolume);
      await _sfxPlayer.play(AssetSource(fileName));
    } catch (e) {
      debugPrint('AudioManager playSfx warning: $e');
    }
  }

  /// Plays an organic, pentatonic pitch-scaled chime when a particle is captured.
  ///
  /// [fillPercentage] ranges from 0.0 to 1.0, ascending the pentatonic scale C-D-E-G-A.
  Future<void> playParticleCapture({required double fillPercentage}) async {
    if (!_isSoundEnabled) return;

    // Debounce micro-interval (45ms) to prevent robotic stutter during heavy showers
    final now = DateTime.now();
    if (now.difference(_lastParticleSoundTime).inMilliseconds < 45) {
      return;
    }
    _lastParticleSoundTime = now;

    try {
      final position = (fillPercentage.clamp(0.0, 1.0)) * (_pentatonicIntervals.length - 1);
      final index = position.floor();
      final fraction = position - index;
      final baseInterval = index >= _pentatonicIntervals.length - 1
          ? _pentatonicIntervals.last
          : _pentatonicIntervals[index] * (1.0 - fraction) +
              _pentatonicIntervals[index + 1] * fraction;

      // Pitch micro-jitter (+/- 3% randomization for organic analog feel)
      final jitter = 1.0 + (math.Random().nextDouble() - 0.5) * 0.06;
      final targetPitch = (baseInterval * jitter).clamp(0.5, 2.5);

      final player = _interactionPlayers[_nextInteractionIndex];
      _nextInteractionIndex = (_nextInteractionIndex + 1) % _interactionPlayers.length;

      await player.setPlaybackRate(targetPitch);
      await player.setVolume(interactionBus.effectiveLinearVolume);
      await player.play(AssetSource('audio/particle_ping.wav'));
    } catch (e) {
      debugPrint('AudioManager playParticleCapture warning: $e');
    }
  }

  /// Plays a resonant shimmer when a particle traverses a Color Filter Gate.
  Future<void> playFilterResonance({required Color filterColor}) async {
    if (!_isSoundEnabled) return;

    final now = DateTime.now();
    if (now.difference(_lastFilterSoundTime).inMilliseconds < 60) {
      return;
    }
    _lastFilterSoundTime = now;

    try {
      // Map color hues to harmonious pitch intervals
      final hsl = HSLColor.fromColor(filterColor);
      final pitchFactor = (0.9 + (hsl.hue / 360.0) * 0.5).clamp(0.8, 1.6);

      final player = _interactionPlayers[_nextInteractionIndex];
      _nextInteractionIndex = (_nextInteractionIndex + 1) % _interactionPlayers.length;

      await player.setPlaybackRate(pitchFactor);
      await player.setVolume(interactionBus.effectiveLinearVolume * 0.85);
      await player.play(AssetSource('audio/filter_pass.wav'));
    } catch (e) {
      debugPrint('AudioManager playFilterResonance warning: $e');
    }
  }

  /// Applies smooth sidechain ducking attenuation on music and ambience buses.
  void duckMusic({
    required bool active,
    double duckDb = -10.0,
    Duration attack = const Duration(milliseconds: 15),
    Duration release = const Duration(milliseconds: 400),
  }) {
    final targetDb = active ? duckDb.clamp(-80.0, 0.0) : 0.0;
    musicBus.duckingOffsetDb = targetDb;
    ambienceBus.duckingOffsetDb = targetDb;
    _applyBusVolumes();
  }

  /// Toggles music playback state on or off.
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    musicBus.isMuted = !_isMusicEnabled;
    if (_isMusicEnabled) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  /// Toggles sound effects on or off across SFX and Interaction buses.
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    sfxBus.isMuted = !_isSoundEnabled;
    interactionBus.isMuted = !_isSoundEnabled;
    _applyBusVolumes();
  }

  /// Disposes all audio players and releases timers cleanly.
  void dispose() {
    _duckingTimer?.cancel();
    _bgmPlayer.dispose();
    _chimesPlayer.dispose();
    _sfxPlayer.dispose();
    for (final player in _interactionPlayers) {
      player.dispose();
    }
  }
}
