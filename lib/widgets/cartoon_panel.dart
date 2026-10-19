import 'package:flutter/material.dart';

enum CartoonPanelStyle {
  cream,
  indigo,
}

/// Cartoon styled container/dialog board with 3D bottom bevel,
/// border outline, and soft inner gradient.
class CartoonPanel extends StatelessWidget {
  final Widget child;
  final CartoonPanelStyle style;
  final double borderRadius;
  final double borderWidth;
  final double bevelDepth;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  const CartoonPanel({
    super.key,
    required this.child,
    this.style = CartoonPanelStyle.cream,
    this.borderRadius = 24.0,
    this.borderWidth = 3.0,
    this.bevelDepth = 6.0,
    this.padding = const EdgeInsets.all(20.0),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isCream = style == CartoonPanelStyle.cream;

    final Color bgColor = isCream ? const Color(0xFFFFFBEB) : const Color(0xFF231B4D);
    final Color borderColor = isCream ? const Color(0xFFD97706) : const Color(0xFF5B45A8);
    final Color shadowColor = isCream ? const Color(0xFF92400E) : const Color(0xFF140D30);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shadowColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 14.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: bevelDepth),
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}
