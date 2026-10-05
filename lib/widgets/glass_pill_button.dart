import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'glass_container.dart';

/// Modern Minimalist & Glassmorphism Tactile Pill Button.
///
/// Features:
/// - 50ms squash down to 0.92 on pointer press
/// - 220ms spring pop overshoot to 1.08 and settling to 1.00 on release ([Curves.easeOutBack])
/// - 1px specular gradient border with luminous accent glow
/// - Seamless integration with the Dual Glass Pipeline
class GlassPillButton extends StatefulWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final Color accentGlow;
  final bool isPrimary;
  final double height;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final bool enableLiveBlur;
  final VoidCallback? onPlaySound;

  const GlassPillButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.accentGlow = GlassTokens.neonCyan,
    this.isPrimary = false,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.textStyle,
    this.enableLiveBlur = true,
    this.onPlaySound,
  });

  @override
  State<GlassPillButton> createState() => _GlassPillButtonState();
}

class _GlassPillButtonState extends State<GlassPillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController;
  late final Animation<double> _popAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    // Spring pop: shoots from 0.92 past 1.00 up to 1.08, then settles to 1.00
    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.00)
            .chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 40,
      ),
    ]).animate(_popController);
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    setState(() => _isPressed = true);
  }

  void _onPointerUp(PointerUpEvent _) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _popController.forward(from: 0.0);
    }
  }

  void _onPointerCancel(PointerCancelEvent _) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTap() {
    widget.onPlaySound?.call();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderGradient = widget.isPrimary
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.accentGlow.withValues(alpha: 0.70),
              GlassTokens.borderHighlight,
              widget.accentGlow.withValues(alpha: 0.20),
            ],
            stops: const [0.0, 0.45, 1.0],
          )
        : null;

    final effectiveGlow = widget.isPrimary
        ? [
            BoxShadow(
              color: widget.accentGlow.withValues(alpha: 0.25),
              blurRadius: 18.0,
              spreadRadius: 1.0,
            ),
          ]
        : null;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _popAnimation,
          builder: (context, child) {
            double currentScale = 1.0;
            if (_isPressed) {
              currentScale = 0.92;
            } else if (_popController.isAnimating) {
              currentScale = _popAnimation.value;
            }

            return Transform.scale(
              scale: currentScale,
              child: child,
            );
          },
          child: GlassContainer(
            borderRadius: GlassTokens.radiusPill,
            blurSigma: GlassTokens.blurStandard,
            backgroundColor: widget.isPrimary
                ? GlassTokens.surfaceElevated
                : GlassTokens.surfaceLight,
            borderGradient: effectiveBorderGradient,
            borderWidth: widget.isPrimary ? 1.5 : 1.0,
            padding: widget.padding,
            boxShadow: effectiveGlow,
            enableLiveBlur: widget.enableLiveBlur,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: widget.textStyle ??
                      GoogleFonts.outfit(
                        color: GlassTokens.textSpecular,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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

