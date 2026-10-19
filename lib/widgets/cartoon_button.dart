import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

enum CartoonButtonVariant {
  green,
  amber,
  cyan,
  coral,
  purple,
}

/// Juicy 3D Cartoon Push Button with tactile depression, specular gloss shine,
/// and squash & stretch spring physics (game-feel).
class CartoonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CartoonButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final double? width;
  final double fontSize;
  final double bevelDepth;
  final double borderRadius;
  final double paddingHorizontal;

  const CartoonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CartoonButtonVariant.green,
    this.leading,
    this.trailing,
    this.height = 54.0,
    this.width,
    this.fontSize = 17.0,
    this.bevelDepth = 5.0,
    this.borderRadius = 22.0,
    this.paddingHorizontal = 16.0,
  });

  @override
  State<CartoonButton> createState() => _CartoonButtonState();
}

class _CartoonButtonState extends State<CartoonButton>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
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
    final double depth = widget.bevelDepth;
    final double currentShift = _isPressed ? depth : 0.0;

    return AnimatedBuilder(
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
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: shadowColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 6.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(
              top: currentShift,
              bottom: depth - currentShift,
            ),
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 1.8,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius - 1.8),
              child: Stack(
                children: [
                  // Specular Gloss Highlight (Top half)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: (widget.height * 0.46),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.borderRadius),
                          topRight: Radius.circular(widget.borderRadius),
                        ),
                      ),
                    ),
                  ),

                  // Button Content (Icon & Text)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: widget.paddingHorizontal),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leading != null) ...[
                            widget.leading!,
                            const SizedBox(width: 5.0),
                          ],
                          Flexible(
                            child: Text(
                              widget.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    offset: const Offset(0, 2),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.trailing != null) ...[
                            const SizedBox(width: 5.0),
                            widget.trailing!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
