import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/lock_badge.dart';
import '../../widgets/neu_container.dart';

/// Pure Neumorphism node representing a playable level on the stage matrix.
/// - Unlocked: Tactile extruded convex cylinder with dual directional shadows and 3-star rating row.
/// - Next Playable: Raised high-elevation node with breathing pulse aura beckoning the player.
/// - Completed: Radiant golden illuminated rim with 3 glowing gold stars.
/// - Locked: Deeply sunken debossed socket with engraved lock badge and micro-shake on tap.
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
    this.accentColor = NeuTokens.accentAmber,
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
        final neuStyle = !widget.isUnlocked
            ? NeuStyle.inset
            : (isDepressed ? NeuStyle.inset : NeuStyle.convex);

        final depth = !widget.isUnlocked
            ? 3.5
            : (widget.isNextPlayable ? 6.5 : (isDepressed ? 2.5 : 5.0));

        final blur = !widget.isUnlocked
            ? 6.0
            : (widget.isNextPlayable ? 12.0 : (isDepressed ? 4.0 : 10.0));

        final textColor = widget.isUnlocked
            ? (widget.isCompleted
                ? NeuTokens.accentAmber
                : (widget.isNextPlayable
                    ? NeuTokens.textPrimary
                    : NeuTokens.textPrimary.withValues(alpha: 0.90)))
            : NeuTokens.textMuted;

        final border = Border.all(
          color: widget.isCompleted
              ? NeuTokens.accentAmber.withValues(alpha: 0.85)
              : (widget.isNextPlayable
                  ? NeuTokens.accentCyan.withValues(alpha: 0.45 + pulseVal * 0.45)
                  : (widget.isUnlocked
                      ? NeuTokens.bevelLight
                      : NeuTokens.bevelDark)),
          width: widget.isCompleted || widget.isNextPlayable ? 1.6 : 1.0,
        );

        return Transform.translate(
          offset: Offset(wiggleDx, 0),
          child: ScaleTransition(
            scale: _pressScale,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              behavior: HitTestBehavior.opaque,
              child: NeuContainer(
                borderRadius: 18.0,
                style: neuStyle,
                depth: depth,
                blur: blur,
                accentColor: widget.isNextPlayable
                    ? NeuTokens.accentCyan
                    : (widget.isCompleted ? NeuTokens.accentAmber : null),
                accentGlow: widget.isNextPlayable || widget.isCompleted,
                border: border,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center Stage Numeral and Milestone tag
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.levelId}',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: widget.isMilestone ? 20 : 18,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: 0.6,
                            shadows: widget.isCompleted
                                ? [
                                    Shadow(
                                      color: NeuTokens.accentAmberGlow,
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),

                        // Stars row for mobile game look & feel
                        if (widget.isUnlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
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
                                        ? NeuTokens.accentAmber
                                        : NeuTokens.textMuted.withValues(alpha: 0.35),
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
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: widget.accentColor.withValues(
                                  alpha: widget.isUnlocked ? 0.90 : 0.40,
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
        );
      },
    );
  }
}
