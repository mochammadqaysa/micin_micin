import 'package:flutter/material.dart';

/// Authentic Bart Bonte circular victory dialog ("NEXT" button / spr_buttonnext).
///
/// Features:
/// - Smooth modal scrim fade-in.
/// - Centered minimalist circular button with "NEXT" typography (`Key('spr_buttonnext')`).
/// - Tactile responsive scale feedback on touch.
/// - Waits for explicit user tap to transition to the next level.
class VictoryOverlay extends StatefulWidget {
  final int levelId;
  final bool isLastLevel;
  final VoidCallback onNext;

  const VictoryOverlay({
    super.key,
    required this.levelId,
    this.isLastLevel = false,
    required this.onNext,
  });

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.isLastLevel ? 'FINISH' : 'NEXT';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Semantics(
              button: true,
              label: label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) {
                  setState(() => _pressed = false);
                  widget.onNext();
                },
                onTapCancel: () => setState(() => _pressed = false),
                child: AnimatedScale(
                  scale: _pressed ? 0.90 : 1.0,
                  duration: const Duration(milliseconds: 70),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    key: const Key('spr_buttonnext'),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        label,
                        key: const Key('victory_next_button'),
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

