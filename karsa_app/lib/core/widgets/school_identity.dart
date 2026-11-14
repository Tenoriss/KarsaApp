import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/clay_styles.dart';
import '../theme/dark_color_mapper.dart';
import '../theme/karsa_theme.dart';

class SchoolIdentity extends StatelessWidget {
  final bool compact;

  const SchoolIdentity({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 5 : 18),
      padding: EdgeInsets.symmetric(
        horizontal: 11,
        vertical: compact ? 6 : 8,
      ),
      decoration: ClayStyles.soft(
        color: c.card,
        isDark: c.isDark,
        radius: 18,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: DarkColorMapper.surface(Colors.white, isDark: c.isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              AppConstants.assetSchoolLogo,
              width: 33,
              height: 33,
              fit: BoxFit.contain,
              semanticLabel: 'Logo SD Karitas Purwokerto',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppConstants.schoolName,
                  style: TextStyle(
                    color: c.ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.65,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.schoolCaption,
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
