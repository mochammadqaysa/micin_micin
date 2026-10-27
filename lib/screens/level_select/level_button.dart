import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../../core/pixel_terrain_tokens.dart';
import '../../widgets/lock_badge.dart';

/// Pixel-art Level Button representing a playable level on the stage matrix.
/// - Unlocked / Next Playable: Moss/Sage face with stepped pixel border.
/// - Completed: Radiant Sand face with Sage accents.
/// - Locked: Deep Slate socket with lock icon.
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
    this.accentColor = PixelTerrainTokens.sage,
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
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.isUnlocked) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      return;
    }
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.isUnlocked) {
      widget.onTap();
      return;
    }
    _pressController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    if (!widget.isUnlocked) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shakeController,
        _pressController,
      ]),
      builder: (context, child) {
        final double wiggleDx = _shakeController.isAnimating
            ? math.sin(_shakeController.value * math.pi * 4) *
                (1.0 - _shakeController.value) *
                5.0
            : 0.0;

        PixelShapeStyle style;
        Color textColor;

        if (!widget.isUnlocked) {
          style = PixelTerrainTokens.slateBoxStyle;
          textColor = Colors.white.withValues(alpha: 0.25);
        } else if (widget.isCompleted) {
          style = PixelTerrainTokens.sandBoxStyle;
          textColor = PixelTerrainTokens.slate;
        } else if (widget.isNextPlayable) {
          style = PixelTerrainTokens.mossBoxStyle;
          textColor = Colors.white;
        } else {
          style = PixelTerrainTokens.tealBoxStyle;
          textColor = Colors.white;
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
              child: PixelBox(
                logicalWidth: 14,
                logicalHeight: 14,
                width: 58,
                height: 58,
                style: style,
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.levelId}',
                            style: PixelText.mulmaru(
                              fontSize: widget.isMilestone ? 16 : 14,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (widget.isMilestone && widget.milestoneLabel != null)
                            Text(
                              widget.milestoneLabel!,
                              style: PixelText.mulmaru(
                                fontSize: 8,
                                color: textColor,
                              ),
                            ),
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
                                      size: 10,
                                      color: isEarned
                                          ? PixelTerrainTokens.sand
                                          : Colors.white.withValues(alpha: 0.30),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
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
