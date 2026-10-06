import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/neu_container.dart';
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
  late final Animation<double> _haloFade;

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

    _haloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeInOut),
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
              ? GlassTokens.radiantGold
              : GlassTokens.textSpecular,
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
      backgroundColor: GlassTokens.obsidianVoid,
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

          // 3. Central Zen Emblem and Typography
          Center(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                final double pulse =
                    math.sin(_entranceController.value * math.pi * 3).abs();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Zen Vessel Emblem with Staggered Scale & Fade
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: GlassContainer(
                          width: 88,
                          height: 88,
                          shape: BoxShape.circle,
                          enableLiveBlur: false,
                          backgroundColor: GlassTokens.surfaceLight,
                          borderWidth: 1.8,
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              GlassTokens.radiantGold.withValues(alpha: 0.65 + pulse * 0.35),
                              GlassTokens.radiantGold.withValues(alpha: 0.20),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GlassTokens.radiantGold
                                  .withValues(alpha: 0.12 * _haloFade.value + pulse * 0.18),
                              blurRadius: 28 + pulse * 14,
                              spreadRadius: 2 + pulse * 4,
                            ),
                          ],
                          child: Center(
                            child: Icon(
                              Icons.grain_rounded,
                              size: 46,
                              color: GlassTokens.radiantGold
                                  .withValues(alpha: 0.90 + pulse * 0.10),
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
                            const Text(
                              'Micin, Micin',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 38,
                                fontWeight: FontWeight.w600,
                                color: GlassTokens.textSpecular,
                                letterSpacing: 2.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Teka-teki Garis & Butiran Gula',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: GlassTokens.textMuted,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sebuah Penghormatan untuk Sugar, Sugar',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                color: GlassTokens.textDim,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 32),
                            NeuContainer(
                              width: 140,
                              height: 6,
                              borderRadius: 3,
                              style: NeuStyle.inset,
                              depth: 2.5,
                              blur: 4.0,
                              padding: const EdgeInsets.all(1.5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _entranceController.value.clamp(0.05, 1.0),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: const LinearGradient(
                                        colors: [
                                          NeuTokens.accentAmber,
                                          NeuTokens.accentCyan,
                                        ],
                                      ),
                                    ),
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

