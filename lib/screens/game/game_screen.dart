import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../data/level_repository.dart';
import '../../engine/drawing/virtual_coordinate_adapter.dart';
import '../../engine/game_engine.dart';
import '../../models/level_config.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../../widgets/level_complete_dialog.dart';
import '../../widgets/pause_overlay.dart';
import 'game_hud.dart';
import 'painters/background_painter.dart';
import 'painters/level_painter.dart';
import 'painters/line_painter.dart';
import 'painters/particle_painter.dart';

/// Interactive game screen hosting the physical canvas, rendering pipeline,
/// gesture recognition, and HUD overlay.
class GameScreen extends ConsumerStatefulWidget {
  final int levelId;
  final LevelConfig? levelConfig;

  const GameScreen({
    super.key,
    required this.levelId,
    this.levelConfig,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  GameEngine? _gameEngine;
  bool _isLoading = true;
  bool _hasHandledCompletion = false;
  String? _errorMessage;
  Offset _touchParallax = Offset.zero;
  late final AudioManager _audioManager;

  @override
  void initState() {
    super.initState();
    _audioManager = ref.read(audioManagerProvider);
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    try {
      LevelConfig? config = widget.levelConfig;

      // Null safety fallback: load from asset repository if not provided in extra
      if (config == null) {
        const repo = LevelRepository();
        config = await repo.loadLevel(widget.levelId);
      }

      if (!mounted) return;

      final engine = GameEngine(
        levelConfig: config,
        onParticleCaptured: (cup, particle) {
          if (!mounted) return;
          final target = cup.targetAmount;
          final fillRatio = target > 0 ? (cup.capturedCount / target).clamp(0.0, 1.0) : 0.0;
          _audioManager.playParticleCapture(fillPercentage: fillRatio);
        },
        onFilterPassed: (filter, particle) {
          if (!mounted) return;
          _audioManager.playFilterResonance(filterColor: filter.targetColor);
        },
      );
      engine.start(this);
      engine.addListener(_onEngineUpdate);

      setState(() {
        _gameEngine = engine;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load level: $e';
        _isLoading = false;
      });
    }
  }

  void _onEngineUpdate() {
    if (!mounted) return;
    if (_gameEngine != null) {
      final totalTarget = _gameEngine!.totalTarget;
      final totalCaptured = _gameEngine!.totalCaptured;
      final progressRatio = totalTarget > 0 ? (totalCaptured / totalTarget).clamp(0.0, 1.0) : 0.0;
      _audioManager.updateProgress(progressRatio);
    }
    if (_gameEngine?.isComplete == true && !_hasHandledCompletion) {
      _hasHandledCompletion = true;
      _audioManager.playSfx(SoundType.levelComplete);
      ref.read(playerProgressProvider.notifier).markCompleted(widget.levelId);
      if (widget.levelId < kTotalLevels) {
        ref.read(playerProgressProvider.notifier).unlockLevel(widget.levelId + 1);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _gameEngine?.removeListener(_onEngineUpdate);
    _gameEngine?.dispose();
    _audioManager.duckMusic(active: false);
    LevelPainter.clearCache();
    ParticlePainter.clearBuffers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF101012),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD54F)),
        ),
      );
    }

    if (_errorMessage != null || _gameEngine == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF101012),
        body: Center(
          child: Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final engine = _gameEngine!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        engine.pause();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101012),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
            final scale = VirtualCoordinateAdapter.computeScale(viewportSize);
            final offset = VirtualCoordinateAdapter.computeOffset(viewportSize, scale);

            return Stack(
              children: [
                // 1. Static sand textured background covering entire device screen with touch parallax
                CustomPaint(
                  painter: BackgroundPainter(parallaxOffset: _touchParallax),
                  size: Size.infinite,
                ),

                // 2. Transformed virtual game world (400x700)
                Positioned.fill(
                  child: Transform.translate(
                    offset: offset,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: kVirtualWidth,
                        height: kVirtualHeight,
                        child: ClipRect(
                          child: Stack(
                            children: [
                              // Level geometry (cups, emitters, filter zones)
                              RepaintBoundary(
                                child: CustomPaint(
                                  painter: LevelPainter(
                                    levelConfig: engine.levelConfig,
                                    liveCups: engine.cups,
                                  ),
                                  size: const Size(kVirtualWidth, kVirtualHeight),
                                ),
                              ),

                              // Particle layer (batch rendered via Canvas.drawPoints)
                              RepaintBoundary(
                                child: CustomPaint(
                                  painter: ParticlePainter(
                                    engine.particleController.pool.activeParticles,
                                    cups: engine.cups,
                                  ),
                                  size: const Size(kVirtualWidth, kVirtualHeight),
                                ),
                              ),

                              // Player-drawn lines layer (dissolves gently on victory)
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOut,
                                opacity: engine.isComplete ? 0.0 : 1.0,
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    painter: LinePainter(engine.lineController.lines),
                                    size: const Size(kVirtualWidth, kVirtualHeight),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Touch gesture detector capturing user finger strokes
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) {
                    if (!engine.isPaused) {
                      final virtualPoint = VirtualCoordinateAdapter.screenToVirtual(
                        details.localPosition,
                        viewportSize,
                      );
                      engine.lineController.onPanStart(virtualPoint);
                    }
                  },
                  onPanUpdate: (details) {
                    if (!engine.isPaused) {
                      final virtualPoint = VirtualCoordinateAdapter.screenToVirtual(
                        details.localPosition,
                        viewportSize,
                      );
                      engine.lineController.onPanUpdate(virtualPoint);
                      final center = Offset(viewportSize.width / 2.0, viewportSize.height / 2.0);
                      final delta = details.localPosition - center;
                      setState(() {
                        _touchParallax = Offset(
                          (delta.dx * 0.02).clamp(-12.0, 12.0),
                          (delta.dy * 0.02).clamp(-12.0, 12.0),
                        );
                      });
                    }
                  },
                  onPanEnd: (_) {
                    engine.lineController.onPanEnd();
                    if (_touchParallax != Offset.zero) {
                      setState(() {
                        _touchParallax = Offset.zero;
                      });
                    }
                  },
                ),

                // 6. HUD Controls and statistics (Pure Diegetic: Stage Numeral, Reset, Pause)
                GameHud(
                  levelId: engine.levelConfig.id,
                  capturedCount: engine.particleController.capturedCount,
                  totalSugar: engine.levelConfig.totalSugar,
                  hasGravityToggle: engine.levelConfig.hasGravityToggle,
                  isMusicEnabled: ref.watch(audioManagerProvider).isMusicEnabled,
                  onPause: () {
                    ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                    ref.read(audioManagerProvider).duckMusic(active: true, duckDb: -10.0);
                    engine.pause();
                  },
                  onReset: () {
                    ref.read(audioManagerProvider).playSfx(SoundType.levelReset);
                    ref.read(audioManagerProvider).updateProgress(0.0);
                    ref.read(audioManagerProvider).duckMusic(active: false);
                    setState(() {
                      _hasHandledCompletion = false;
                    });
                    engine.reset();
                  },
                  onToggleGravity: () {
                    ref.read(audioManagerProvider).playSfx(SoundType.gravityInvert);
                    engine.toggleGravity();
                  },
                ),

                // 7. Pause overlay modal with whispered chamber info and audio soundscape control
                if (engine.isPaused)
                  PauseOverlay(
                    levelId: widget.levelId,
                    isMusicEnabled: ref.watch(audioManagerProvider).isMusicEnabled,
                    onToggleMusic: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                      ref.read(audioManagerProvider).toggleMusic();
                      setState(() {});
                    },
                    onResume: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                      ref.read(audioManagerProvider).duckMusic(active: false);
                      engine.resume();
                    },
                    onReplay: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.levelReset);
                      ref.read(audioManagerProvider).updateProgress(0.0);
                      ref.read(audioManagerProvider).duckMusic(active: false);
                      setState(() {
                        _hasHandledCompletion = false;
                      });
                      engine.reset();
                      engine.resume();
                    },
                    onMenu: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                      ref.read(audioManagerProvider).duckMusic(active: false);
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/levels');
                      }
                    },
                  ),

                // 8. Level complete dialog overlay (TASK-050)
                if (engine.isComplete)
                  LevelCompleteDialog(
                    levelId: widget.levelId,
                    levelConfig: widget.levelConfig,
                    onNextLevel: widget.levelId < kTotalLevels
                        ? () {
                            ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                            context.pushReplacement('/game/${widget.levelId + 1}');
                          }
                        : null,
                    onReplay: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.levelReset);
                      setState(() {
                        _hasHandledCompletion = false;
                      });
                      engine.reset();
                    },
                    onMenu: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/levels');
                      }
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
