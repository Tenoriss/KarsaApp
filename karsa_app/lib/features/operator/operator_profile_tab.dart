import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/dark_color_mapper.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/motion_pressable.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/school_identity.dart';
import '../../models/operator_profile.dart';
import '../../providers/app_state.dart';

/// Tab **Profil** operator sekolah — tab keenam, di sebelah Media.
///
/// Sebelumnya kartu identitas operator menempel di ujung beranda sehingga
/// tenggelam di bawah lima kartu pintasan. Sekarang profil punya tab sendiri:
/// identitas kerja ditampilkan lengkap dan read-only, dengan tombol Ubah yang
/// membuka form "Informasi pribadi" yang sudah ada.
class OperatorProfileTab extends StatelessWidget {
  const OperatorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final profile = state.operatorProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PageHeader(
          title: 'Profil Operator',
          sub: 'Identitas kerja dan pengaturan akun',
        ),
        const SchoolIdentity(),
        const SizedBox(height: 16),
        _ProfileHero(profile: profile),
        const SizedBox(height: 20),
        Text('Informasi pribadi', style: theme.text.section),
        const SizedBox(height: 10),
        _ProfileFields(profile: profile),
        const SizedBox(height: 18),
        Text('Pengaturan', style: theme.text.section),
        const SizedBox(height: 10),
        ClayCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (final item in _settingsItems)
                _SettingRow(
                  icon: item.$1,
                  label: item.$2,
                  onTap: () => state.openSetting(item.$2),
                  isLast: item == _settingsItems.last,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: MotionPressable(
            semanticsLabel: 'Keluar dari akun demo',
            onTap: state.logout,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Keluar dari akun demo', style: theme.text.link),
            ),
          ),
        ),
        Text(
          'Data profil tersimpan di perangkat ini pada kunci "@karsa-demo-v1".',
          style: theme.text.smallMuted,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Daftar pengaturan yang relevan untuk operator.
  static const List<(IconData, String)> _settingsItems = <(IconData, String)>[
    (KarsaIcons.sunnyOutline, 'Tampilan'),
    (KarsaIcons.notificationsOutline, 'Notifikasi'),
    (KarsaIcons.shieldCheckmarkOutline, 'Privasi dan keamanan'),
    (KarsaIcons.helpCircleOutline, 'Pusat bantuan'),
  ];
}

/// Kepala profil: avatar inisial, nama, unit kerja, dan tombol Ubah.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final OperatorProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final state = context.watch<AppState>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ClayStyles.soft(
        color: const Color(0xFFFBEAEC),
        isDark: c.isDark,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: ClayStyles.soft(
                  color: Colors.white,
                  isDark: c.isDark,
                  customRadius: BorderRadius.circular(31),
                ),
                child: Text(
                  profile.initials,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: c.rose,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.name.isEmpty ? 'Operator Sekolah' : profile.name,
                      style: theme.text.itemTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.role.isEmpty ? 'Operator sekolah' : profile.role,
                      style: theme.text.smallMuted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.unit.isEmpty
                          ? 'Unit kerja belum diisi'
                          : profile.unit,
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MotionPressable(
            semanticsLabel: 'Ubah profil operator',
            onTap: () => state.openSetting('Informasi pribadi'),
            child: Container(
              height: 44,
              decoration: ClayStyles.raised(
                color: c.rose,
                isDark: c.isDark,
                radius: 15,
              ),
              alignment: Alignment.center,
              child: const Text(
                'Ubah profil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enam kolom profil read-only beserta indikator kelengkapan.
class _ProfileFields extends StatelessWidget {
  const _ProfileFields({required this.profile});

  final OperatorProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final filled = profile.filledFields;
    final missing = <String>[
      if (profile.email.isEmpty) 'surel',
      if (profile.phone.isEmpty) 'telepon',
    ];
    final fields = <(String, String)>[
      ('Nama lengkap', profile.name),
      ('NIP', profile.nip),
      ('Jabatan', profile.role),
      ('Unit kerja', profile.unit),
      ('Surel', profile.email),
      ('Telepon', profile.phone),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: ClayStyles.soft(color: c.card, isDark: c.isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < fields.length; i++)
            _ProfileField(
              label: fields[i].$1,
              value: fields[i].$2,
              isLast: i == fields.length - 1,
            ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: ClayStyles.inset(
              color: DarkColorMapper.surface(
                const Color(0xFFFBF3F4),
                isDark: c.isDark,
              ),
              isDark: c.isDark,
              radius: 13,
              borderColor: const Color(0xFFF1E5E2),
              borderWidth: 1,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  filled < OperatorProfile.totalFields
                      ? KarsaIcons.helpCircleOutline
                      : KarsaIcons.checkmarkCircle,
                  size: 17,
                  color: filled < OperatorProfile.totalFields ? c.rose : c.blue,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    filled < OperatorProfile.totalFields
                        ? 'Lengkapi ${missing.isEmpty ? 'data pribadi' : missing.join(' & ')} '
                            '($filled/${OperatorProfile.totalFields} kolom terisi)'
                        : 'Data pribadi sudah lengkap',
                    style: theme.text.smallMuted.copyWith(
                      color: c.rose,
                      fontWeight: FontWeight.w700,
                    ),
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

/// Satu baris label–nilai pada daftar informasi pribadi.
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final empty = value.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 104, child: Text(label, style: theme.text.smallMuted)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              empty ? 'Belum diisi' : value,
              style: TextStyle(
                fontSize: 13,
                height: 18 / 13,
                fontWeight: empty ? FontWeight.w500 : FontWeight.w700,
                color: empty ? c.muted : c.ink,
                fontStyle: empty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris pengaturan dengan ikon, label, dan panah.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: ClayStyles.soft(
                color: const Color(0xFFF8EBEC),
                isDark: c.isDark,
                radius: 12,
              ),
              child: Icon(icon, size: 18, color: c.rose),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: theme.text.itemTitle),
            ),
            Icon(KarsaIcons.chevronForward, size: 17, color: c.muted),
          ],
        ),
      ),
    );
  }
}
