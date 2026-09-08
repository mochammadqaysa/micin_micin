import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../providers/audio_provider.dart';
import '../game/painters/background_painter.dart';

/// Main menu screen with animated decorative particle rain, PLAY, and CREDITS actions.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final List<_MenuParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize 60 decorative floating particles
    for (int i = 0; i < 60; i++) {
      _particles.add(
        _MenuParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.001 + _random.nextDouble() * 0.003,
          radius: 1.0 + _random.nextDouble() * 2.0,
          opacity: 0.2 + _random.nextDouble() * 0.6,
        ),
      );
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateParticles)
     ..repeat();

    // Start background music loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioManagerProvider).playBgm();
    });
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.y += p.speed;
      if (p.y > 1.0) {
        p.y = 0.0;
        p.x = _random.nextDouble();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioManagerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF101418),
      body: Stack(
        children: [
          // 1. Plane 1 (Far Depth): Background Chalk Slate
          const CustomPaint(
            painter: BackgroundPainter(),
            size: Size.infinite,
          ),

          // 2. Plane 2: Decorative falling sugar particles
          CustomPaint(
            painter: _MenuParticlePainter(_particles),
            size: Size.infinite,
          ),

          // 3. Audio toggle in top-right corner
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C22).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF28323E),
                      width: 1.0,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      audio.isMusicEnabled
                          ? Icons.music_note_rounded
                          : Icons.music_off_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                      audio.toggleMusic();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),

          // 4. Central Title and Zen Action Buttons
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo / Zen Crystal Icon
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF192028),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.10),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.grain_rounded,
                        size: 44,
                        color: Color(0xFFFFD54F),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Game Title
                    const Text(
                      'Micin, Micin',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF1F5F9),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Teka-teki Garis & Butiran Gula',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        color: Color(0xFF8092A7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 52),

                    // Zen PLAY Button (Basalt pill with glowing warm amber rim)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                          context.push('/levels');
                        },
                        borderRadius: BorderRadius.circular(22),
                        splashColor: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                        highlightColor: Colors.transparent,
                        child: Container(
                          width: 210,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C242C),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.65),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD54F).withValues(alpha: 0.12),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 24,
                                color: Color(0xFFFFD54F),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'PLAY',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Zen CREDITS Button (Subtle quiet basalt pill)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                          context.push('/credits');
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.white10,
                        highlightColor: Colors.transparent,
                        child: Container(
                          width: 210,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141920),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF28323E),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'CREDITS',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuParticle {
  double x;
  double y;
  final double speed;
  final double radius;
  final double opacity;

  _MenuParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class _MenuParticlePainter extends CustomPainter {
  final List<_MenuParticle> particles;

  _MenuParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MenuParticlePainter oldDelegate) => true;
}
