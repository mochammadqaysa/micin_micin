import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../models/player_progress.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../game/painters/background_painter.dart';

/// Zen main menu screen featuring a choreographed staggered entrance animation,
/// living sugar sand stream inspired by Bart Bonte's Sugar, Sugar, and tactile basalt action buttons.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;

  // Staggered Entrance Animations
  late final Animation<double> _bgFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlide;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _playSlide;
  late final Animation<double> _playScale;
  late final Animation<double> _playFade;
  late final Animation<double> _secondarySlide;
  late final Animation<double> _secondaryFade;

  // Living Sand Particles
  final List<_MenuSugarGrain> _grains = [];
  final math.Random _random = math.Random(1337);
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();

    // 1. Choreographed Staggered Entrance Controller (1.4s)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.08, 0.60, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<double>(begin: -24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.08, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.08, 0.45, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
      ),
    );

    // Play button emerges smoothly directly under the logo/title
    _playSlide = Tween<double>(begin: 36.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _playScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _playFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.80, curve: Curves.easeOut),
      ),
    );

    _secondarySlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _secondaryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOut),
      ),
    );

    // 2. Continuous breathing pulse for Play button glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 3. Living Sugar Sand Stream (70 particles)
    for (int i = 0; i < 70; i++) {
      _grains.add(
        _MenuSugarGrain(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.0012 + _random.nextDouble() * 0.0035,
          radius: 0.9 + _random.nextDouble() * 1.8,
          alpha: 0.18 + _random.nextDouble() * 0.60,
          color: _random.nextDouble() > 0.35
              ? const Color(0xFFFFFFFF)
              : const Color(0xFFFFD54F),
        ),
      );
    }

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateParticles)
     ..repeat();

    _entranceController.forward();

    // Start background music loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioManagerProvider).playBgm();
    });
  }

  void _updateParticles() {
    for (final grain in _grains) {
      grain.y += grain.speed;

      // Gentle interactive touch deflection if finger is pressed/dragged
      if (_touchPosition != null) {
        final double dx = grain.x - _touchPosition!.dx;
        final double dy = grain.y - _touchPosition!.dy;
        final double distSq = dx * dx + dy * dy;
        if (distSq < 0.04 && distSq > 0.0001) {
          grain.x += dx * 0.02;
          grain.y += dy * 0.02;
        }
      }

      if (grain.y > 1.0) {
        grain.y = 0.0;
        grain.x = _random.nextDouble();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioManagerProvider);
    final progressAsync = ref.watch(playerProgressProvider);
    final progress = progressAsync.asData?.value ?? PlayerProgress.initial();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1318),
      body: Listener(
        onPointerDown: (event) {
          final size = MediaQuery.sizeOf(context);
          if (size.width > 0 && size.height > 0) {
            _touchPosition = Offset(
              event.position.dx / size.width,
              event.position.dy / size.height,
            );
          }
        },
        onPointerMove: (event) {
          final size = MediaQuery.sizeOf(context);
          if (size.width > 0 && size.height > 0) {
            _touchPosition = Offset(
              event.position.dx / size.width,
              event.position.dy / size.height,
            );
          }
        },
        onPointerUp: (_) => _touchPosition = null,
        onPointerCancel: (_) => _touchPosition = null,
        child: Stack(
          children: [
            // 1. Plane 1 (Far Depth): Background Chalk Slate
            AnimatedBuilder(
              animation: _bgFade,
              builder: (context, child) {
                return Opacity(
                  opacity: _bgFade.value,
                  child: const CustomPaint(
                    painter: BackgroundPainter(),
                    size: Size.infinite,
                  ),
                );
              },
            ),

            // 2. Plane 2: Living Sugar Sand Stream (Bart Bonte signature tribute)
            CustomPaint(
              painter: _MenuSugarPainter(_grains),
              size: Size.infinite,
            ),

            // 3. Audio toggle in top-right corner with staggered fade
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedBuilder(
                    animation: _secondaryFade,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _secondaryFade.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161D25).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF283442),
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
                      );
                    },
                  ),
                ),
              ),
            ),

            // 4. Central Composition with Choreographed Staggered Transitions
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      final double pulse = _pulseController.value;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Step 2: Zen Vessel Logo drops & scales into place
                          Transform.translate(
                            offset: Offset(0, _logoSlide.value),
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoFade.value,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161D25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFFD54F)
                                          .withValues(alpha: 0.40 + pulse * 0.40),
                                      width: 1.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD54F)
                                            .withValues(alpha: 0.10 + pulse * 0.16),
                                        blurRadius: 24 + pulse * 12,
                                        spreadRadius: 2 + pulse * 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.grain_rounded,
                                    size: 46,
                                    color: Color(0xFFFFD54F),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Step 3: Title 'Micin, Micin' & Subtitle slides up from underneath logo
                          Transform.translate(
                            offset: Offset(0, _titleSlide.value),
                            child: Opacity(
                              opacity: _titleFade.value,
                              child: Column(
                                children: [
                                  const Text(
                                    'Micin, Micin',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 42,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF1F5F9),
                                      letterSpacing: 2.2,
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
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Step 4: PLAY Button emerges smoothly DIRECTLY BELOW the logo & title!
                          Transform.translate(
                            offset: Offset(0, _playSlide.value),
                            child: Transform.scale(
                              scale: _playScale.value,
                              child: Opacity(
                                opacity: _playFade.value,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                                      context.push('/levels');
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    splashColor: const Color(0xFFFFD54F).withValues(alpha: 0.18),
                                    highlightColor: Colors.transparent,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 224,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B232D),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: const Color(0xFFFFD54F)
                                              .withValues(alpha: 0.55 + pulse * 0.35),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD54F)
                                                .withValues(alpha: 0.12 + pulse * 0.16),
                                            blurRadius: 18 + pulse * 10,
                                            spreadRadius: 1 + pulse * 2,
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            size: 26,
                                            color: Color(0xFFFFD54F),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'PLAY',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFFFFFF),
                                              letterSpacing: 2.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Step 5: Secondary Actions (CREDITS & Campaign Progress Snapshot)
                          Transform.translate(
                            offset: Offset(0, _secondarySlide.value),
                            child: Opacity(
                              opacity: _secondaryFade.value,
                              child: Column(
                                children: [
                                  // Zen CREDITS Button (Tactile basalt pill)
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
                                        width: 224,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF141A22),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF283442),
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

                                  const SizedBox(height: 28),

                                  // Zen Campaign Progress Snapshot Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141920).withValues(alpha: 0.70),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF222C38),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFFD54F),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '✦ ${progress.completedCount} / $kTotalLevels Taman Selesai',
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF8092A7),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSugarGrain {
  double x;
  double y;
  final double speed;
  final double radius;
  final double alpha;
  final Color color;

  _MenuSugarGrain({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.alpha,
    required this.color,
  });
}

class _MenuSugarPainter extends CustomPainter {
  final List<_MenuSugarGrain> grains;

  _MenuSugarPainter(this.grains);

  @override
  void paint(Canvas canvas, Size size) {
    for (final grain in grains) {
      final paint = Paint()
        ..color = grain.color.withValues(alpha: grain.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(grain.x * size.width, grain.y * size.height),
        grain.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MenuSugarPainter oldDelegate) => true;
}

