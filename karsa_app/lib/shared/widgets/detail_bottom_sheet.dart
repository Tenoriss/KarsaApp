import 'package:flutter/material.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';

class DetailBottomSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const DetailBottomSheet({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Positioned.fill(
      child: Container(
        color: const Color(0x61182A3A), // rgba(24,42,58,0.38)
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: const SizedBox.expand(),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
                decoration: ClayStyles.soft(
                  color: c.bg,
                  isDark: c.isDark,
                  customRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      decoration: BoxDecoration(
                        color: DarkColorMapper.surface(
                          const Color(0xFFD8C9C5),
                          isDark: c.isDark,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
