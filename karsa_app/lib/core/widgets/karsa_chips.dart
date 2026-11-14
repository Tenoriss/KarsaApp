import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'motion_pressable.dart';

class KarsaChips extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const KarsaChips({
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
      margin: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: options.map((option) {
            final selected = option == value;
            return Padding(
              padding: const EdgeInsets.only(right: 7),
              child: MotionPressable(
                semanticsLabel: option,
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: selected
                      ? BoxDecoration(
                          color: c.rose,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: c.rose, width: 2),
                        )
                      : ClayStyles.soft(
                          color: c.card,
                          isDark: c.isDark,
                          radius: 24,
                        ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : c.muted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
