import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'motion_pressable.dart';

class KarsaSegmentTabs extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const KarsaSegmentTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(4),
      decoration: ClayStyles.inset(
        color: const Color(0xFFF5ECEA),
        isDark: c.isDark,
        radius: 20,
      ),
      child: Row(
        children: options.map((opt) {
          final active = opt == value;
          return Expanded(
            child: MotionPressable(
              semanticsLabel: opt,
              onTap: () => onChanged(opt),
              child: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: active
                    ? ClayStyles.soft(
                        color: const Color(0xFFFFFDFB),
                        isDark: c.isDark,
                        radius: 16,
                      )
                    : null,
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? c.rose : c.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
