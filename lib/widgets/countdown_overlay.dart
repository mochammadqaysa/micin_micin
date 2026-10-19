import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';


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
          _remaining = 0; // "GO!" / "MULAI!"
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
    final Color badgeColor = isGo ? CartoonTokens.greenTop : CartoonTokens.amberTop;

    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating cartoon countdown pill banner
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badgeColor,
                      isGo ? CartoonTokens.greenBottom : CartoonTokens.amberBottom,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGo ? Icons.play_arrow_rounded : Icons.timer_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayText,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            offset: const Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tip badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Gambar garis sekarang sebelum gula mengalir!',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
