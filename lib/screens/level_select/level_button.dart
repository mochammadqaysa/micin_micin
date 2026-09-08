import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/lock_badge.dart';

/// Zen circular/beveled node representing a playable level on the stage matrix.
/// - Unlocked: Translucent elevated basalt pebble (#191F26) with crisp Outfit numerals.
/// - Next Playable: Continuous tranquil breathing pulse glow beckoning the player.
/// - Completed: Delicate radiant gold completion pip and illuminated rim.
/// - Locked: Deeply recessed slate (#12161A) with tactile micro-shake on tap.
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
    this.accentColor = const Color(0xFFFFD54F),
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
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.isNextPlayable) {
      _initPulse();
    }
  }

  void _initPulse() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.25, end: 0.85).animate(
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
    _pulseController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isUnlocked) {
      _shakeController.forward(from: 0.0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isUnlocked
        ? (widget.isNextPlayable
            ? const Color(0xFF1C242C)
            : const Color(0xFF161C22))
        : const Color(0xFF12161A);

    final borderColor = widget.isCompleted
        ? widget.accentColor.withValues(alpha: 0.80)
        : (widget.isNextPlayable
            ? widget.accentColor.withValues(alpha: 0.60)
            : (widget.isUnlocked
                ? const Color(0xFF28323D)
                : const Color(0xFF192026)));

    final textColor = widget.isUnlocked
        ? (widget.isCompleted
            ? widget.accentColor
            : (widget.isNextPlayable
                ? const Color(0xFFFFFFFF)
                : const Color(0xFFE2E8F0)))
        : const Color(0xFF475569).withValues(alpha: 0.45);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _shakeController,
        if (_pulseController != null) _pulseController!,
      ]),
      builder: (context, child) {
        // Micro-wiggle horizontal displacement: 4px dampening sine
        final double wiggleDx = _shakeController.isAnimating
            ? math.sin(_shakeController.value * math.pi * 4) *
                (1.0 - _shakeController.value) *
                4.0
            : 0.0;

        final double pulseAlpha = _pulseAnimation?.value ?? 0.0;

        return Transform.translate(
          offset: Offset(wiggleDx, 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: widget.accentColor.withValues(alpha: 0.12),
              highlightColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isNextPlayable
                        ? widget.accentColor.withValues(alpha: 0.35 + pulseAlpha * 0.45)
                        : borderColor,
                    width: widget.isCompleted || widget.isNextPlayable ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (widget.isCompleted)
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    if (widget.isNextPlayable)
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.08 + pulseAlpha * 0.14),
                        blurRadius: 12 + pulseAlpha * 6,
                        spreadRadius: pulseAlpha * 1.5,
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Faint radial mineral glow inside unlocked node
                    if (widget.isUnlocked)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: RadialGradient(
                              center: const Alignment(0, -0.4),
                              radius: 0.85,
                              colors: [
                                (widget.isCompleted ? widget.accentColor : Colors.white)
                                    .withValues(alpha: widget.isCompleted ? 0.06 : 0.03),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Center Stage Numeral and optional milestone tag
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.levelId}',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: widget.isMilestone ? 19 : 17,
                            fontWeight: widget.isCompleted || widget.isNextPlayable
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: textColor,
                            letterSpacing: 0.5,
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
                                fontWeight: FontWeight.w500,
                                color: widget.accentColor.withValues(
                                  alpha: widget.isUnlocked ? 0.75 : 0.35,
                                ),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Delicate Completion Pip (bottom center mineral pip)
                    if (widget.isCompleted && !widget.isMilestone)
                      Positioned(
                        bottom: 6,
                        child: Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.accentColor,
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withValues(alpha: 0.60),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Subtle Lock Badge for locked nodes
                    if (!widget.isUnlocked)
                      const Positioned(
                        child: Opacity(
                          opacity: 0.35,
                          child: LockBadge(size: 14),
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

