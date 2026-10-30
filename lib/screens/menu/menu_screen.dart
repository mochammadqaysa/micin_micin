import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../game/painters/background_painter.dart';

/// Authentic Bart Bonte Main Menu for Micin Micin (Sugar, Sugar).
///
/// Features:
/// - Hero typography: "sugar, sugar" lowercase authentic branding.
/// - Autoplay background acoustic guitar loop (`sugar_song.mp3`).
/// - Gentle fluttering sugar-grain rain in the background.
/// - Tactile minimalist rounded action buttons (PLAY, LEVELS, CREDITS, AUDIO).
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

  // Authentic Deep Blue Slate background palette per StageVisualTheme.menu
  static const _bgColor = Color(0xFF07456B);
  static const _dotColor = Color(0xFFFFFFFF);

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

    _logoSlide = Tween<double>(begin: -35.0, end: 0.0).animate(
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
    for (int i = 0; i < 90; i++) {
      _dots.add(_SugarDot(
        x: _rng.nextDouble() * w,
        y: -_rng.nextDouble() * 200.0,
        speed: 0.8 + _rng.nextDouble() * 1.5,
        size: 2.0 + _rng.nextDouble() * 1.8,
        opacity: 0.35 + _rng.nextDouble() * 0.55,
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
          dot.y = -_rng.nextDouble() * 50.0;
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
          // 1. Solid background canvas with preserved BackgroundPainter
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

          // 2. Soft animated falling sugar crystals
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
                        const Spacer(flex: 3),

                        // Authentic "sugar, sugar" hero title & subtitle
                        const _SugarSugarLogo(),

                        const Spacer(flex: 3),

                        // Primary PLAY button (Bart Bonte bold clean white pill)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Center(
                            child: _MenuActionButton(
                              key: const Key('menu_play_button'),
                              width: 250,
                              height: 54,
                              backgroundColor: const Color(0xFFF8FAFC),
                              foregroundColor: _bgColor,
                              label: 'PLAY',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.0,
                              elevation: 4.0,
                              onPressed: () => _navigate('/game/$lastLevel'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Secondary action buttons (LEVELS & CREDITS)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _MenuActionButton(
                                key: const Key('menu_levels_button'),
                                width: 120,
                                height: 46,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                foregroundColor: Colors.white,
                                borderColor: Colors.white.withValues(alpha: 0.35),
                                label: 'LEVELS',
                                fontSize: 13,
                                letterSpacing: 2.0,
                                onPressed: () => _navigate('/levels'),
                              ),
                              const SizedBox(width: 12),
                              _MenuActionButton(
                                key: const Key('menu_credits_button'),
                                width: 120,
                                height: 46,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                foregroundColor: Colors.white,
                                borderColor: Colors.white.withValues(alpha: 0.35),
                                label: 'CREDITS',
                                fontSize: 13,
                                letterSpacing: 2.0,
                                onPressed: () => _navigate('/credits'),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Bottom controls row: audio toggle + version indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MenuAudioToggle(
                                key: const Key('menu_audio_toggle'),
                                isMusicEnabled:
                                    ref.watch(audioManagerProvider).isMusicEnabled,
                                onToggle: () {
                                  ref
                                      .read(audioManagerProvider)
                                      .playSfx(SoundType.buttonClick);
                                  ref.read(audioManagerProvider).toggleMusic();
                                  setState(() {});
                                },
                              ),
                              Text(
                                'v1.0.0',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.45),
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
// Authentic "sugar, sugar" Typography Hero Logo
// ─────────────────────────────────────────────────────────────────────────────

class _SugarSugarLogo extends StatelessWidget {
  const _SugarSugarLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'sugar, sugar',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Color(0x66000000),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'micin',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'micin',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'draw · guide · fill',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimalist Menu Action Button
// ─────────────────────────────────────────────────────────────────────────────

class _MenuActionButton extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double elevation;
  final VoidCallback onPressed;

  const _MenuActionButton({
    super.key,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.label,
    required this.fontSize,
    this.fontWeight = FontWeight.w700,
    required this.letterSpacing,
    this.elevation = 0.0,
    required this.onPressed,
  });

  @override
  State<_MenuActionButton> createState() => _MenuActionButtonState();
}

class _MenuActionButtonState extends State<_MenuActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1.5)
                  : null,
              boxShadow: widget.elevation > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: widget.elevation * 2,
                        offset: Offset(0, widget.elevation),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  letterSpacing: widget.letterSpacing,
                  color: widget.foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimalist Audio Toggle Pill
// ─────────────────────────────────────────────────────────────────────────────

class _MenuAudioToggle extends StatefulWidget {
  final bool isMusicEnabled;
  final VoidCallback onToggle;

  const _MenuAudioToggle({
    super.key,
    required this.isMusicEnabled,
    required this.onToggle,
  });

  @override
  State<_MenuAudioToggle> createState() => _MenuAudioToggleState();
}

class _MenuAudioToggleState extends State<_MenuAudioToggle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.isMusicEnabled ? 'MUSIC ON' : 'MUTED';

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onToggle();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isMusicEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
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
      paint.color = color.withValues(alpha: dot.opacity * 0.75);
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
