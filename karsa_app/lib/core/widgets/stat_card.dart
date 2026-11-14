import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';
import 'clay_card.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String desc;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.desc,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return ClayCard(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: ClayStyles.raised(
                color: color,
                isDark: c.isDark,
                radius: 20,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label, style: theme.text.smallMuted),
                  Text(value, style: theme.text.statNumber),
                  Text(desc, style: theme.text.smallMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WideStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String desc;
  final Color color;
  final VoidCallback? onTap;

  const WideStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.desc,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: icon,
      label: label,
      value: value,
      desc: desc,
      color: color,
      onTap: onTap,
    );
  }
}
