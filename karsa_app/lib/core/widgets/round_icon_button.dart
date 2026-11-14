import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'motion_pressable.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticsLabel;
  final int badgeCount;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticsLabel,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return MotionPressable(
      semanticsLabel: semanticsLabel,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: ClayStyles.soft(
              color: c.card,
              isDark: c.isDark,
              radius: 21,
              borderColor: c.line,
              borderWidth: 1,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: c.rose, size: 20),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -3,
              top: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: c.pink,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
