import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/pixel_terrain_tokens.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../game/painters/background_painter.dart';

/// Micin Micin Main Menu — authentic 16-bit Pixel Zen aesthetic.
///
/// Features PixelButton tactile interactions, zen pixel logo plaque,
/// falling sugar-grain rain, and Mulmaru pixel typography.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _sugarController;
  late final Animation<double> _logoSlide;
  late final Animation<double> _fadeIn;

  final List<_SugarDot> _dots = [];
  final math.Random _rng = math.Random(42);
  bool _isNavigating = false;

  static const _bgColor = PixelTerrainTokens.slate;
  static const _dotColor = PixelTerrainTokens.sand;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sugarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tickSugar);

    _logoSlide = Tween<double>(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnDots();
      _entranceController.forward();
      _sugarController.repeat();
      ref.read(audioManagerProvider).playBgm();
    });
  }

  void _spawnDots() {
    final w = MediaQuery.of(context).size.width;
    _dots.clear();
    for (int i = 0; i < 80; i++) {
      _dots.add(_SugarDot(
        x: _rng.nextDouble() * w,
        y: -_rng.nextDouble() * 200.0,
        speed: 0.8 + _rng.nextDouble() * 1.4,
        size: 1.5 + _rng.nextDouble() * 2.0,
        opacity: 0.4 + _rng.nextDouble() * 0.6,
      ));
    }
  }

  void _tickSugar() {
    if (!mounted) return;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    setState(() {
      for (final dot in _dots) {
        dot.y += dot.speed;
        if (dot.y > h + 4.0) {
          dot.y = -_rng.nextDouble() * 60.0;
          dot.x = _rng.nextDouble() * w;
        }
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  void _navigate(String path) {
    if (_isNavigating) return;
    _isNavigating = true;
    ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(playerProgressProvider);
    final lastLevel = progressAsync.when(
      data: (p) => p.highestUnlockedLevel.clamp(1, kTotalLevels),
      loading: () => 1,
      error: (_, __) => 1,
    );
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // 1. Chalkboard background texture
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(
                parallaxOffset: Offset.zero,
                backgroundColor: _bgColor,
                virtualOffset: Offset.zero,
                virtualScale: 1.0,
              ),
            ),
          ),

          // 2. Animated falling sugar grain dots
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SugarRainPainter(dots: _dots, color: _dotColor),
                size: size,
              ),
            ),
          ),

          // 3. Main content column
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, _) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoSlide.value),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Logo
                        _ChalkLogo(),

                        const Spacer(flex: 3),

                        // Primary PLAY button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Center(
                            child: PixelButton(
                              key: const Key('menu_play_button'),
                              logicalWidth: 64,
                              logicalHeight: 13,
                              width: 260,
                              height: 52,
                              normalStyle: PixelTerrainTokens.playButtonNormal,
                              pressedStyle: PixelTerrainTokens.playButtonPressed,
                              pressChildOffset: const Offset(0, 2),
                              onPressed: () => _navigate('/game/$lastLevel'),
                              child: Center(
                                child: Text(
                                  'PLAY',
                                  style: PixelText.mulmaru(
                                    fontSize: 18,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Secondary buttons row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PixelButton(
                                key: const Key('menu_levels_button'),
                                logicalWidth: 31,
                                logicalHeight: 11,
                                width: 124,
                                height: 46,
                                normalStyle: PixelTerrainTokens.actionButtonNormal,
                                pressedStyle: PixelTerrainTokens.actionButtonPressed,
                                pressChildOffset: const Offset(0, 2),
                                onPressed: () => _navigate('/levels'),
                                child: Center(
                                  child: Text(
                                    'LEVELS',
                                    style: PixelText.mulmaru(
                                      fontSize: 13,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              PixelButton(
                                key: const Key('menu_credits_button'),
                                logicalWidth: 31,
                                logicalHeight: 11,
                                width: 124,
                                height: 46,
                                normalStyle: PixelTerrainTokens.pauseButtonNormal,
                                pressedStyle: PixelTerrainTokens.pauseButtonPressed,
                                pressChildOffset: const Offset(0, 2),
                                onPressed: () => _navigate('/credits'),
                                child: Center(
                                  child: Text(
                                    'CREDITS',
                                    style: PixelText.mulmaru(
                                      fontSize: 13,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Bottom controls row: audio toggle + version
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PixelButton(
                                key: const Key('menu_audio_toggle'),
                                logicalWidth: 32,
                                logicalHeight: 11,
                                width: 128,
                                height: 44,
                                normalStyle: ref.watch(audioManagerProvider).isMusicEnabled
                                    ? PixelTerrainTokens.audioButtonNormal
                                    : PixelTerrainTokens.pauseButtonNormal,
                                pressedStyle: PixelTerrainTokens.audioButtonPressed,
                                pressChildOffset: const Offset(0, 1),
                                onPressed: () {
                                  ref
                                      .read(audioManagerProvider)
                                      .playSfx(SoundType.buttonClick);
                                  ref.read(audioManagerProvider).toggleMusic();
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      ref.watch(audioManagerProvider).isMusicEnabled
                                          ? Icons.graphic_eq_rounded
                                          : Icons.volume_off_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ref.watch(audioManagerProvider).isMusicEnabled
                                          ? 'MUSIC ON'
                                          : 'MUTED',
                                      style: PixelText.mulmaru(
                                        fontSize: 10,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'v1.0.0',
                                style: PixelText.mulmaru(
                                  fontSize: 10,
                                  color: PixelTerrainTokens.sage.withValues(alpha: 0.6),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chalk Logo Widget
// ─────────────────────────────────────────────────────────────────────────────

class _ChalkLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/cartoon/zen_pixel_logo.png',
          width: 280,
          height: 94,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'micin',
              style: PixelText.mulmaru(
                fontSize: 14,
                letterSpacing: 2.0,
                color: PixelTerrainTokens.sand,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(
                color: PixelTerrainTokens.sage.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'micin',
              style: PixelText.mulmaru(
                fontSize: 14,
                letterSpacing: 2.0,
                color: PixelTerrainTokens.sage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'draw · guide · fill',
          style: PixelText.mulmaru(
            fontSize: 11,
            letterSpacing: 2.0,
            color: PixelTerrainTokens.sage.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sugar Rain Painter
// ─────────────────────────────────────────────────────────────────────────────

class _SugarRainPainter extends CustomPainter {
  final List<_SugarDot> dots;
  final Color color;

  const _SugarRainPainter({required this.dots, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final dot in dots) {
      paint.color = color.withValues(alpha: dot.opacity * 0.7);
      canvas.drawRect(
        Rect.fromLTWH(dot.x, dot.y, dot.size, dot.size),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SugarRainPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _SugarDot {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;

  _SugarDot({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}
