import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'motion_pressable.dart';

class KarsaButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool disabled;
  final EdgeInsetsGeometry margin;

  const KarsaButton({
    super.key,
    required this.title,
    this.onTap,
    this.disabled = false,
    this.margin = const EdgeInsets.only(top: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return MotionPressable(
      onTap: onTap,
      disabled: disabled,
      semanticsLabel: title,
      child: Container(
        width: double.infinity,
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: ClayStyles.raised(
          color: c.rose,
          isDark: c.isDark,
          radius: 20,
        ),
        alignment: Alignment.center,
        child: Text(title, style: theme.text.button),
      ),
    );
  }
}
