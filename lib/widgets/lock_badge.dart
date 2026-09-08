import 'package:flutter/material.dart';

/// Small visual lock badge overlaid on locked level tiles.
class LockBadge extends StatelessWidget {
  final double size;

  const LockBadge({
    super.key,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF616161),
          width: 1.0,
        ),
      ),
      child: Icon(
        Icons.lock_rounded,
        size: size,
        color: const Color(0xFFBDBDBD),
      ),
    );
  }
}
