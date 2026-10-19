import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import 'cartoon_button.dart';

/// Chunky 3D Circular Cartoon Icon Button with bevel base, glossy sheen, and bouncy tap feel.
class CartoonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final CartoonButtonVariant variant;
  final double size;
  final double iconSize;
  final String? tooltip;
  final Color? iconColor;

  const CartoonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = CartoonButtonVariant.cyan,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.tooltip,
    this.iconColor,
  });

  @override
  State<CartoonIconButton> createState() => _CartoonIconButtonState();
}

class _CartoonIconButtonState extends State<CartoonIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  (Color, Color, Color) get _colors {
    switch (widget.variant) {
      case CartoonButtonVariant.green:
        return (CartoonTokens.greenTop, CartoonTokens.greenBottom, CartoonTokens.greenShadow);
      case CartoonButtonVariant.amber:
        return (CartoonTokens.amberTop, CartoonTokens.amberBottom, CartoonTokens.amberShadow);
      case CartoonButtonVariant.cyan:
        return (CartoonTokens.cyanTop, CartoonTokens.cyanBottom, CartoonTokens.cyanShadow);
      case CartoonButtonVariant.coral:
        return (CartoonTokens.coralTop, CartoonTokens.coralBottom, CartoonTokens.coralShadow);
      case CartoonButtonVariant.purple:
        return (CartoonTokens.purpleTop, CartoonTokens.purpleBottom, CartoonTokens.purpleShadow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (topColor, bottomColor, shadowColor) = _colors;
    const double depth = 4.0;
    final double currentShift = _isPressed ? depth : 0.0;
    final double totalHeight = widget.size + depth;

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: SizedBox(
          width: widget.size,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. 3D Shadow Base
              Positioned(
                top: depth,
                left: 0,
                width: widget.size,
                height: widget.size,
                child: Container(
                  decoration: BoxDecoration(
                    color: shadowColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Button Face Layer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                top: currentShift,
                left: 0,
                width: widget.size,
                height: widget.size,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [topColor, bottomColor],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 1.8,
                    ),
                  ),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        // Specular Gloss (Upper half)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: widget.size * 0.45,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.50),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Icon in center
                        Center(
                          child: Icon(
                            widget.icon,
                            size: widget.iconSize,
                            color: widget.iconColor ?? Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.50),
                                offset: const Offset(0, 1.5),
                                blurRadius: 2.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }
}
