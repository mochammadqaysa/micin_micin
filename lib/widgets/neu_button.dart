import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import 'neu_container.dart';

/// Interactive Pure Neumorphism button with physical tactile spring action.
///
/// Resting state is extruded convex with dual directional shadows.
/// Pressed state physically depresses into the canvas with inner debossed shadows
/// and subtle micro-scale feedback.
class NeuButton extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final bool isPill;
  final double depth;
  final double blur;
  final Color? accentColor;
  final bool accentGlow;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;
  final bool enabled;

  const NeuButton({
    super.key,
    this.child,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius = NeuTokens.radiusMedium,
    this.shape = BoxShape.rectangle,
    this.isPill = false,
    this.depth = NeuTokens.depthButton,
    this.blur = NeuTokens.blurButton,
    this.accentColor,
    this.accentGlow = false,
    this.isSelected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.margin,
    this.tooltip,
    this.enabled = true,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isDown = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _isDown = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _isDown = false);
    _pressController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isDown = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.isPill ? NeuTokens.radiusPill : widget.borderRadius;
    final isDepressed = _isDown || widget.isSelected;

    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: NeuContainer(
        width: widget.width,
        height: widget.height,
        borderRadius: effectiveRadius,
        shape: widget.shape,
        style: isDepressed ? NeuStyle.inset : NeuStyle.convex,
        depth: isDepressed ? widget.depth * 0.6 : widget.depth,
        blur: isDepressed ? widget.blur * 0.6 : widget.blur,
        accentColor: widget.accentColor,
        accentGlow: widget.accentGlow || (widget.isSelected && widget.accentColor != null),
        padding: widget.padding,
        margin: widget.margin,
        border: widget.accentColor != null
            ? Border.all(
                color: widget.isSelected
                    ? widget.accentColor!
                    : widget.accentColor!.withValues(alpha: 0.45),
                width: widget.isSelected ? 1.8 : 1.2,
              )
            : null,
        child: Center(
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.45,
            child: widget.child,
          ),
        ),
      ),
    );

    button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: button,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Circular or Squircle Pure Neumorphism Icon Button.
class NeuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? accentColor;
  final bool accentGlow;
  final bool isSelected;
  final BoxShape shape;
  final double borderRadius;
  final String? tooltip;
  final bool enabled;

  const NeuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.iconColor,
    this.accentColor,
    this.accentGlow = false,
    this.isSelected = false,
    this.shape = BoxShape.circle,
    this.borderRadius = NeuTokens.radiusMedium,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ??
        (isSelected && accentColor != null
            ? accentColor
            : NeuTokens.textPrimary);

    return NeuButton(
      onPressed: onPressed,
      width: size,
      height: size,
      shape: shape,
      borderRadius: borderRadius,
      depth: NeuTokens.depthButton,
      blur: NeuTokens.blurButton,
      accentColor: accentColor,
      accentGlow: accentGlow,
      isSelected: isSelected,
      tooltip: tooltip,
      enabled: enabled,
      padding: EdgeInsets.zero,
      child: Icon(
        icon,
        size: iconSize,
        color: effectiveColor,
      ),
    );
  }
}
