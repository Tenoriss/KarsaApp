import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'motion_pressable.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;

  const ClayCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(15),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.radius = 23,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final box = Container(
      margin: margin,
      padding: padding,
      decoration: ClayStyles.soft(
        color: backgroundColor ?? c.card,
        isDark: c.isDark,
        radius: radius,
        borderColor: borderColor,
      ),
      child: child,
    );

    if (onTap == null) return box;
    return MotionPressable(onTap: onTap, child: box);
  }
}
