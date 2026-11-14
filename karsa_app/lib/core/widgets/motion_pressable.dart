import 'package:flutter/material.dart';

class MotionPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool disabled;
  final String? semanticsLabel;

  const MotionPressable({
    super.key,
    required this.child,
    this.onTap,
    this.disabled = false,
    this.semanticsLabel,
  });

  @override
  State<MotionPressable> createState() => _MotionPressableState();
}

class _MotionPressableState extends State<MotionPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.disabled || widget.onTap == null) return;
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final activeTap = widget.disabled ? null : widget.onTap;

    Widget content = AnimatedScale(
      scale: (!reduceMotion && _pressed && activeTap != null) ? 0.965 : 1.0,
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: Opacity(
        opacity: widget.disabled ? 0.45 : 1.0,
        child: widget.child,
      ),
    );

    if (activeTap != null || widget.disabled) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: activeTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: MouseRegion(
          cursor: activeTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: content,
        ),
      );
    }

    if (widget.semanticsLabel != null || activeTap != null) {
      content = Semantics(
        button: activeTap != null,
        enabled: !widget.disabled,
        label: widget.semanticsLabel,
        child: content,
      );
    }

    return content;
  }
}
