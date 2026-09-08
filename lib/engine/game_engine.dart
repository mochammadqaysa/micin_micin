import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/level_config.dart';
import 'collision/cup_hitbox.dart';
import 'color_filter/color_filter_zone.dart';
import 'drawing/line_controller.dart';
import 'particle/particle_controller.dart';
import 'particle/particle_emitter.dart';

/// Central game engine coordinating particle physics, line drawing,
/// cup goals, and the active frame loop (Ticker).
class GameEngine with ChangeNotifier {
  final LevelConfig levelConfig;
  final ParticleController particleController;
  final LineController lineController;
  final List<CupHitbox> cups;
  final List<ColorFilterZone> filters;

  Ticker? _ticker;
  bool isPaused = false;
  bool _isComplete = false;

  /// Optional event callbacks for presentation layer audio triggers
  void Function(CupHitbox cup, dynamic particle)? onParticleCaptured;
  void Function(ColorFilterZone filter, dynamic particle)? onFilterPassed;

  GameEngine({
    required this.levelConfig,
    ParticleController? particleController,
    LineController? lineController,
    List<CupHitbox>? cups,
    List<ColorFilterZone>? filters,
    this.onParticleCaptured,
    this.onFilterPassed,
  })  : particleController = particleController ??
            ParticleController(
              gravity: levelConfig.gravity,
              emitters: levelConfig.emitters
                  .map(ParticleEmitter.fromConfig)
                  .toList(),
            ),
        lineController = lineController ?? LineController(),
        cups = cups ??
            levelConfig.cups.map(CupHitbox.fromConfig).toList(),
        filters = filters ??
            levelConfig.filters.map(ColorFilterZone.fromConfig).toList();

  /// Starts the game loop using Flutter's [TickerProvider] (CON-001).
  void start(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick)..start();
  }

  /// Internal frame tick handler invoked on every screen refresh.
  void _onTick(Duration elapsed) {
    if (isPaused) return;

    particleController.update(
      lines: lineController.allSegments,
      cups: cups,
      filters: filters,
      canvasHeight: levelConfig.canvasHeight,
      onParticleCaptured: onParticleCaptured != null
          ? (cup, p) => onParticleCaptured!(cup, p)
          : null,
      onFilterPassed: onFilterPassed != null
          ? (filter, p) => onFilterPassed!(filter, p)
          : null,
    );

    // One-time boolean guard to trigger level completion (CON-005, Q3)
    if (!_isComplete && isLevelComplete) {
      _isComplete = true;
      notifyListeners();
    }

    notifyListeners();
  }

  /// Exposes a manual tick interface for deterministic unit and headless tests.
  void tickManual(Duration elapsed) {
    _onTick(elapsed);
  }

  /// Determines whether the current level objectives have been satisfied (REQ-008, AC-007).
  bool get isLevelComplete =>
      (cups.isNotEmpty && cups.every((c) => c.remaining == 0)) ||
      (particleController.capturedCount >= levelConfig.totalSugar &&
          particleController.emitters.every((e) => e.isExhausted));

  /// Status of the completion flag.
  bool get isComplete => _isComplete;

  /// Total target amount required across all target cups in the stage.
  int get totalTarget =>
      cups.fold<int>(0, (sum, cup) => sum + cup.targetAmount);

  /// Total particles successfully captured across all target cups.
  int get totalCaptured =>
      cups.fold<int>(0, (sum, cup) => sum + cup.capturedCount);

  /// Pauses physics updates and animations.
  void pause() {
    isPaused = true;
    notifyListeners();
  }

  /// Resumes physics updates and animations.
  void resume() {
    isPaused = false;
    notifyListeners();
  }

  /// Performs a TOTAL level reset: clears all drawn lines, resets particle pool,
  /// resets all emitters and cups to zero (REQ-012, Q2).
  void reset() {
    _isComplete = false;
    lineController.clearAll();
    particleController.resetAll();
    for (final cup in cups) {
      cup.reset();
    }
    notifyListeners();
  }

  /// Inverts the vertical gravity vector (REQ-008).
  void toggleGravity() {
    particleController.gravity = -particleController.gravity;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}
