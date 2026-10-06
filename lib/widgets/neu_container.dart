import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Elevation and lighting styles for Pure Neumorphic widgets.
enum NeuStyle {
  /// Raised convex surface: Extruded from the canvas with directional dual shadows
  /// and a subtle convex lighting gradient (Top-Left light -> Bottom-Right dark).
  convex,

  /// Raised flat surface: Extruded with directional dual shadows and flat base fill.
  flat,

  /// Sunken debossed cavity: Recessed into the canvas with inverted lighting
  /// gradient and photo-realistic inner shadows.
  inset,

  /// Soft concave depression: Inverted lighting gradient with subtle soft rim.
  concave,
}

/// The fundamental Pure Neumorphism container widget.
///
/// Features authentic directional dual shadows (@ 135°), convex/inset surface gradients,
/// and pixel-perfect inner shadow painting for sunken debossed bays and pressed states.
class NeuContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final NeuStyle style;
  final double depth;
  final double blur;
  final Color? backgroundColor;
  final Color? accentColor;
  final bool accentGlow;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final bool clipContent;

  const NeuContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius = NeuTokens.radiusMedium,
    this.shape = BoxShape.rectangle,
    this.style = NeuStyle.convex,
    this.depth = NeuTokens.depthCard,
    this.blur = NeuTokens.blurCard,
    this.backgroundColor,
    this.accentColor,
    this.accentGlow = false,
    this.border,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.alignment,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = backgroundColor ?? NeuTokens.canvas;
    final rradius = Radius.circular(borderRadius);
    final borderRRect = shape == BoxShape.circle ? null : BorderRadius.all(rradius);

    // 1. Dual Outer Shadows for Raised Surfaces (convex / flat)
    final isRaised = style == NeuStyle.convex || style == NeuStyle.flat;
    List<BoxShadow>? outerShadows;

    if (isRaised && depth > 0) {
      outerShadows = [
        // Top-Left specular highlight
        BoxShadow(
          color: NeuTokens.shadowLight,
          offset: Offset(-depth, -depth),
          blurRadius: blur,
          spreadRadius: 0.0,
        ),
        // Bottom-Right deep ambient drop shadow
        BoxShadow(
          color: NeuTokens.shadowDark,
          offset: Offset(depth, depth),
          blurRadius: blur,
          spreadRadius: 0.0,
        ),
        // Optional active accent illumination aura
        if (accentGlow && accentColor != null)
          BoxShadow(
            color: accentColor!.withValues(alpha: 0.35),
            offset: Offset.zero,
            blurRadius: blur * 1.4,
            spreadRadius: 1.0,
          ),
      ];
    }

    // 2. Surface Lighting Gradient
    Gradient? surfaceGradient;
    Color? solidColor;

    switch (style) {
      case NeuStyle.convex:
        surfaceGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeuTokens.surfaceLight,
            NeuTokens.surfaceBase,
            NeuTokens.surfaceDark,
          ],
          stops: const [0.0, 0.45, 1.0],
        );
        break;
      case NeuStyle.flat:
        solidColor = baseColor;
        break;
      case NeuStyle.inset:
      case NeuStyle.concave:
        surfaceGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeuTokens.surfaceDark,
            NeuTokens.surfaceBase,
            NeuTokens.surfaceLight.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.55, 1.0],
        );
        break;
    }

    // 3. Assemble Inner Content with Optional Inset Painter
    Widget body = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      child: child,
    );

    if (style == NeuStyle.inset) {
      body = CustomPaint(
        foregroundPainter: NeuInnerShadowPainter(
          borderRadius: borderRadius,
          shape: shape,
          depth: math.max(depth * 0.7, 2.5),
          blur: math.max(blur * 0.65, 4.0),
          shadowColor: NeuTokens.insetDark,
          highlightColor: NeuTokens.insetLight,
        ),
        child: body,
      );
    }

    if (clipContent) {
      if (shape == BoxShape.circle) {
        body = ClipOval(child: body);
      } else {
        body = ClipRRect(borderRadius: borderRRect!, child: body);
      }
    }

    // 4. Outer Chassis with Box Decoration
    Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: solidColor,
        gradient: surfaceGradient,
        shape: shape,
        borderRadius: borderRRect,
        boxShadow: outerShadows,
        border: border ??
            Border.all(
              color: isRaised ? NeuTokens.bevelLight : NeuTokens.bevelDark,
              width: 1.0,
            ),
      ),
      child: body,
    );

    if (margin != null) {
      box = Padding(padding: margin!, child: box);
    }

    return RepaintBoundary(child: box);
  }
}

/// Hardware-accelerated custom painter that renders authentic directional
/// inner shadows inside of an RRect or Circle boundary.
class NeuInnerShadowPainter extends CustomPainter {
  final double borderRadius;
  final BoxShape shape;
  final double depth;
  final double blur;
  final Color shadowColor;
  final Color highlightColor;

  NeuInnerShadowPainter({
    required this.borderRadius,
    required this.shape,
    required this.depth,
    required this.blur,
    required this.shadowColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = shape == BoxShape.circle
        ? RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.5))
        : RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.save();
    canvas.clipRRect(rrect);

    // 1. Dark Inner Shadow (Top-Left inside)
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final outerInflated = rect.inflate(depth * 4);
    final darkHole = rrect.shift(Offset(depth, depth));

    final shadowPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(outerInflated)
      ..addRRect(darkHole);

    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Light Inner Highlight (Bottom-Right inside)
    final highlightPaint = Paint()
      ..color = highlightColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final lightHole = rrect.shift(Offset(-depth * 0.8, -depth * 0.8));

    final highlightPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(outerInflated)
      ..addRRect(lightHole);

    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NeuInnerShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.shape != shape ||
        oldDelegate.depth != depth ||
        oldDelegate.blur != blur ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}
