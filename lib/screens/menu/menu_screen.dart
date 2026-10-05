import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../engine/drawing/line_controller.dart';
import '../../models/player_progress.dart';
import '../../models/sugar_particle.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../../widgets/glass_container.dart';
import '../game/painters/background_painter.dart';
import '../game/painters/line_painter.dart';

/// Zen main menu screen implementing Stitch "Main Menu - Zen Gateway"
/// and "Interactive Transition Spec: Menu to Chambers".
///
/// Features:
/// - Diegetic Sanctuary V header & chimes toggle.
/// - Fluid living sugar sand stream inspired by Bart Bonte's Sugar, Sugar.
/// - Center stage diegetic physics chamber visualizer (spawner aperture, hairline spline, basalt cup).
/// - Contemplative navigation suite (Play pill, Chambers, Colophon/Credits).
/// - 550ms Interactive Transition Choreography:
///   * Rule α: Aperture letter-spacing expansion (0.35em -> 0.45em) & fade.
///   * Rule β: Guide barrier dematerialization into motes.
///   * Rule γ: CTA node unfolding into active chamber coordinate.
///   * Audio: -10dB resonance chime cue at t=120ms.
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
  late final AnimationController _transitionController;

  // Staggered Entrance Animations
  late final Animation<double> _bgFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlide;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _centerChamberFade;
  late final Animation<double> _playSlide;
  late final Animation<double> _playScale;
  late final Animation<double> _playFade;
  late final Animation<double> _secondarySlide;
  late final Animation<double> _secondaryFade;

  // Interactive Physics Drawing & Living Sand Simulation
  late final LineController _lineController;
  final List<_MenuSugarGrain> _grains = [];
  final math.Random _random = math.Random(1337);
  Offset? _touchPosition;
  Offset? _dragStartPos;
  bool _isDrawing = false;
  DateTime? _lastTapTime;
  bool _isNavigating = false;
  Size _screenSize = Size.zero;

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
        curve: const Interval(0.22, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.22, 0.55, curve: Curves.easeOut),
      ),
    );

    _centerChamberFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _playSlide = Tween<double>(begin: 32.0, end: 0.0).animate(
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

    // 2. Continuous breathing pulse for glow rings & buttons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 3. Interactive Transition Controller: Menu to Chambers (550ms)
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // 4. Line Drawing & Interactive Endless Particle Simulation
    _lineController = LineController();
    _initGrains();

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

  /// Populates the initial circular particle pool with distributed vertical waterfall.
  void _initGrains() {
    _grains.clear();
    const double fallbackW = 400.0;
    const double fallbackH = 700.0;
    final double w = _screenSize.width > 0 ? _screenSize.width : fallbackW;
    final double h = _screenSize.height > 0 ? _screenSize.height : fallbackH;
    final double spawnerX = w * 0.5;
    const double spawnerY = 56.0;

    for (int i = 0; i < 180; i++) {
      final double progress = i / 180.0;
      _grains.add(
        _MenuSugarGrain(
          x: spawnerX + (_random.nextDouble() * 10.0 - 5.0),
          y: spawnerY + progress * (h - spawnerY),
          vx: (_random.nextDouble() * 0.6 - 0.3),
          vy: 0.8 + _random.nextDouble() * 1.4,
          radius: 1.0 + _random.nextDouble() * 1.5,
          baseAlpha: 0.35 + _random.nextDouble() * 0.60,
          color: _random.nextDouble() > 0.30
              ? GlassTokens.textSpecular
              : GlassTokens.radiantGold,
        ),
      );
    }
  }

  /// 60 FPS physics tick: gravity, CCD against user-drawn chalk lines, and endless recycling.
  void _updateParticles() {
    final double w = _screenSize.width > 0 ? _screenSize.width : 400.0;
    final double h = _screenSize.height > 0 ? _screenSize.height : 700.0;
    final double spawnerX = w * 0.5;
    final double spawnerY = MediaQuery.paddingOf(context).top + 24.0;

    final segments = _lineController.allSegments;

    for (final grain in _grains) {
      if (!grain.isActive) {
        grain.x = spawnerX + (_random.nextDouble() * 8.0 - 4.0);
        grain.y = spawnerY + (_random.nextDouble() * 4.0);
        grain.vx = (_random.nextDouble() * 0.6 - 0.3);
        grain.vy = 0.8 + _random.nextDouble() * 1.2;
        grain.isActive = true;
      }

      // 1. Downward gravity acceleration & air damping
      grain.vy = (grain.vy + 0.20).clamp(-kMaxSpeed, kMaxSpeed);
      grain.vx = (grain.vx * 0.99).clamp(-kMaxSpeed, kMaxSpeed);

      // 2. Interactive touch push if finger/cursor is pressed/dragged
      if (_touchPosition != null) {
        final double dx = grain.x - _touchPosition!.dx;
        final double dy = grain.y - _touchPosition!.dy;
        final double distSq = dx * dx + dy * dy;
        if (distSq < 2500 && distSq > 1.0) {
          final double dist = math.sqrt(distSq);
          grain.vx += (dx / dist) * 0.40;
          grain.vy += (dy / dist) * 0.40;
        }
      }

      // 3. Continuous collision detection against player-drawn chalk lines
      for (final segment in segments) {
        if (segment.resolveCollision(grain, radius: grain.radius)) {
          break;
        }
      }

      // 4. Integrate velocities into positions
      grain.x += grain.vx;
      grain.y += grain.vy;

      // 5. Boundary check & continuous endless recycling back to top nozzle
      if (grain.y > h + 25.0 || grain.x < -35.0 || grain.x > w + 35.0) {
        grain.x = spawnerX + (_random.nextDouble() * 8.0 - 4.0);
        grain.y = spawnerY + (_random.nextDouble() * 4.0);
        grain.vx = (_random.nextDouble() * 0.6 - 0.3);
        grain.vy = 0.8 + _random.nextDouble() * 1.2;
        grain.color = _random.nextDouble() > 0.30
            ? GlassTokens.textSpecular
            : GlassTokens.radiantGold;
        grain.opacity = 0.40 + _random.nextDouble() * 0.55;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Clears all player-drawn lines and plays the reset chime
  void _clearLines() {
    if (_lineController.lines.isEmpty) return;
    ref.read(audioManagerProvider).playSfx(SoundType.levelReset);
    _lineController.clearAll();
    setState(() {});
  }

  /// Triggers the interactive choreography transition to Chambers (LevelSelectScreen)
  void _navigateToChambers() {
    if (_isNavigating) return;
    _isNavigating = true;

    ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
    ref.read(audioManagerProvider).playSfx(SoundType.particlePing);

    _transitionController.forward(from: 0.0);
    context.push('/levels').then((_) {
      if (mounted) {
        _isNavigating = false;
        _transitionController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioManagerProvider);
    final progressAsync = ref.watch(playerProgressProvider);
    final progress = progressAsync.asData?.value ?? PlayerProgress.initial();

    // Determine current highest unlocked level for dynamic CTA resume label
    int currentUnlockedLevel = 1;
    for (int i = 1; i <= kTotalLevels; i++) {
      if (progress.isUnlocked(i)) {
        currentUnlockedLevel = i;
      }
    }

    String actRoman = 'I';
    if (currentUnlockedLevel > 22) {
      actRoman = 'IV';
    } else if (currentUnlockedLevel > 15) {
      actRoman = 'III';
    } else if (currentUnlockedLevel > 7) {
      actRoman = 'II';
    }
    final String actLabel = 'Act $actRoman • Chamber $currentUnlockedLevel';

    _screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: GlassTokens.obsidianVoid,
      body: Listener(
        onPointerDown: (event) {
          if (_isNavigating) return;
          _dragStartPos = event.localPosition;
          _isDrawing = false;
          _touchPosition = event.localPosition;

          final now = DateTime.now();
          if (_lastTapTime != null &&
              now.difference(_lastTapTime!) < const Duration(milliseconds: 320)) {
            _clearLines();
            _lastTapTime = null;
          } else {
            _lastTapTime = now;
          }
        },
        onPointerMove: (event) {
          if (_isNavigating) return;
          _touchPosition = event.localPosition;

          if (!_isDrawing && _dragStartPos != null) {
            final dist = (event.localPosition - _dragStartPos!).distance;
            if (dist > 4.0) {
              _isDrawing = true;
              _lineController.onPanStart(
                _dragStartPos!,
                color: Colors.white,
                thickness: 4.5,
              );
              _lineController.onPanUpdate(event.localPosition);
              setState(() {});
            }
          } else if (_isDrawing) {
            _lineController.onPanUpdate(event.localPosition);
            setState(() {});
          }
        },
        onPointerUp: (_) {
          _touchPosition = null;
          _dragStartPos = null;
          if (_isDrawing) {
            _isDrawing = false;
            _lineController.onPanEnd();
            setState(() {});
          }
        },
        onPointerCancel: (_) {
          _touchPosition = null;
          _dragStartPos = null;
          if (_isDrawing) {
            _isDrawing = false;
            _lineController.onPanEnd();
            setState(() {});
          }
        },
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

            // 2. Plane 2: Player-Drawn Chalk Lines (Interactive Barrier)
            CustomPaint(
              painter: LinePainter(_lineController.lines),
              size: Size.infinite,
            ),

            // 3. Plane 3: Living Sugar Sand Stream (Bart Bonte signature tribute)
            AnimatedBuilder(
              animation: _transitionController,
              builder: (context, child) {
                // Parallax motes layer shift: translateY(-20px * t)
                final t = _transitionController.value;
                return Transform.translate(
                  offset: Offset(0, -20.0 * t),
                  child: child,
                );
              },
              child: CustomPaint(
                painter: _MenuSugarPainter(_grains),
                size: Size.infinite,
              ),
            ),

            // 4. Ambient Vignette Glow
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.1,
                      colors: [
                        const Color(0xFF84D5C7).withValues(alpha: 0.03),
                        Colors.transparent,
                        const Color(0xFF0A0F13).withValues(alpha: 0.60),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 5. Main Foreground Interface Suite
            SafeArea(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _entranceController,
                  _pulseController,
                  _transitionController,
                ]),
                builder: (context, child) {
                  final double pulse = _pulseController.value;
                  final double rawT = _transitionController.value;
                  final double t = Curves.easeOutCubic.transform(rawT);

                  // Rule α: Aperture Spacing (letterSpacing expands 2.2 -> 10.2, fade out)
                  final double titleLetterSpacing = 2.2 + (8.0 * t);
                  final double titleOpacity = (1.0 - rawT * 2.2).clamp(0.0, 1.0) * _titleFade.value;
                  final double titleSlideY = _titleSlide.value - (18.0 * t);

                  // Rule β: Guide Barrier Dematerialize
                  final double guideOpacity = (1.0 - rawT * 2.5).clamp(0.0, 1.0) * _centerChamberFade.value;
                  final double guideScale = (1.0 - t * 0.15);

                  // Rule γ: CTA Node Unfolding (Stitch: holds solid rawT < 0.40, then shrinks and slides up rawT 0.40..0.80)
                  final double ctaOpacity;
                  final double ctaScale;
                  final double ctaSlideY;
                  if (rawT < 0.40) {
                    ctaOpacity = _playFade.value;
                    ctaScale = _playScale.value;
                    ctaSlideY = _playSlide.value;
                  } else if (rawT < 0.80) {
                    final double midP = (rawT - 0.40) / 0.40;
                    ctaOpacity = (1.0 - midP * 0.85).clamp(0.0, 1.0) * _playFade.value;
                    ctaScale = (_playScale.value - midP * 0.35).clamp(0.1, 1.0);
                    ctaSlideY = _playSlide.value - (midP * 40.0);
                  } else {
                    ctaOpacity = 0.0;
                    ctaScale = 0.65 * _playScale.value;
                    ctaSlideY = _playSlide.value - 40.0;
                  }

                  return Column(
                    children: [
                      // Top Floating Header & Atmosphere State (Stitch Canon)
                      _buildHeader(audio, rawT, t),

                      // Center Scroll/Flow Content
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Step 2: Zen Vessel Logo drops & scales into place
                                IgnorePointer(
                                  child: Transform.translate(
                                    offset: Offset(0, _logoSlide.value - (14.0 * t)),
                                    child: Transform.scale(
                                      scale: _logoScale.value * (1.0 - t * 0.1),
                                      child: Opacity(
                                        opacity: (1.0 - rawT * 2.2).clamp(0.0, 1.0) * _logoFade.value,
                                        child: GlassContainer(
                                          width: 72,
                                          height: 72,
                                          shape: BoxShape.circle,
                                          enableLiveBlur: false,
                                          backgroundColor: GlassTokens.surfaceLight,
                                          borderWidth: 1.6,
                                          borderGradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              GlassTokens.radiantGold
                                                  .withValues(alpha: 0.55 + pulse * 0.40),
                                              GlassTokens.radiantGold.withValues(alpha: 0.20),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: GlassTokens.radiantGold
                                                  .withValues(alpha: 0.10 + pulse * 0.16),
                                              blurRadius: 20 + pulse * 10,
                                              spreadRadius: 1 + pulse * 2,
                                            ),
                                          ],
                                          child: const Center(
                                            child: Icon(
                                              Icons.grain_rounded,
                                              size: 38,
                                              color: GlassTokens.radiantGold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Step 3: Title & Subtitle with Rule α Aperture Expansion
                                IgnorePointer(
                                  child: Transform.translate(
                                    offset: Offset(0, titleSlideY),
                                    child: Opacity(
                                      opacity: titleOpacity,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Micin, Micin',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 38,
                                              fontWeight: FontWeight.w600,
                                              color: GlassTokens.textSpecular,
                                              letterSpacing: titleLetterSpacing,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Teka-teki Garis & Butiran Gula',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 14,
                                              color: GlassTokens.textMuted,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Step 3.5: Diegetic Center Physics Visualizer (Stitch Zen Chamber)
                                IgnorePointer(
                                  child: Transform.scale(
                                    scale: guideScale,
                                    child: Opacity(
                                      opacity: guideOpacity,
                                      child: _buildCenterVisualizer(currentUnlockedLevel),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Step 4: PLAY Action Pill (Rule γ CTA Node)
                                Transform.translate(
                                  offset: Offset(0, ctaSlideY),
                                  child: Transform.scale(
                                    scale: ctaScale,
                                    child: Opacity(
                                      opacity: ctaOpacity,
                                      child: _buildPlayButton(
                                        pulse: pulse,
                                        actLabel: actLabel,
                                        levelId: currentUnlockedLevel,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Step 5: Secondary Minimalist Navigation Links (Chambers / CREDITS)
                                Transform.translate(
                                  offset: Offset(0, _secondarySlide.value + (10.0 * t)),
                                  child: Opacity(
                                    opacity: (1.0 - rawT * 2.5).clamp(0.0, 1.0) * _secondaryFade.value,
                                    child: _buildSecondaryLinks(progress),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Quiet Footer Status (Stitch Canon)
                      _buildFooter(progress, rawT, t),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top diegetic header with Sanctuary indicator, center nozzle, clear button, and chimes toggle
  Widget _buildHeader(AudioManager audio, double rawT, double t) {
    final double headerFade = (1.0 - rawT * 2.5).clamp(0.0, 1.0) * _secondaryFade.value;
    final double headerSlideY = -14.0 * t;
    return Transform.translate(
      offset: Offset(0, headerSlideY),
      child: Opacity(
        opacity: headerFade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Sanctuary indicator (IgnorePointer)
              IgnorePointer(
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: GlassTokens.radiantGold,
                        boxShadow: [
                          BoxShadow(
                            color: GlassTokens.radiantGoldGlow,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SANCTUARY V',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: GlassTokens.textDim,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Center: Diegetic Emitter Aperture Nozzle
              IgnorePointer(
                child: GlassContainer(
                  width: 18,
                  height: 18,
                  shape: BoxShape.circle,
                  enableLiveBlur: false,
                  backgroundColor: GlassTokens.surfaceLight,
                  borderWidth: 1.2,
                  borderGradient: LinearGradient(
                    colors: [
                      GlassTokens.radiantGold.withValues(alpha: 0.65),
                      GlassTokens.radiantGold.withValues(alpha: 0.25),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: GlassTokens.radiantGoldGlow,
                      blurRadius: 6,
                    ),
                  ],
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Right: Clear (if lines drawn) + Chimes toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_lineController.lines.isNotEmpty) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _clearLines,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: GlassTokens.radiantGold,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'CLEAR',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: GlassTokens.radiantGold,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                        audio.toggleMusic();
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Text(
                              'Chimes',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: GlassTokens.textDim,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              audio.isMusicEnabled
                                  ? Icons.music_note_rounded
                                  : Icons.music_off_rounded,
                              size: 16,
                              color: GlassTokens.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Diegetic Center Physics Chamber Visualizer with hairline spline & basalt vessel
  Widget _buildCenterVisualizer(int levelId) {
    return SizedBox(
      width: 176,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Spawner Aperture
          Positioned(
            top: 4,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GlassTokens.surfaceElevated,
                border: Border.all(
                  color: GlassTokens.borderHighlight.withValues(alpha: 0.15),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          ),

          // Hairline Guide Stroke Spline & Basalt Cup
          CustomPaint(
            size: const Size(176, 140),
            painter: _ChamberGuidePainter(),
          ),

          // Micro Readout inside Vessel
          Positioned(
            bottom: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$levelId · $kTotalLevels',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'GRAINS IN FLOW',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                    color: GlassTokens.textDim,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Primary Action Pill with 'PLAY' and dynamic chamber label
  Widget _buildPlayButton({
    required double pulse,
    required String actLabel,
    required int levelId,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _navigateToChambers,
        borderRadius: BorderRadius.circular(28),
        splashColor: GlassTokens.radiantGold.withValues(alpha: 0.18),
        highlightColor: Colors.transparent,
        child: GlassContainer(
          width: double.infinity,
          borderRadius: 28,
          enableLiveBlur: false,
          backgroundColor: GlassTokens.surfaceLight,
          borderWidth: 1.4,
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
              color: GlassTokens.radiantGoldGlow.withValues(alpha: 0.15 + pulse * 0.16),
              blurRadius: 18 + pulse * 10,
              spreadRadius: 1 + pulse * 2,
            ),
          ],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: GlassTokens.neonCyan,
                        boxShadow: [
                          BoxShadow(
                            color: GlassTokens.neonCyanGlow,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PLAY',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GlassTokens.textSpecular,
                            letterSpacing: 2.2,
                          ),
                        ),
                        Text(
                          actLabel,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: GlassTokens.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: GlassTokens.radiantGold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Secondary Minimalist Navigation Links (Chambers / CREDITS)
  Widget _buildSecondaryLinks(PlayerProgress progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _navigateToChambers,
              child: const Text(
                'CHAMBERS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: GlassTokens.neonCyan,
                  letterSpacing: 1.8,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '/',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: GlassTokens.textDim,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                context.push('/credits');
              },
              child: const Text(
                'CREDITS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: GlassTokens.textMuted,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Zen Campaign Progress Snapshot Pill
        IgnorePointer(
          child: GlassContainer(
            borderRadius: 16,
            enableLiveBlur: false,
            backgroundColor: GlassTokens.surfaceSubtle,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: GlassTokens.radiantGold,
                    boxShadow: [
                      BoxShadow(
                        color: GlassTokens.radiantGoldGlow,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '✦ ${progress.completedCount} / $kTotalLevels Taman Selesai',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: GlassTokens.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Quiet Footer Status (Stitch Canon)
  Widget _buildFooter(PlayerProgress progress, double rawT, double t) {
    final double footerFade = (1.0 - rawT * 2.5).clamp(0.0, 1.0) * _secondaryFade.value;
    final double footerSlideY = 14.0 * t;
    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(0, footerSlideY),
        child: Opacity(
          opacity: footerFade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.adjust_rounded,
                      size: 13,
                      color: GlassTokens.radiantGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${progress.completedCount} / $kTotalLevels HARMONIZED',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: GlassTokens.textDim,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'G · 9.81',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: GlassTokens.textDim,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.south_rounded,
                      size: 13,
                      color: GlassTokens.textDim,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSugarGrain extends SugarParticle {
  final double radius;
  final double baseAlpha;

  _MenuSugarGrain({
    required super.x,
    required super.y,
    super.vx,
    super.vy,
    super.color,
    required this.radius,
    required this.baseAlpha,
  }) : super(opacity: 1.0, isActive: true);
}

class _MenuSugarPainter extends CustomPainter {
  final List<_MenuSugarGrain> grains;

  _MenuSugarPainter(this.grains);

  @override
  void paint(Canvas canvas, Size size) {
    for (final grain in grains) {
      if (!grain.isActive) continue;
      final paint = Paint()
        ..color = grain.color.withValues(alpha: grain.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(grain.x, grain.y),
        grain.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MenuSugarPainter oldDelegate) => true;
}

class _ChamberGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Hairline guide splines (Stitch guide barriers)
    final splinePaint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(w * 0.18, h * 0.35);
    path1.quadraticBezierTo(w * 0.45, h * 0.46, w * 0.65, h * 0.58);
    canvas.drawPath(path1, splinePaint1);

    final splinePaint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(w * 0.82, h * 0.62);
    path2.quadraticBezierTo(w * 0.68, h * 0.72, w * 0.55, h * 0.82);
    canvas.drawPath(path2, splinePaint2);

    // 2. Basalt U-Cup Boundary
    final cupPaint = Paint()
      ..color = GlassTokens.borderHighlight.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cupX = w * 0.5;
    final cupY = h * 0.76;
    const cupW = 44.0;
    const cupH = 26.0;

    final cupPath = Path();
    cupPath.moveTo(cupX - cupW / 2, cupY);
    cupPath.lineTo(cupX - cupW / 2, cupY + cupH - 6);
    cupPath.quadraticBezierTo(cupX - cupW / 2, cupY + cupH, cupX - cupW / 2 + 6, cupY + cupH);
    cupPath.lineTo(cupX + cupW / 2 - 6, cupY + cupH);
    cupPath.quadraticBezierTo(cupX + cupW / 2, cupY + cupH, cupX + cupW / 2, cupY + cupH - 6);
    cupPath.lineTo(cupX + cupW / 2, cupY);

    canvas.drawPath(cupPath, cupPaint);
  }

  @override
  bool shouldRepaint(covariant _ChamberGuidePainter oldDelegate) => false;
}
