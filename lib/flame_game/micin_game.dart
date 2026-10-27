import 'dart:async' show unawaited;
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color, Offset, Size;
import '../core/constants.dart';
import '../core/pixel_sprites.dart';
import '../engine/drawing/virtual_coordinate_adapter.dart';
import '../engine/game_engine.dart';
import '../models/level_visual_theme.dart';
import 'components/background_component.dart';
import 'components/level_geometry_component.dart';
import 'components/line_drawing_component.dart';
import 'components/particle_system_component.dart';
import 'components/silhouette_component.dart';

/// Flame game bridge wrapping the headless [GameEngine].
///
/// Responsibility split:
///  - [MicinGame] owns the Flame scene graph and drives the physics loop.
///  - [GameEngine] owns all physics simulation (unchanged from previous impl).
///  - Flutter overlays (HUD, Pause, Countdown) are registered via
///    [GameWidget.overlayBuilderMap] and shown/hidden through [overlays].
class MicinGame extends FlameGame with DragCallbacks {
  final GameEngine engine;
  final LevelVisualTheme visualTheme;

  // ── Screen-shake (trauma model) ───────────────────────────────────────────
  double _trauma = 0.0;
  double _traumaTime = 0.0;
  static const double _traumaDecay = 1.5; // trauma/second
  static const double _maxShakeRoll = 0.035; // radians

  // ── Parallax state ────────────────────────────────────────────────────────
  double _parallaxX = 0.0;
  double _parallaxY = 0.0;
  BackgroundFlameComponent? _backgroundComponent;

  // ── Viewport metrics (computed in onGameResize) ───────────────────────────
  double _scale = 1.0;

  // ── Overlay keys ──────────────────────────────────────────────────────────
  static const String kOverlayHud = 'hud';
  static const String kOverlayPause = 'pause';
  static const String kOverlayCountdown = 'countdown';

  MicinGame({required this.engine, required this.visualTheme});

  // ── Flame lifecycle ───────────────────────────────────────────────────────

  @override
  Color backgroundColor() => visualTheme.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.moveTo(Vector2(kVirtualWidth / 2, kVirtualHeight / 2));

    // Show countdown overlay — HUD is always visible
    overlays.add(kOverlayHud);
    overlays.add(kOverlayCountdown);

    // Asynchronously preload pixel art sprites
    unawaited(PixelSprites.loadAll());

    // Layer 0: Background (chromatic chalkboard + parallax grain + diegetic label)
    _backgroundComponent = BackgroundFlameComponent(
      backgroundColor: visualTheme.backgroundColor,
      canvasLabel: visualTheme.stageLabel,
      canvasLabelColor: visualTheme.canvasLabelColor,
      canvasLabelOpacity: visualTheme.canvasLabelOpacity,
      canvasLabelPositionVirtual: visualTheme.canvasLabelPosition,
    );
    await world.add(_backgroundComponent!);

    // Layer 1: Silhouette props (vector shadows + rigid colliders)
    if (visualTheme.silhouetteProps.isNotEmpty) {
      await world.add(SilhouetteFlameComponent(
        props: visualTheme.silhouetteProps,
      ));
    }

    // Layer 2: Level geometry (cups, emitters, filter zones)
    await world.add(LevelGeometryFlameComponent(
      levelConfig: engine.levelConfig,
      liveCupsGetter: () => engine.cups,
    ));

    // Layer 3: Particles (batch drawPoints — zero allocation)
    await world.add(ParticleSystemFlameComponent(
      particlesGetter: () => engine.particleController.pool.activeParticles,
      cupsGetter: () => engine.cups,
    ));

    // Layer 4: Player-drawn lines
    await world.add(LineDrawingFlameComponent(
      linesGetter: () => engine.lineController.lines,
    ));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final flutterSize = Size(size.x, size.y);
    _scale = VirtualCoordinateAdapter.computeScale(flutterSize);

    // Center camera on the 400x700 virtual canvas.
    camera.viewfinder.zoom = _scale;
    camera.viewfinder.position = Vector2(
      kVirtualWidth / 2,
      kVirtualHeight / 2,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Drive the headless physics engine.
    if (!engine.isPaused && !engine.isComplete) {
      engine.tickManual(Duration(microseconds: (dt * 1e6).round()));
    }

    // Decay screen-shake trauma.
    if (_trauma > 0.0) {
      _trauma = math.max(0.0, _trauma - _traumaDecay * dt);
      _traumaTime += dt * 28.0;
      final shake = _trauma * _trauma;
      camera.viewfinder.angle =
          _maxShakeRoll * shake * math.sin(_traumaTime * 1.1);
    } else if (camera.viewfinder.angle != 0.0) {
      camera.viewfinder.angle = 0.0;
    }

    // Drift parallax back to zero.
    _parallaxX *= 0.90;
    _parallaxY *= 0.90;
    if (_parallaxX.abs() < 0.01) _parallaxX = 0.0;
    if (_parallaxY.abs() < 0.01) _parallaxY = 0.0;
    _backgroundComponent?.setParallax(_parallaxX, _parallaxY);
  }

  // ── Touch input bridge ────────────────────────────────────────────────────

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (engine.isPaused) return;
    final vp = _toVirtual(event.canvasPosition);
    engine.lineController.onPanStart(vp);
    _updateParallax(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (engine.isPaused) return;
    final vp = _toVirtual(event.canvasStartPosition);
    engine.lineController.onPanUpdate(vp);
    _updateParallax(event.canvasStartPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    engine.lineController.onPanEnd();
    _parallaxX = 0.0;
    _parallaxY = 0.0;
    _backgroundComponent?.setParallax(0.0, 0.0);
  }

  // ── Public API for HUD/overlays ───────────────────────────────────────────

  /// Adds trauma (0..1). Multiple hits accumulate.
  void addTrauma(double amount) {
    _trauma = (_trauma + amount).clamp(0.0, 1.0);
  }

  /// Called by HUD when countdown finishes.
  void onCountdownComplete() {
    engine.isSpawningActive = true;
    overlays.remove(kOverlayCountdown);
  }

  /// Called by HUD pause button.
  void pauseGame() {
    engine.pause();
    overlays.add(kOverlayPause);
  }

  /// Called by Pause overlay resume button.
  void resumeGame() {
    overlays.remove(kOverlayPause);
    engine.resume();
  }

  /// Called by reset button.
  void resetGame() {
    engine.reset();
    engine.isSpawningActive = false;
    overlays.remove(kOverlayPause);
    overlays.remove(kOverlayCountdown);
    overlays.add(kOverlayCountdown);
    camera.viewfinder.angle = 0.0;
    _trauma = 0.0;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Offset _toVirtual(Vector2 canvasPos) {
    final flutterSize = Size(size.x, size.y);
    return VirtualCoordinateAdapter.screenToVirtual(
      Offset(canvasPos.x, canvasPos.y),
      flutterSize,
    );
  }

  void _updateParallax(Vector2 canvasPos) {
    final cx = size.x / 2.0;
    final cy = size.y / 2.0;
    _parallaxX = ((canvasPos.x - cx) * 0.018).clamp(-12.0, 12.0);
    _parallaxY = ((canvasPos.y - cy) * 0.018).clamp(-12.0, 12.0);
    _backgroundComponent?.setParallax(_parallaxX, _parallaxY);
  }
}
