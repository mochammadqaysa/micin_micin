import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Reusable Modern Minimalist & Glassmorphism Container.
///
/// Supports the Dual Glass Pipeline:
/// - Mode A (`enableLiveBlur: true`): Hardware-accelerated [BackdropFilter] with
///   isolated [RepaintBoundary] for static screens and modal overlays.
/// - Mode B (`enableLiveBlur: false`): Pre-composited translucent glass gradient
///   without backdrop blur for high-frequency in-game HUDs over active particle simulation.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool enableLiveBlur;
  final List<BoxShadow>? boxShadow;
  final BoxShape shape;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = GlassTokens.radiusMedium,
    this.blurSigma = GlassTokens.blurStandard,
    this.backgroundColor = GlassTokens.surfaceLight,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.enableLiveBlur = true,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderGradient = borderGradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassTokens.borderHighlight,
            GlassTokens.borderShadow,
          ],
          stops: [0.0, 1.0],
        );

    final rradius = Radius.circular(borderRadius);
    final borderRRect = shape == BoxShape.circle
        ? null
        : BorderRadius.all(rradius);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape,
        borderRadius: borderRRect,
      ),
      child: child,
    );

    if (enableLiveBlur && blurSigma > 0) {
      if (shape == BoxShape.circle) {
        content = ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: content,
          ),
        );
      } else {
        content = ClipRRect(
          borderRadius: borderRRect!,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: content,
          ),
        );
      }
    } else {
      if (shape == BoxShape.circle) {
        content = ClipOval(child: content);
      } else {
        content = ClipRRect(borderRadius: borderRRect!, child: content);
      }
    }

    Widget decorated = CustomPaint(
      foregroundPainter: _GlassBorderPainter(
        gradient: effectiveBorderGradient,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        shape: shape,
      ),
      child: content,
    );

    if (boxShadow != null && boxShadow!.isNotEmpty) {
      decorated = Container(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: borderRRect,
          boxShadow: boxShadow,
        ),
        child: decorated,
      );
    }

    if (margin != null) {
      decorated = Padding(
        padding: margin!,
        child: decorated,
      );
    }

    return RepaintBoundary(child: decorated);
  }
}

/// Custom painter that renders a 1px crisp specular gradient border
/// along the outer edge of the glass container.
class _GlassBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderWidth;
  final double borderRadius;
  final BoxShape shape;

  _GlassBorderPainter({
    required this.gradient,
    required this.borderWidth,
    required this.borderRadius,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (borderWidth <= 0) return;

    final rect = Offset.zero & size;
    final halfWidth = borderWidth / 2;
    final insetRect = rect.deflate(halfWidth);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    if (shape == BoxShape.circle) {
      canvas.drawOval(insetRect, paint);
    } else {
      final rrect = RRect.fromRectAndRadius(
        insetRect,
        Radius.circular((borderRadius - halfWidth).clamp(0.0, double.infinity)),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.shape != shape;
  }
}
