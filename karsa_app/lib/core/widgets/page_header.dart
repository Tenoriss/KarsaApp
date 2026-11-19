import 'package:flutter/material.dart';
import '../theme/karsa_theme.dart';
import 'karsa_icons.dart';
import 'motion_pressable.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? sub;
  final VoidCallback? onBack;

  /// Aksi tambahan di kanan judul (mis. tombol mode gelap di beranda operator
  /// yang tidak memakai GreetingHeader).
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.title,
    this.sub,
    this.onBack,
    this.trailing,
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
              padding: const EdgeInsets.only(right: 6),
              child: MotionPressable(
                semanticsLabel: 'Kembali',
                onTap: onBack,
                // Area sentuh 44x44 (panduan aksesibilitas Apple/Material).
                // Sebelumnya padding 4px + ikon 20px = 28px, terlalu kecil
                // untuk jari sehingga tombol ini terasa "tidak bisa diklik".
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(
                      KarsaIcons.chevronBack,
                      size: 20,
                      color: theme.colors.ink,
                    ),
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
