import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'neu_container.dart';

/// Pure Neumorphism debossed lock badge for locked game nodes.
class LockBadge extends StatelessWidget {
  final double size;

  const LockBadge({
    super.key,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      width: size + 10.0,
      height: size + 10.0,
      shape: BoxShape.circle,
      style: NeuStyle.inset,
      depth: 3.0,
      blur: 5.0,
      child: Center(
        child: Icon(
          Icons.lock_rounded,
          size: size,
          color: NeuTokens.textMuted,
        ),
      ),
    );
  }
}
