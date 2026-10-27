import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../core/pixel_terrain_tokens.dart';

/// Animated preparation countdown overlay shown when a stage begins or restarts.
/// Gives players a few seconds to inspect the board and draw initial barrier lines
/// before sugar particles start flowing.
class CountdownOverlay extends StatefulWidget {
  final VoidCallback onFinished;
  final int totalSeconds;

  const CountdownOverlay({
    super.key,
    required this.onFinished,
    this.totalSeconds = 3,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late final AnimationController _popController;
  late final Animation<double> _scaleAnimation;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_popController);

    _popController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;

      if (_remaining > 1) {
        setState(() {
          _remaining--;
        });
        HapticFeedback.selectionClick();
        _popController.reset();
        _popController.forward();
      } else if (_remaining == 1) {
        setState(() {
          _remaining = 0; // "MULAI!"
        });
        HapticFeedback.mediumImpact();
        _popController.reset();
        _popController.forward();
      } else {
        _finish();
      }
    });
  }

  void _finish() {
    if (_isComplete) return;
    _isComplete = true;
    _timer?.cancel();
    widget.onFinished();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return const SizedBox.shrink();

    final isGo = _remaining == 0;
    final String displayText = isGo ? 'MULAI!' : '$_remaining';

    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Pixel Zen countdown badge
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: PixelBox(
                logicalWidth: 36,
                logicalHeight: 12,
                style: isGo ? PixelTerrainTokens.mossBoxStyle : PixelTerrainTokens.tealBoxStyle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGo ? Icons.play_arrow_rounded : Icons.timer_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayText,
                        style: PixelText.mulmaru(
                          fontSize: 24,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tip badge
            PixelBox(
              logicalWidth: 70,
              logicalHeight: 8,
              style: PixelTerrainTokens.slateBoxStyle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Text(
                  'Gambar garis sekarang sebelum gula mengalir!',
                  style: PixelText.mulmaru(
                    fontSize: 10,
                    color: PixelTerrainTokens.sand.withValues(alpha: 0.95),
                    letterSpacing: 0.5,
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
