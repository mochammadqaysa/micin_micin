import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../audio/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/player_progress.dart';
import '../../models/sugar_particle.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/neu_button.dart';
import '../../widgets/neu_container.dart';
import '../../widgets/neu_progress_bar.dart';
import '../game/painters/background_painter.dart';

/// Pure Neumorphism Main Menu featuring:
/// - 3D Embossed Game Plaque with dual directional drop shadows.
/// - Tactile extruded PLAY button with spring physics depression.
/// - Interactive 2.5D Physical Sugar dispenser and Neumorphic target cup.
/// - Secondary Neumorphic action bay for LEVELS and CREDITS.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;

  // Granular Sugar Simulation
  final List<_MenuSugarGrain> _grains = [];
  final math.Random _random = math.Random(1337);
  Size _screenSize = Size.zero;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _initGrains();
    _entranceController.forward();

    // Start background music loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioManagerProvider).playBgm();
    });
  }

  void _initGrains() {
    _grains.clear();
    const double fallbackW = 400.0;
    const double fallbackH = 700.0;
    final double w = _screenSize.width > 0 ? _screenSize.width : fallbackW;
    final double h = _screenSize.height > 0 ? _screenSize.height : fallbackH;
    final double spawnerX = w * 0.5;
    const double spawnerY = 56.0;

    for (int i = 0; i < 140; i++) {
      final double progress = i / 140.0;
      _grains.add(
        _MenuSugarGrain(
          x: spawnerX + (_random.nextDouble() * 10.0 - 5.0),
          y: spawnerY + progress * (h - spawnerY - 100.0),
          vx: (_random.nextDouble() * 0.5 - 0.25),
          vy: 1.0 + _random.nextDouble() * 1.6,
          radius: 1.1,
          color: _random.nextDouble() > 0.25
              ? NeuTokens.textPrimary
              : NeuTokens.accentAmber,
        ),
      );
    }
  }

  void _updateParticles(double w, double h) {
    final double spawnerX = w * 0.5;
    const double spawnerY = 52.0;
    final double cupTopY = h - 105.0;

    for (final grain in _grains) {
      if (!grain.isActive) {
        grain.x = spawnerX + (_random.nextDouble() * 6.0 - 3.0);
        grain.y = spawnerY + (_random.nextDouble() * 4.0);
        grain.vx = (_random.nextDouble() * 0.5 - 0.25);
        grain.vy = 0.8 + _random.nextDouble() * 1.2;
        grain.isActive = true;
      }

      grain.vy = (grain.vy + 0.18).clamp(-kMaxSpeed, kMaxSpeed);
      grain.vx = (grain.vx * 0.985).clamp(-kMaxSpeed, kMaxSpeed);

      grain.x += grain.vx;
      grain.y += grain.vy;

      if (grain.y > cupTopY + 45.0 || grain.x < -30.0 || grain.x > w + 30.0) {
        grain.x = spawnerX + (_random.nextDouble() * 6.0 - 3.0);
        grain.y = spawnerY + (_random.nextDouble() * 3.0);
        grain.vx = (_random.nextDouble() * 0.5 - 0.25);
        grain.vy = 0.8 + _random.nextDouble() * 1.2;
        grain.color = _random.nextDouble() > 0.25
            ? NeuTokens.textPrimary
            : NeuTokens.accentAmber;
      }
    }
  }

  void _navigateTo(String route) {
    if (_isNavigating) return;
    _isNavigating = true;

    ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
    context.push(route).then((_) {
      if (mounted) {
        _isNavigating = false;
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioManagerProvider);
    final progressAsync = ref.watch(playerProgressProvider);
    final progress = progressAsync.asData?.value ?? PlayerProgress.initial();

    int currentUnlockedLevel = 1;
    for (int i = 1; i <= kTotalLevels; i++) {
      if (progress.isUnlocked(i)) {
        currentUnlockedLevel = i;
      }
    }

    _screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: NeuTokens.canvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // 1. Neumorphic Canvas Depth & Vignette
              const Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundPainter(
                    backgroundColor: NeuTokens.canvas,
                  ),
                ),
              ),

              // 2. Living 2.5D Physical World (Sugar Grains & Neumorphic Target Cup)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    _updateParticles(w, h);
                    return CustomPaint(
                      painter: _Menu2D5ScenePainter(
                        grains: _grains,
                        levelProgress: progress.completedCount,
                        targetLevel: currentUnlockedLevel,
                      ),
                      size: Size(w, h),
                    );
                  },
                ),
              ),

              // 3. Foreground Pure Neumorphism Interface Suite
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      children: [
                        // Top Header: Stats Badge & Audio/Credits Controls
                        _buildTopBar(audio, progress),

                        const Spacer(flex: 2),

                        // Center: 3D Embossed Title Plaque
                        _buildTitleBlock(),

                        const SizedBox(height: 32),

                        // Center-Bottom: Tactile Action Console
                        _buildActionConsole(progress, currentUnlockedLevel),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Pure Neumorphic Top Bar with player stars progress and tactile audio toggle.
  Widget _buildTopBar(AudioManager audio, PlayerProgress progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sunken Player Stars & Progress Chip
        NeuContainer(
          borderRadius: 20,
          style: NeuStyle.inset,
          depth: 3.0,
          blur: 5.0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: NeuTokens.accentAmber,
              ),
              const SizedBox(width: 6),
              Text(
                '${progress.completedCount * 3}/90',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: NeuTokens.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 12,
                color: NeuTokens.bevelLight,
              ),
              const SizedBox(width: 8),
              Text(
                '${progress.completedCount}/30',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: NeuTokens.accentCyan,
                ),
              ),
            ],
          ),
        ),

        // Controls Cluster: Audio toggle & Credits icon buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeuIconButton(
              icon: audio.isMusicEnabled
                  ? Icons.music_note_rounded
                  : Icons.music_off_rounded,
              size: 40,
              iconSize: 19,
              iconColor: audio.isMusicEnabled
                  ? NeuTokens.accentAmber
                  : NeuTokens.textMuted,
              isSelected: audio.isMusicEnabled,
              accentColor: NeuTokens.accentAmber,
              onPressed: () {
                ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                audio.toggleMusic();
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
            NeuIconButton(
              icon: Icons.emoji_events_rounded,
              size: 40,
              iconSize: 19,
              iconColor: NeuTokens.textSecondary,
              onPressed: () => _navigateTo('/credits'),
            ),
          ],
        ),
      ],
    );
  }

  /// 3D Embossed Neumorphic Title Plaque.
  Widget _buildTitleBlock() {
    return NeuContainer(
      borderRadius: 28,
      style: NeuStyle.convex,
      depth: 7.0,
      blur: 14.0,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mineral Pill Chip wrapped in GlassContainer for test contract
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            borderRadius: 16,
            enableLiveBlur: false,
            backgroundColor: NeuTokens.surfaceLight,
            borderGradient: const LinearGradient(
              colors: [
                NeuTokens.accentAmberGlow,
                NeuTokens.bevelDark,
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.grain_rounded,
                  size: 15,
                  color: NeuTokens.accentAmber,
                ),
                SizedBox(width: 6),
                Text(
                  'PHYSICS SUGAR PUZZLE',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: NeuTokens.textPrimary,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Game Title: Bold 3D Embossed Typography with dual drop shadows
          Text(
            'Micin, Micin',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: NeuTokens.textPrimary,
              letterSpacing: 2.0,
              height: 1.05,
              shadows: const [
                Shadow(
                  color: NeuTokens.shadowDark,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 4.0,
                ),
                Shadow(
                  color: NeuTokens.shadowLight,
                  offset: Offset(-1.5, -1.5),
                  blurRadius: 2.5,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Teka-teki Garis & Butiran Gula',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: NeuTokens.textSecondary,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Pure Neumorphism Action Console with Tactile PLAY Button.
  Widget _buildActionConsole(PlayerProgress progress, int currentUnlockedLevel) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: GlassContainer(
        borderRadius: 24,
        enableLiveBlur: false,
        backgroundColor: NeuTokens.canvas,
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Primary Hero PLAY Button
            NeuButton(
              isPill: true,
              height: 60,
              accentColor: NeuTokens.accentAmber,
              accentGlow: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: () => _navigateTo('/levels'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PLAY',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),
                  NeuContainer(
                    borderRadius: 10,
                    style: NeuStyle.inset,
                    depth: 2.5,
                    blur: 4.0,
                    backgroundColor: NeuTokens.canvas,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      'LEVEL $currentUnlockedLevel',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeuTokens.accentAmber,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Secondary Row: LEVELS and CREDITS Neumorphic Buttons
            Row(
              children: [
                Expanded(
                  child: NeuButton(
                    height: 46,
                    borderRadius: 14,
                    onPressed: () => _navigateTo('/levels'),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 15,
                          color: NeuTokens.accentCyan,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'LEVELS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NeuTokens.textPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeuButton(
                    height: 46,
                    borderRadius: 14,
                    onPressed: () => _navigateTo('/credits'),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: NeuTokens.accentAmber,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'CREDITS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NeuTokens.textPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Campaign Progression Track
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completedCount} / $kTotalLevels Level Selesai',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NeuTokens.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  '${((progress.completedCount / kTotalLevels) * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: NeuTokens.accentAmber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Sunken Neumorphic Progress Bar
            NeuProgressBar(
              value: progress.completedCount / kTotalLevels,
              height: 7.0,
              fillColor: NeuTokens.accentAmber,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSugarGrain extends SugarParticle {
  final double radius;

  _MenuSugarGrain({
    required super.x,
    required super.y,
    super.vx,
    super.vy,
    super.color,
    required this.radius,
  }) : super(opacity: 1.0, isActive: true);
}

class _Menu2D5ScenePainter extends CustomPainter {
  final List<_MenuSugarGrain> grains;
  final int levelProgress;
  final int targetLevel;

  _Menu2D5ScenePainter({
    required this.grains,
    required this.levelProgress,
    required this.targetLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double spawnerX = size.width * 0.5;
    const double spawnerY = 50.0;
    final double cupX = size.width * 0.5;
    final double cupY = size.height - 85.0;

    _renderEmitterNozzle(canvas, Offset(spawnerX, spawnerY));
    _renderSugarGrains(canvas);
    _renderCup(canvas, Offset(cupX, cupY));
  }

  void _renderEmitterNozzle(Canvas canvas, Offset center) {
    const nozzleW = 34.0;
    const nozzleH = 14.0;
    final rect = Rect.fromCenter(center: center, width: nozzleW, height: nozzleH);

    final shadowPaint = Paint()
      ..color = NeuTokens.shadowDark
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawOval(rect.inflate(2.0), shadowPaint);

    final nozzlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          NeuTokens.surfaceLight,
          NeuTokens.surfaceDark,
        ],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6.0)), nozzlePaint);

    final rimPaint = Paint()
      ..color = NeuTokens.bevelLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6.0)), rimPaint);
  }

  void _renderSugarGrains(Canvas canvas) {
    final whitePoints = <Offset>[];
    final goldPoints = <Offset>[];

    for (final grain in grains) {
      if (!grain.isActive) continue;
      if (grain.color.r > 240 && grain.color.g > 240 && grain.color.b > 240) {
        whitePoints.add(Offset(grain.x, grain.y));
      } else {
        goldPoints.add(Offset(grain.x, grain.y));
      }
    }

    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;
    if (whitePoints.isNotEmpty) {
      canvas.drawPoints(PointMode.points, whitePoints, whitePaint);
    }

    final goldPaint = Paint()
      ..color = NeuTokens.accentAmber.withValues(alpha: 0.95)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;
    if (goldPoints.isNotEmpty) {
      canvas.drawPoints(PointMode.points, goldPoints, goldPaint);
    }
  }

  void _renderCup(Canvas canvas, Offset center) {
    const cupW = 58.0;
    const cupH = 40.0;
    final rect = Rect.fromCenter(center: center, width: cupW, height: cupH);

    // Neumorphic Ground Contact Shadows
    final shadowPaint = Paint()
      ..color = NeuTokens.shadowDark
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rect.center.dx + 2, rect.bottom + 4.0),
        width: rect.width * 1.1,
        height: 10.0,
      ),
      shadowPaint,
    );

    // Neumorphic Vessel Body
    final bodyPath = Path()
      ..moveTo(rect.left, rect.top + 3.0)
      ..lineTo(rect.left + 3.0, rect.bottom - 6.0)
      ..quadraticBezierTo(rect.left + 4.0, rect.bottom, rect.left + 10.0, rect.bottom)
      ..lineTo(rect.right - 10.0, rect.bottom)
      ..quadraticBezierTo(rect.right - 4.0, rect.bottom, rect.right - 3.0, rect.bottom - 6.0)
      ..lineTo(rect.right, rect.top + 3.0)
      ..close();

    final bodyFillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          NeuTokens.surfaceLight,
          NeuTokens.surfaceBase,
          NeuTokens.surfaceDark,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyFillPaint);

    final bodyStrokePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          NeuTokens.bevelLight,
          NeuTokens.accentAmber,
          NeuTokens.bevelDark,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(bodyPath, bodyStrokePaint);

    // Neumorphic Rim Basin
    final rimHeight = (rect.width * 0.28).clamp(8.0, 16.0);
    final rimRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.top + 2.0),
      width: rect.width,
      height: rimHeight,
    );

    final innerBasinPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 0.9,
        colors: [
          NeuTokens.surfaceDark,
          NeuTokens.canvas,
        ],
      ).createShader(rimRect)
      ..style = PaintingStyle.fill;
    canvas.drawOval(rimRect, innerBasinPaint);

    final rimStrokePaint = Paint()
      ..color = NeuTokens.accentAmber.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawOval(rimRect, rimStrokePaint);

    // Numeral on Cup Face
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$targetLevel',
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: NeuTokens.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textCenter = Offset(rect.center.dx, rect.top + (rect.height * 0.55));
    textPainter.paint(
      canvas,
      Offset(
        textCenter.dx - textPainter.width / 2,
        textCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _Menu2D5ScenePainter oldDelegate) => true;
}
