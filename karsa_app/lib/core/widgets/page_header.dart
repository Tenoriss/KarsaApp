import 'package:flutter/material.dart';
import '../theme/karsa_theme.dart';
import 'karsa_icons.dart';
import 'motion_pressable.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? sub;
  final VoidCallback? onBack;

  const PageHeader({
    super.key,
    required this.title,
    this.sub,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: MotionPressable(
                semanticsLabel: 'Kembali',
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    KarsaIcons.chevronBack,
                    size: 20,
                    color: theme.colors.ink,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.text.pageTitle),
                if (sub != null && sub!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(sub!, style: theme.text.muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
