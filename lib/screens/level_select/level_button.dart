import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/lock_badge.dart';

/// 3D Cartoon Level Button representing a playable level on the stage matrix.
/// - Unlocked: Cyan/blue candy 3D button face with gloss top highlight and bottom bevel.
/// - Next Playable: Raised vibrant green button with breathing pulse aura beckoning the player.
/// - Completed: Radiant golden/amber face with 3 gold stars.
/// - Locked: Deep slate 3D socket with lock badge and micro-shake on tap.
class LevelButton extends StatefulWidget {
  final int levelId;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isNextPlayable;
  final bool isMilestone;
  final String? milestoneLabel;

  const LevelButton({
    super.key,
    required this.levelId,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    this.accentColor = CartoonTokens.amberTop,
    this.isNextPlayable = false,
    this.isMilestone = false,
    this.milestoneLabel,
  });

  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  bool _isDown = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );

    if (widget.isNextPlayable) {
      _initPulse();
    }
  }

  void _initPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.35, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant LevelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNextPlayable && _pulseController == null) {
      _initPulse();
    } else if (!widget.isNextPlayable && _pulseController != null) {
      _pulseController?.dispose();
      _pulseController = null;
      _pulseAnimation = null;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pressController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.isUnlocked) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      return;
    }
    setState(() => _isDown = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.isUnlocked) {
      widget.onTap();
      return;
    }
    setState(() => _isDown = false);
    _pressController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    if (!widget.isUnlocked) return;
    setState(() => _isDown = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shakeController,
        _pressController,
        if (_pulseController != null) _pulseController!,
      ]),
      builder: (context, child) {
        // Micro-wiggle horizontal displacement on locked tap
        final double wiggleDx = _shakeController.isAnimating
            ? math.sin(_shakeController.value * math.pi * 4) *
                (1.0 - _shakeController.value) *
                5.0
            : 0.0;

        final double pulseVal = _pulseAnimation?.value ?? 0.0;

        // Visual styling parameters
        final isDepressed = _isDown;
        const double bevelDepth = 4.0;
        final double shift = isDepressed ? 3.0 : 0.0;

        Color topColor;
        Color bottomColor;
        Color shadowColor;
        Color borderColor;
        Color textColor = Colors.white;

        if (!widget.isUnlocked) {
          topColor = const Color(0xFF282050);
          bottomColor = const Color(0xFF1B143A);
          shadowColor = const Color(0xFF110C24);
          borderColor = const Color(0xFF3F3475);
          textColor = const Color(0xFF6B619E);
        } else if (widget.isCompleted) {
          topColor = CartoonTokens.amberTop;
          bottomColor = CartoonTokens.amberBottom;
          shadowColor = CartoonTokens.amberShadow;
          borderColor = Colors.white;
        } else if (widget.isNextPlayable) {
          topColor = CartoonTokens.greenTop;
          bottomColor = CartoonTokens.greenBottom;
          shadowColor = CartoonTokens.greenShadow;
          borderColor = Colors.white;
        } else {
          topColor = CartoonTokens.cyanTop;
          bottomColor = CartoonTokens.cyanBottom;
          shadowColor = CartoonTokens.cyanShadow;
          borderColor = Colors.white.withValues(alpha: 0.9);
        }

        return Transform.translate(
          offset: Offset(wiggleDx, 0),
          child: ScaleTransition(
            scale: _pressScale,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (widget.isNextPlayable)
                      BoxShadow(
                        color: CartoonTokens.greenTop.withValues(alpha: 0.35 + 0.35 * pulseVal),
                        blurRadius: 10 + 6 * pulseVal,
                        spreadRadius: 1,
                      ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.only(top: shift, bottom: bevelDepth - shift),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [topColor, bottomColor],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColor,
                      width: 2.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Top Gloss highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: widget.isUnlocked ? 0.35 : 0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Center Stage Numeral and Milestone tag
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.levelId}',
                            style: GoogleFonts.outfit(
                              fontSize: widget.isMilestone ? 20 : 18,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 0.6,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  offset: const Offset(0, 1.5),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          // Stars row for mobile game look & feel
                          if (widget.isUnlocked)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(3, (starIndex) {
                                  final isEarned = widget.isCompleted;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 11,
                                      color: isEarned
                                          ? const Color(0xFFFFD54F)
                                          : Colors.white.withValues(alpha: 0.35),
                                    ),
                                  );
                                }),
                              ),
                            ),

                          if (widget.isMilestone && widget.milestoneLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                widget.milestoneLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: widget.accentColor.withValues(
                                    alpha: widget.isUnlocked ? 1.0 : 0.50,
                                  ),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Locked State: Sunken Debossed Lock Socket
                      if (!widget.isUnlocked)
                        const Positioned.fill(
                          child: Center(
                            child: LockBadge(size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
