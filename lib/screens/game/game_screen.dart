import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../data/level_repository.dart';
import '../../engine/game_engine.dart';
import '../../models/level_config.dart';
import '../../models/level_visual_theme.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../../widgets/countdown_overlay.dart';
import '../../widgets/pause_overlay.dart';
import '../../widgets/victory_overlay.dart';
import '../../flame_game/micin_game.dart';
import '../../flame_game/components/level_geometry_component.dart';
import '../../flame_game/components/particle_system_component.dart';
import 'game_hud.dart';

/// Interactive game screen hosting the Flame game canvas, HUD, and overlays.
///
/// Replaces the CustomPainter + Flutter Ticker stack with a [GameWidget] that
/// hosts [MicinGame]. All physics remain in the unchanged [GameEngine].
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

class _GameScreenState extends ConsumerState<GameScreen> {
  MicinGame? _game;
  GameEngine? _gameEngine;
  bool _isLoading = true;
  bool _hasHandledCompletion = false;
  String? _errorMessage;
  late final AudioManager _audioManager;

  @override
  void initState() {
    super.initState();
    _audioManager = ref.read(audioManagerProvider);
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      LevelConfig? config = widget.levelConfig;
      if (config == null) {
        const repo = LevelRepository();
        config = await repo.loadLevel(widget.levelId);
      }
      if (!mounted) return;

      final visualTheme = LevelVisualTheme.forLevel(widget.levelId);
      final propColliders = visualTheme.silhouetteProps
          .expand((p) => p.generateColliders())
          .toList();

      final engine = GameEngine(
        levelConfig: config,
        propColliders: propColliders,
        onParticleCaptured: (cup, particle) {
          if (!mounted) return;
          final ratio = cup.targetAmount > 0
              ? (cup.capturedCount / cup.targetAmount).clamp(0.0, 1.0)
              : 0.0;
          _audioManager.playParticleCapture(fillPercentage: ratio);
        },
        onFilterPassed: (filter, particle) {
          if (!mounted) return;
          _audioManager.playFilterResonance(filterColor: filter.targetColor);
        },
      );
      engine.isSpawningActive = false;
      engine.addListener(_onEngineUpdate);

      final game = MicinGame(engine: engine, visualTheme: visualTheme);

      setState(() {
        _gameEngine = engine;
        _game = game;
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

    // Update audio progress stem
    final engine = _gameEngine;
    if (engine != null) {
      final total = engine.totalTarget;
      final ratio = total > 0 ? (engine.totalCaptured / total).clamp(0.0, 1.0) : 0.0;
      _audioManager.updateProgress(ratio);
    }

    // Level completion handler (Bart Bonte authentic centered NEXT dialog)
    if (_gameEngine?.isComplete == true && !_hasHandledCompletion) {
      _hasHandledCompletion = true;
      _game?.addTrauma(0.45);
      _audioManager.playSfx(SoundType.levelComplete);
      ref.read(playerProgressProvider.notifier).markCompleted(widget.levelId);
      if (widget.levelId < kTotalLevels) {
        ref.read(playerProgressProvider.notifier).unlockLevel(widget.levelId + 1);
      }
      _game?.overlays.add(MicinGame.kOverlayVictory);
    }

    // Defer setState to post-frame to avoid calling it during Flame's update
    // which runs inside GameWidget's build/layout phase.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _gameEngine?.removeListener(_onEngineUpdate);
    _gameEngine?.dispose();
    _audioManager.duckMusic(active: false);
    LevelGeometryFlameComponent.clearCache();
    ParticleSystemFlameComponent.clearBuffers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0E14),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFB300),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_errorMessage != null || _game == null || _gameEngine == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0E14),
        body: Center(
          child: Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(color: Color(0xFFFF6B6B), fontFamily: 'Outfit'),
          ),
        ),
      );
    }

    final engine = _gameEngine!;
    final game = _game!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        game.pauseGame();
        _audioManager.duckMusic(active: true, duckDb: -10.0);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            // ── HUD (always visible during gameplay) ─────────────────────────
            MicinGame.kOverlayHud: (context, _) => GameHud(
              levelId: engine.levelConfig.id,
              capturedCount: engine.particleController.capturedCount,
              totalSugar: engine.levelConfig.totalSugar,
              hasGravityToggle: engine.levelConfig.hasGravityToggle,
              isMusicEnabled: ref.watch(audioManagerProvider).isMusicEnabled,
              onPause: () {
                _audioManager.playSfx(SoundType.buttonClick);
                _audioManager.duckMusic(active: true, duckDb: -10.0);
                game.pauseGame();
              },
              onReset: () {
                _audioManager.playSfx(SoundType.levelReset);
                _audioManager.updateProgress(0.0);
                _audioManager.duckMusic(active: false);
                game.resetGame();
                setState(() {
                  _hasHandledCompletion = false;
                });
              },
              onToggleGravity: () {
                _audioManager.playSfx(SoundType.gravityInvert);
                engine.toggleGravity();
              },
            ),

            // ── Pause overlay ─────────────────────────────────────────────────
            MicinGame.kOverlayPause: (context, _) => PauseOverlay(
              levelId: widget.levelId,
              isMusicEnabled: ref.watch(audioManagerProvider).isMusicEnabled,
              onToggleMusic: () {
                _audioManager.playSfx(SoundType.buttonClick);
                _audioManager.toggleMusic();
                setState(() {});
              },
              onResume: () {
                _audioManager.playSfx(SoundType.buttonClick);
                _audioManager.duckMusic(active: false);
                game.resumeGame();
              },
              onReplay: () {
                _audioManager.playSfx(SoundType.levelReset);
                _audioManager.updateProgress(0.0);
                _audioManager.duckMusic(active: false);
                game.resetGame();
                game.resumeGame();
                setState(() {
                  _hasHandledCompletion = false;
                });
              },
              onMenu: () {
                _audioManager.playSfx(SoundType.buttonClick);
                _audioManager.duckMusic(active: false);
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/levels');
                }
              },
            ),

            // ── Countdown overlay ─────────────────────────────────────────────
            MicinGame.kOverlayCountdown: (context, _) => CountdownOverlay(
              onFinished: () {
                if (!mounted) return;
                game.onCountdownComplete();
              },
            ),

            // ── Victory overlay (Bart Bonte circular NEXT dialog) ──────────────
            MicinGame.kOverlayVictory: (context, _) => VictoryOverlay(
              levelId: widget.levelId,
              isLastLevel: widget.levelId >= kTotalLevels,
              onNext: () {
                _audioManager.playSfx(SoundType.buttonClick);
                game.overlays.remove(MicinGame.kOverlayVictory);
                if (widget.levelId < kTotalLevels) {
                  context.pushReplacement('/game/${widget.levelId + 1}');
                } else {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/levels');
                  }
                }
              },
            ),
          },
        ),
      ),
    );
  }
}
