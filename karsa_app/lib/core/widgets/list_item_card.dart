import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/dark_color_mapper.dart';
import '../theme/karsa_theme.dart';
import 'clay_card.dart';

class ListItemCard extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String meta;
  final Color? tileColor;
  final String? status;
  final VoidCallback? onTap;

  const ListItemCard({
    super.key,
    required this.iconEmoji,
    required this.title,
    required this.meta,
    this.tileColor,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final badgeBg = DarkColorMapper.surface(
      const Color(0xFFF9E8ED),
      isDark: c.isDark,
    );

    return ClayCard(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 46),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: ClayStyles.soft(
                color: tileColor ?? const Color(0xFFF8EBEC),
                isDark: c.isDark,
                radius: 14,
              ),
              alignment: Alignment.center,
              child: Text(iconEmoji, style: const TextStyle(fontSize: 23)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.text.itemTitle),
                  const SizedBox(height: 2),
                  Text(meta, style: theme.text.smallMuted),
                ],
              ),
            ),
            if (status != null && status!.isNotEmpty) ...<Widget>[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status!, style: theme.text.badge),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
