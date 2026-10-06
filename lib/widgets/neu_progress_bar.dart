import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'neu_container.dart';

/// Pure Neumorphism Progress Bar.
///
/// Features a deeply sunken debossed trough (`NeuStyle.inset`) housing an
/// extruded tactile liquid gauge (`NeuStyle.convex`) with specular highlights
/// and smooth interpolation.
class NeuProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final double? width;
  final Color fillColor;
  final Color? trackColor;
  final String? label;
  final bool showPercentage;

  const NeuProgressBar({
    super.key,
    required this.value,
    this.height = 18.0,
    this.width,
    this.fillColor = NeuTokens.accentAmber,
    this.trackColor,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRatio = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = width ?? constraints.maxWidth;
        final fillWidth = totalWidth * clampedRatio;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null || showPercentage)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0, left: 4.0, right: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NeuTokens.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    if (showPercentage)
                      Text(
                        '${(clampedRatio * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: fillColor,
                        ),
                      ),
                  ],
                ),
              ),

            // Sunken Neumorphic Track Trough
            NeuContainer(
              width: totalWidth,
              height: height,
              borderRadius: height * 0.5,
              style: NeuStyle.inset,
              depth: 3.5,
              blur: 6.0,
              backgroundColor: trackColor ?? NeuTokens.canvas,
              padding: const EdgeInsets.all(2.5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: fillWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        fillColor.withValues(alpha: 0.95),
                        fillColor,
                        fillColor.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: fillColor.withValues(alpha: 0.45),
                        offset: const Offset(0, 1),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
