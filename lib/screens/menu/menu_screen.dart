import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../game/painters/background_painter.dart';

/// Micin Micin Main Menu — arcade game aesthetic.
///
/// Design language: diegetic chalkboard world, tactile chunky buttons with
/// hard drop-shadows, chalk-dust logo, animated sugar-grain rain waterfall.
/// References: Bart Bonte's Sugar Sugar, classic Flash puzzle game menus.
/// Explicitly avoids: glassmorphism, generic rounded cards, mobile-app patterns.
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

  static const _bgColor = Color(0xFF0B1828);
  static const _dotColor = Color(0xFFFFF8E7);

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
                          child: _ArcadeButton(
                            label: 'PLAY',
                            topColor: const Color(0xFFFFB300),
                            shadowColor: const Color(0xFF7A5200),
                            textColor: Colors.white,
                            onTap: () => _navigate('/game/$lastLevel'),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Secondary buttons row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ArcadeButton(
                                  label: 'LEVELS',
                                  topColor: const Color(0xFF1E3A5F),
                                  shadowColor: const Color(0xFF0A1520),
                                  textColor: const Color(0xFF90CAF9),
                                  fontSize: 16,
                                  onTap: () => _navigate('/levels'),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _ArcadeButton(
                                  label: 'CREDITS',
                                  topColor: const Color(0xFF1B3A2E),
                                  shadowColor: const Color(0xFF081510),
                                  textColor: const Color(0xFF80CBC4),
                                  fontSize: 16,
                                  onTap: () => _navigate('/credits'),
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
                              _AudioToggleButton(
                                isMusicEnabled:
                                    ref.watch(audioManagerProvider).isMusicEnabled,
                                onTap: () {
                                  ref
                                      .read(audioManagerProvider)
                                      .playSfx(SoundType.buttonClick);
                                  ref.read(audioManagerProvider).toggleMusic();
                                  setState(() {});
                                },
                              ),
                              Text(
                                'v1.0.0',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.25),
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
        // Chalk-texture sugar emitter icon
        CustomPaint(
          size: const Size(48, 48),
          painter: _EmitterIconPainter(),
        ),
        const SizedBox(height: 14),
        // Main title — two-line chalk style
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFCDD5E0)],
          ).createShader(bounds),
          child: Column(
            children: [
              Text(
                'micin',
                style: GoogleFonts.outfit(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              Text(
                'micin',
                style: GoogleFonts.outfit(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Tagline
        Text(
          'draw · guide · fill',
          style: GoogleFonts.outfit(
            fontSize: 13,
            letterSpacing: 3.0,
            color: Colors.white.withValues(alpha: 0.35),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arcade-Style Chunky Button with Hard Drop Shadow
// ─────────────────────────────────────────────────────────────────────────────

class _ArcadeButton extends StatefulWidget {
  final String label;
  final Color topColor;
  final Color shadowColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback onTap;

  const _ArcadeButton({
    required this.label,
    required this.topColor,
    required this.shadowColor,
    required this.textColor,
    this.fontSize = 20,
    required this.onTap,
  });

  @override
  State<_ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<_ArcadeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const pressDepth = 4.0;
    final depressed = _pressed ? pressDepth : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: depressed, bottom: pressDepth - depressed),
        child: CustomPaint(
          painter: _ArcadeButtonPainter(
            topColor: widget.topColor,
            shadowColor: widget.shadowColor,
            depressed: _pressed,
          ),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: GoogleFonts.outfit(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                color: widget.textColor,
                letterSpacing: 2.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(0, 1.5),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcadeButtonPainter extends CustomPainter {
  final Color topColor;
  final Color shadowColor;
  final bool depressed;

  const _ArcadeButtonPainter({
    required this.topColor,
    required this.shadowColor,
    required this.depressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(8.0);
    const depth = 5.0;

    if (!depressed) {
      // Hard drop shadow (solid, no blur — arcade style)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, depth, size.width, size.height),
          radius,
        ),
        Paint()..color = shadowColor,
      );
    }

    // Top face with subtle vertical gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(topColor, Colors.white, 0.15)!,
            topColor,
            Color.lerp(topColor, Colors.black, 0.15)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Top highlight edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_ArcadeButtonPainter old) =>
      old.topColor != topColor ||
      old.shadowColor != shadowColor ||
      old.depressed != depressed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio Toggle Button
// ─────────────────────────────────────────────────────────────────────────────

class _AudioToggleButton extends StatelessWidget {
  final bool isMusicEnabled;
  final VoidCallback onTap;

  const _AudioToggleButton({
    required this.isMusicEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isMusicEnabled
              ? const Color(0xFF1A2E44)
              : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMusicEnabled
                ? const Color(0xFF2E5080).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMusicEnabled ? Icons.graphic_eq_rounded : Icons.volume_off_rounded,
              color: isMusicEnabled
                  ? const Color(0xFF64B5F6)
                  : Colors.white.withValues(alpha: 0.30),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              isMusicEnabled ? 'MUSIC ON' : 'MUTED',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isMusicEnabled
                    ? const Color(0xFF64B5F6)
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      ),
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
// Emitter Icon Painter (decorative sugar funnel above logo)
// ─────────────────────────────────────────────────────────────────────────────

class _EmitterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Funnel body
    final path = Path()
      ..moveTo(w * 0.1, h * 0.15)
      ..lineTo(w * 0.35, h * 0.75)
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w * 0.9, h * 0.15)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFB300)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Spout
    final spout = Path()
      ..moveTo(w * 0.35, h * 0.75)
      ..lineTo(w * 0.38, h * 0.90)
      ..lineTo(w * 0.62, h * 0.90)
      ..lineTo(w * 0.65, h * 0.75);
    canvas.drawPath(spout, Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8);
  }

  @override
  bool shouldRepaint(_EmitterIconPainter _) => false;
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
