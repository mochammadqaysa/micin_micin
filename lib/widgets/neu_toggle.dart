import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import 'neu_container.dart';

/// Pure Neumorphism Interactive Toggle Switch.
///
/// Features a debossed sunken stadium track with a sliding convex tactile knob
/// that glows with energetic mobile game accenting when toggled active.
class NeuToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final IconData? activeIcon;
  final IconData? inactiveIcon;

  const NeuToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 62.0,
    this.height = 34.0,
    this.activeColor = NeuTokens.accentAmber,
    this.activeIcon,
    this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final knobSize = height - 8.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: NeuContainer(
        width: width,
        height: height,
        borderRadius: height * 0.5,
        style: NeuStyle.inset,
        depth: 3.0,
        blur: 5.0,
        accentColor: value ? activeColor : null,
        accentGlow: value,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: NeuContainer(
            width: knobSize,
            height: knobSize,
            shape: BoxShape.circle,
            style: NeuStyle.convex,
            depth: 3.5,
            blur: 5.0,
            accentColor: value ? activeColor : null,
            accentGlow: value,
            border: Border.all(
              color: value ? activeColor : NeuTokens.bevelLight,
              width: 1.0,
            ),
            child: Center(
              child: Icon(
                value
                    ? (activeIcon ?? Icons.check_rounded)
                    : (inactiveIcon ?? Icons.close_rounded),
                size: knobSize * 0.55,
                color: value ? activeColor : NeuTokens.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
