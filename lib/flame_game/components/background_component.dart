import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show
        Canvas,
        Color,
        Offset,
        Paint,
        PaintingStyle,
        Rect,
        TextDirection,
        TextPainter,
        TextSpan;
import 'package:pixel_ui/pixel_ui.dart';
import '../../core/constants.dart';

/// Renders authentic flat solid background colors per active stage theme (REQ-003, AC-003).
///
/// Overhauled from Pixel Koi Zen elevation contours and mineral stippling to authentic
/// solid color canvas matching Bart Bonte's decompiled `backkleur` palette.
///
/// Features:
/// - Clean, flat solid background.
/// - Zero-allocation hot path via pre-cached [Paint] and [Rect].
/// - Optional diegetic typography rendered cleanly without stippling or contour shelves.
class BackgroundFlameComponent extends Component {
  Color backgroundColor;
  String? canvasLabel;
  Color canvasLabelColor;
  double canvasLabelOpacity;
  Offset canvasLabelPositionVirtual;

  // Zero-allocation rendering cache
  late final Paint _bgPaint = Paint()..style = PaintingStyle.fill;
  static const Rect _virtualCanvasRect =
      Rect.fromLTWH(0, 0, kVirtualWidth, kVirtualHeight);

  // Cached TextPainter for diegetic stage label
  TextPainter? _cachedLabelPainter;
  String? _lastLabel;
  Color? _lastLabelColor;
  double? _lastLabelOpacity;

  BackgroundFlameComponent({
    required this.backgroundColor,
    this.canvasLabel,
    required this.canvasLabelColor,
    this.canvasLabelOpacity = 0.22,
    this.canvasLabelPositionVirtual = const Offset(280.0, 640.0),
  });

  /// Retained for backwards compatibility across game lifecycle.
  void setParallax(double x, double y) {}

  @override
  int get priority => -10;

  @override
  void render(Canvas canvas) {
    // 1. Solid flat background fill (Zero-allocation hot path)
    _bgPaint.color = backgroundColor;
    canvas.drawRect(_virtualCanvasRect, _bgPaint);

    // 2. Diegetic stage typography (if label specified)
    _renderLabel(canvas);
  }

  void _renderLabel(Canvas canvas) {
    if (canvasLabel == null || canvasLabel!.isEmpty) return;

    if (_cachedLabelPainter == null ||
        _lastLabel != canvasLabel ||
        _lastLabelColor != canvasLabelColor ||
        _lastLabelOpacity != canvasLabelOpacity) {
      _lastLabel = canvasLabel;
      _lastLabelColor = canvasLabelColor;
      _lastLabelOpacity = canvasLabelOpacity;

      _cachedLabelPainter = TextPainter(
        text: TextSpan(
          text: canvasLabel,
          style: PixelText.mulmaru(
            fontSize: 28.0,
            color: canvasLabelColor.withValues(
              alpha: canvasLabelOpacity.clamp(0.0, 1.0),
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    _cachedLabelPainter?.paint(canvas, canvasLabelPositionVirtual);
  }
}
