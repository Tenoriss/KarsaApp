import 'package:flutter/material.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/round_icon_button.dart';

class GreetingHeader extends StatelessWidget {
  final String avatarText;
  final bool avatarIsLetter;
  final String eyebrow;
  final String userName;
  final String subtitle;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenNotifications;

  const GreetingHeader({
    super.key,
    required this.avatarText,
    this.avatarIsLetter = false,
    required this.eyebrow,
    required this.userName,
    required this.subtitle,
    required this.isDark,
    required this.badgeCount,
    required this.onToggleTheme,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: ClayStyles.soft(
              color: const Color(0xFFF0E0E5),
              isDark: c.isDark,
              radius: 26,
            ),
            alignment: Alignment.center,
            child: Text(
              avatarText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: avatarIsLetter ? FontWeight.w800 : FontWeight.w400,
                color: c.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(eyebrow, style: theme.text.smallMuted),
                Text(userName, style: theme.text.name),
                Text(subtitle, style: theme.text.smallMuted),
              ],
            ),
          ),
          RoundIconButton(
            icon: isDark ? KarsaIcons.sunnyOutline : KarsaIcons.moonOutline,
            semanticsLabel: isDark ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
            onTap: onToggleTheme,
          ),
          const SizedBox(width: 8),
          RoundIconButton(
            icon: KarsaIcons.notificationsOutline,
            semanticsLabel: 'Pengumuman',
            badgeCount: badgeCount,
            onTap: onOpenNotifications,
          ),
        ],
      ),
    );
  }
}
