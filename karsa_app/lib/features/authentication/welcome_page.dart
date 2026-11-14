import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/school_identity.dart';
import '../../models/demo_account.dart';
import '../../models/user_role.dart';
import '../../providers/app_state.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const List<UserRole> _orderedRoles = <UserRole>[
    UserRole.wali,
    UserRole.guru,
    UserRole.orangtua,
    UserRole.siswa,
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(AppConstants.brandLabel, style: theme.text.brand),
              RoundIconButton(
                icon: c.isDark ? KarsaIcons.sunnyOutline : KarsaIcons.moonOutline,
                semanticsLabel:
                    c.isDark ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
                onTap: state.toggleDarkMode,
              ),
            ],
          ),
        ),
        const SchoolIdentity(),
        Text(
          'Selamat datang di KARSA',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text('Pilih peran Anda untuk melanjutkan', style: theme.text.muted),
        for (int i = 0; i < _orderedRoles.length; i++)
          _RoleSelectionCard(
            account: DemoAccount.forRole(_orderedRoles[i]),
            isBlueVariant: i == 1,
            onTap: () => state.selectRoleForLogin(_orderedRoles[i]),
          ),
        const SizedBox(height: 55),
        Text(
          'Karena setiap anak\npunya potensi yang\nberharga ♥',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DarkColorMapper.text(const Color(0xFF385D76), isDark: c.isDark),
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            height: 30 / 20,
          ),
        ),
        const SizedBox(height: 50),
        Text(
          'PROTOTIPE PEMBELAJARAN · KARSA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DarkColorMapper.text(const Color(0xFFC8AAB0), isDark: c.isDark),
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  final DemoAccount account;
  final bool isBlueVariant;
  final VoidCallback onTap;

  const _RoleSelectionCard({
    required this.account,
    required this.isBlueVariant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    final bgColor = c.isDark
        ? (isBlueVariant ? const Color(0xFF34414E) : const Color(0xFF493640))
        : (isBlueVariant ? const Color(0xFFEDF4F8) : const Color(0xFFFBEAEC));
    final borderColor = c.isDark
        ? const Color(0xFF66535E)
        : (isBlueVariant ? const Color(0xFFC9DFEA) : const Color(0xFFF2CED4));

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: MotionPressable(
        semanticsLabel: account.roleCardTitle,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(14),
          decoration: ClayStyles.soft(
            color: bgColor,
            isDark: c.isDark,
            radius: 23,
            borderColor: borderColor,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: ClayStyles.soft(
                  color: Colors.white,
                  isDark: c.isDark,
                  radius: 27,
                ),
                alignment: Alignment.center,
                child: Text(
                  account.roleEmoji,
                  style: const TextStyle(fontSize: 29),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(account.roleCardTitle, style: theme.text.itemTitle),
                    const SizedBox(height: 2),
                    Text(account.roleCardSubtitle, style: theme.text.smallMuted),
                  ],
                ),
              ),
              Icon(KarsaIcons.chevronForward, color: c.rose, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
