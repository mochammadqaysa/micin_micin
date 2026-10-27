import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../../core/pixel_terrain_tokens.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/glass_container.dart';
import '../game/painters/background_painter.dart';

/// Zen animated splash screen featuring a tranquil living sugar stream,
/// breathing golden emblem halo, and seamless dissolve transition to the main menu.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _textFade;

  final List<_SplashParticle> _particles = [];
  final math.Random _random = math.Random(42);
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Unified entrance & sand trickle controller (1800ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.80, curve: Curves.easeOut),
      ),
    );

    // Initialize falling sand particles
    for (int i = 0; i < 45; i++) {
      _particles.add(
        _SplashParticle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.08,
          y: _random.nextDouble() * 0.48,
          speed: 0.003 + _random.nextDouble() * 0.005,
          radius: 1.0 + _random.nextDouble() * 1.5,
          alpha: 0.25 + _random.nextDouble() * 0.65,
          color: _random.nextBool()
              ? PixelTerrainTokens.sand
              : PixelTerrainTokens.sage,
        ),
      );
    }

    _entranceController.addListener(_updateParticles);
    _entranceController.forward();

    // Preload audio resources asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioManagerProvider).init();
    });

    // Transition to /menu after 2.2 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go('/menu');
      }
    });
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.y += p.speed;
      // Gentle horizontal dispersal towards center vessel
      if (p.y > 0.46) {
        p.y = 0.0;
        p.x = 0.5 + (_random.nextDouble() - 0.5) * 0.08;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelTerrainTokens.slate,
      body: Stack(
        children: [
          // 1. Plane 1: Background Chalk Slate
          const CustomPaint(
            painter: BackgroundPainter(),
            size: Size.infinite,
          ),

          // 2. Plane 2: Falling sugar trickle stream into the vessel
          CustomPaint(
            painter: _SplashParticlePainter(_particles),
            size: Size.infinite,
          ),

          // 3. Central Pixel Zen Emblem and Typography
          Center(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pixel Plaque with Staggered Scale & Fade
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: GlassContainer(
                          enableLiveBlur: false,
                          borderRadius: 0,
                          borderWidth: 0,
                          backgroundColor: Colors.transparent,
                          boxShadow: const [],
                          child: PixelBox(
                            logicalWidth: 22,
                            logicalHeight: 22,
                            width: 88,
                            height: 88,
                            style: PixelTerrainTokens.tealBoxStyle,
                            child: const Center(
                              child: Icon(
                                Icons.grain_rounded,
                                size: 48,
                                color: PixelTerrainTokens.sand,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Staggered Title Slide & Fade
                    Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textFade.value,
                        child: Column(
                          children: [
                            Text(
                              'Micin, Micin',
                              style: PixelText.mulmaru(
                                fontSize: 32,
                                color: PixelTerrainTokens.sand,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Teka-teki Garis & Butiran Gula',
                              style: PixelText.mulmaru(
                                fontSize: 13,
                                color: PixelTerrainTokens.sage,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sebuah Penghormatan untuk Sugar, Sugar',
                              style: PixelText.mulmaru(
                                fontSize: 10,
                                color: PixelTerrainTokens.sand.withValues(alpha: 0.60),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Stepped Pixel Progress Indicator
                            PixelBox(
                              logicalWidth: 35,
                              logicalHeight: 2,
                              width: 140,
                              height: 8,
                              style: PixelTerrainTokens.slateBoxStyle,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _entranceController.value.clamp(0.05, 1.0),
                                  child: Container(
                                    color: PixelTerrainTokens.sage,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashParticle {
  double x;
  double y;
  final double speed;
  final double radius;
  final double alpha;
  final Color color;

  _SplashParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.alpha,
    required this.color,
  });
}

class _SplashParticlePainter extends CustomPainter {
  final List<_SplashParticle> particles;

  _SplashParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlePainter oldDelegate) => true;
}

