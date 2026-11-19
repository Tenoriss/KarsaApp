import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'karsa_icons.dart';
import 'motion_pressable.dart';

/// Kartu satu metode pengerjaan (pilihan ganda / esai). Dipakai bersama oleh
/// detail tugas dan detail latihan supaya keduanya terlihat sama.
class MethodCard extends StatelessWidget {
  final String icon;
  final String title;
  final String meta;
  final String? badge;
  final String actionLabel;
  final VoidCallback onTap;

  const MethodCard({
    required this.icon,
    required this.title,
    required this.meta,
    required this.actionLabel,
    required this.onTap,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return MotionPressable(
      semanticsLabel: '$title, $actionLabel',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ClayStyles.soft(
          color: c.card,
          isDark: c.isDark,
          radius: 18,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: ClayStyles.raised(
                color: c.rose,
                isDark: c.isDark,
                radius: 21,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(title, style: theme.text.itemTitle),
                      if (badge != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            badge!,
                            style: TextStyle(
                              color: c.rose,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(meta, style: theme.text.smallMuted),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              actionLabel,
              style: TextStyle(
                color: c.rose,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Icon(KarsaIcons.chevronForward, size: 16, color: c.rose),
          ],
        ),
      ),
    );
  }
}
