import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Provides bi-directional scaling and translation between device screen pixels
/// and the 400x700 Unified Virtual Coordinate space (ADR 0002).
class VirtualCoordinateAdapter {
  const VirtualCoordinateAdapter._();

  /// Computes the uniform scale factor to fit 400x700 inside [viewportSize]
  /// preserving aspect ratio with letterboxing.
  static double computeScale(Size viewportSize) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) return 1.0;
    final scaleX = viewportSize.width / kVirtualWidth;
    final scaleY = viewportSize.height / kVirtualHeight;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  /// Computes the centering offset (dx, dy) for letterboxing inside [viewportSize].
  static Offset computeOffset(Size viewportSize, double scale) {
    final dx = (viewportSize.width - kVirtualWidth * scale) / 2.0;
    final dy = (viewportSize.height - kVirtualHeight * scale) / 2.0;
    return Offset(dx, dy);
  }

  /// Converts a physical screen coordinate [screenPoint] to virtual (400x700) space.
  ///
  /// Clamps coordinates to the valid canvas boundaries [0.0..kVirtualWidth]
  /// and [0.0..kVirtualHeight].
  static Offset screenToVirtual(Offset screenPoint, Size viewportSize) {
    final scale = computeScale(viewportSize);
    if (scale <= 0) return Offset.zero;
    final offset = computeOffset(viewportSize, scale);
    final vx = (screenPoint.dx - offset.dx) / scale;
    final vy = (screenPoint.dy - offset.dy) / scale;
    return Offset(
      vx.clamp(0.0, kVirtualWidth),
      vy.clamp(0.0, kVirtualHeight),
    );
  }

  /// Converts a virtual coordinate [virtualPoint] to physical screen pixel space.
  static Offset virtualToScreen(Offset virtualPoint, Size viewportSize) {
    final scale = computeScale(viewportSize);
    final offset = computeOffset(viewportSize, scale);
    return Offset(
      virtualPoint.dx * scale + offset.dx,
      virtualPoint.dy * scale + offset.dy,
    );
  }
}
