import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../collision/line_segment.dart';
import 'drawn_line.dart';

/// Manages interactive player touch input and active collision barrier lines.
class LineController extends StateNotifier<List<DrawnLine>> {
  LineController() : super(const []);

  List<Offset> _currentPoints = [];
  Color _currentColor = Colors.white;
  double _currentThickness = kLineThickness;
  List<LineSegment>? _cachedSegments;

  @protected
  @override
  set state(List<DrawnLine> value) {
    _cachedSegments = null;
    super.state = value;
  }

  /// Starts a new line stroke from the player's initial touch/click point.
  void onPanStart(
    Offset point, {
    Color color = Colors.white,
    double thickness = kLineThickness,
  }) {
    _currentPoints = [point];
    _currentColor = color;
    _currentThickness = thickness;

    final newLine = DrawnLine(
      points: List<Offset>.from(_currentPoints),
      color: _currentColor,
      thickness: _currentThickness,
    );

    state = [...state, newLine];
  }

  /// Appends coordinates as the player's finger or cursor drags across the screen.
  void onPanUpdate(Offset point) {
    if (_currentPoints.isEmpty) return;

    _currentPoints.add(point);
    final updatedLine = DrawnLine(
      points: List<Offset>.from(_currentPoints),
      color: _currentColor,
      thickness: _currentThickness,
    );

    state = [...state.sublist(0, state.length - 1), updatedLine];
  }

  /// Concludes the active drawing stroke.
  void onPanEnd() {
    _currentPoints = [];
  }

  /// Clears all lines from the screen and internal state.
  void clearAll() {
    _currentPoints = [];
    state = const [];
  }

  /// Aggregates all [LineSegment]s across all drawn lines for collision queries.
  ///
  /// Caches the aggregated segment list and only recalculates when lines mutate (PRN-002).
  List<LineSegment> get allSegments {
    return _cachedSegments ??= _buildAllSegments();
  }

  List<LineSegment> _buildAllSegments() {
    final segments = <LineSegment>[];
    for (final line in state) {
      segments.addAll(line.toSegments());
    }
    return segments;
  }

  /// Current list of active drawn lines on the canvas.
  List<DrawnLine> get lines => state;
}
