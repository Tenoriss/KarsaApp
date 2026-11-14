import 'package:flutter/material.dart';
import '../theme/clay_styles.dart';
import '../theme/karsa_theme.dart';

class NoticeCard extends StatelessWidget {
  final String? title;
  final String body;
  final Widget? trailingChild;

  const NoticeCard({
    super.key,
    this.title,
    required this.body,
    this.trailingChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(16),
      decoration: ClayStyles.soft(
        color: const Color(0xFFFFF1E8),
        isDark: c.isDark,
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null && title!.isNotEmpty) ...<Widget>[
            Text(
              title!,
              style: TextStyle(
                color: c.rose,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
          ],
          Text(body, style: theme.text.muted),
          if (trailingChild != null) trailingChild!,
        ],
      ),
    );
  }
}
