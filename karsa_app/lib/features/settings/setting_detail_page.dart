import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/clay_styles.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_icons.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
import '../../models/operator_profile.dart';
import '../../providers/app_state.dart';

class SettingDetailPage extends StatelessWidget {
  const SettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final setting = state.setting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: setting,
          onBack: () => state.setScreen('main'),
        ),
        if (setting == 'Informasi pribadi' && state.isOperator) ...<Widget>[
          _OperatorProfileForm(state: state, theme: theme),
        ] else if (setting == 'Informasi pribadi') ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Nama', style: theme.text.label),
          ),
          KarsaInput(
            value: state.draftTitle,
            onChanged: state.setDraftTitle,
          ),
          if (state.isStudent || state.isParent) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Kelas anak', style: theme.text.label),
            ),
            KarsaChips(
              options: state.isStudent
                  ? AppConstants.studentClasses
                  : AppConstants.parentClasses,
              value: state.data.childClass,
              onChanged: state.setChildClassFromSetting,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                state.isStudent
                    ? 'Siswa hanya dapat memilih kelas 5 atau 6.'
                    : 'Orang tua mendampingi anak kelas 1 sampai 4.',
                style: theme.text.smallMuted,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Agama siswa (opsional)', style: theme.text.label),
            ),
            KarsaChips(
              options: CurriculumData.religions,
              value: state.data.religion,
              onChanged: state.setReligion,
            ),
            Text(
              'Contoh agama disesuaikan pilihan ini. Konten lain masih umum dan perlu ditinjau guru.',
              style: theme.text.smallMuted,
            ),
          ],
          if (state.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.error,
                style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
              ),
            ),
          KarsaButton(
            title: 'Simpan perubahan',
            onTap: state.savePersonalInfo,
          ),
        ] else if (setting == 'Mata pelajaran') ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Pilih mata pelajaran guru demo. Tugas akan disaring sesuai pilihan ini.',
              style: theme.text.muted,
            ),
          ),
          KarsaChips(
            options: CurriculumData.subjects,
            value: state.data.teacherSubject,
            onChanged: state.setTeacherSubject,
          ),
          KarsaButton(
            title: 'Selesai',
            onTap: () => state.setScreen('main'),
          ),
        ] else if (setting == 'Tampilan') ...<Widget>[
          ClayCard(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Mode gelap', style: theme.text.itemTitle),
                      Text(
                        'Berlaku untuk semua peran di perangkat ini.',
                        style: theme.text.smallMuted,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: c.isDark,
                  onChanged: state.setDarkMode,
                ),
              ],
            ),
          ),
        ] else if (setting == 'Privasi dan keamanan') ...<Widget>[
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Privasi pada aplikasi demo', style: theme.text.itemTitle),
                const SizedBox(height: 8),
                Text(
                  'Data, hasil belajar, dan akun demo disimpan di perangkat ini. Belum ada sinkronisasi, autentikasi aman, atau pengiriman data ke guru.',
                  style: theme.text.muted,
                ),
              ],
            ),
          ),
        ] else if (setting == 'Notifikasi') ...<Widget>[
          ClayCard(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Notifikasi aplikasi', style: theme.text.itemTitle),
                      Text(
                        'Tampilkan lencana notifikasi pada perangkat ini',
                        style: theme.text.smallMuted,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.data.notifications,
                  onChanged: state.setNotificationsEnabled,
                ),
              ],
            ),
          ),
        ] else ...<Widget>[
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Tentang KARSA', style: theme.text.itemTitle),
                const SizedBox(height: 8),
                Text(
                  'KARSA adalah prototipe pembelajaran. Pilih tugas untuk mengerjakan kuis atau latihan untuk menjawab soal esai. Data tersimpan di perangkat ini dan belum disinkronkan.',
                  style: theme.text.muted,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Form "Informasi pribadi" untuk operator sekolah.
///
/// Role lain hanya butuh satu kolom nama. Operator butuh identitas kerja yang
/// lengkap supaya halaman ini tidak terasa kosong: avatar dengan inisial, NIP,
/// jabatan, unit kerja, dan kontak — plus indikator kelengkapan profil.
class _OperatorProfileForm extends StatelessWidget {
  final AppState state;
  final KarsaThemeScope theme;

  const _OperatorProfileForm({required this.state, required this.theme});

  @override
  Widget build(BuildContext context) {
    final c = theme.colors;
    final profile = state.operatorProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ProfileHero(profile: profile, theme: theme),
        const SizedBox(height: 18),
        Text('Identitas pegawai', style: theme.text.section),
        const SizedBox(height: 4),
        Text('Nama', style: theme.text.label),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Nama lengkap operator',
          semanticsLabel: 'Nama operator',
        ),
        Text('NIP', style: theme.text.label),
        KarsaInput(
          value: state.draftOperatorNip,
          onChanged: state.setDraftOperatorNip,
          placeholder: 'Nomor induk pegawai',
          keyboardType: TextInputType.number,
          semanticsLabel: 'NIP operator',
        ),
        Text('Jabatan', style: theme.text.label),
        KarsaInput(
          value: state.draftOperatorRole,
          onChanged: state.setDraftOperatorRole,
          placeholder: 'Mis. Operator Sekolah',
          semanticsLabel: 'Jabatan operator',
        ),
        Text('Unit kerja', style: theme.text.label),
        KarsaInput(
          value: state.draftOperatorUnit,
          onChanged: state.setDraftOperatorUnit,
          placeholder: 'Mis. SD Karitas Purwokerto',
          semanticsLabel: 'Unit kerja operator',
        ),
        const SizedBox(height: 6),
        Text('Kontak', style: theme.text.section),
        const SizedBox(height: 4),
        Text('Surel', style: theme.text.label),
        KarsaInput(
          value: state.draftOperatorEmail,
          onChanged: state.setDraftOperatorEmail,
          placeholder: 'nama@sekolah.sch.id',
          keyboardType: TextInputType.emailAddress,
          semanticsLabel: 'Surel operator',
        ),
        Text('Telepon', style: theme.text.label),
        KarsaInput(
          value: state.draftOperatorPhone,
          onChanged: state.setDraftOperatorPhone,
          placeholder: '08xxxxxxxxxx',
          keyboardType: TextInputType.phone,
          semanticsLabel: 'Telepon operator',
        ),
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: ClayStyles.inset(
            color: const Color(0xFFF7F1EE),
            isDark: c.isDark,
            radius: 14,
            borderColor: c.line,
            borderWidth: 1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(KarsaIcons.shieldCheckmarkOutline, size: 18, color: c.rose),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nama dan NIP wajib diisi. Surel dan telepon boleh dikosongkan, '
                  'tetapi kalau diisi formatnya harus benar. Semua data tersimpan '
                  'di perangkat ini pada kunci "@karsa-demo-v1".',
                  style: theme.text.smallMuted,
                ),
              ),
            ],
          ),
        ),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(KarsaIcons.helpCircleOutline, size: 17, color: c.rose),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.error,
                    style: TextStyle(
                      color: c.rose,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        KarsaButton(
          title: 'Simpan perubahan',
          onTap: () {
            final saved = state.saveOperatorProfileForm();
            if (saved) {
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Informasi operator tersimpan.')),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Kartu identitas di atas form: avatar inisial, nama, jabatan, dan seberapa
/// lengkap profilnya.
class _ProfileHero extends StatelessWidget {
  final OperatorProfile profile;
  final KarsaThemeScope theme;

  const _ProfileHero({required this.profile, required this.theme});

  @override
  Widget build(BuildContext context) {
    final c = theme.colors;
    final filled = profile.filledFields;
    final total = OperatorProfile.totalFields;
    final ratio = total == 0 ? 0.0 : filled / total;

    return ClayCard(
      padding: const EdgeInsets.all(18),
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
                  color: const Color(0xFFFBEAEC),
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
                      style: theme.text.itemTitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.role.isEmpty ? 'Operator sekolah' : profile.role,
                      style: theme.text.smallMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.unit.isEmpty ? 'Belum ada unit kerja' : profile.unit,
                      style: theme.text.smallMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Icon(KarsaIcons.cardOutline, size: 16, color: c.muted),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  profile.nip.isEmpty ? 'NIP belum diisi' : 'NIP ${profile.nip}',
                  style: theme.text.smallMuted,
                ),
              ),
            ],
          ),
          if (profile.hasContact) ...<Widget>[
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Icon(KarsaIcons.personOutline, size: 16, color: c.muted),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    <String>[
                      if (profile.email.isNotEmpty) profile.email,
                      if (profile.phone.isNotEmpty) profile.phone,
                    ].join(' · '),
                    style: theme.text.smallMuted,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: c.line,
              valueColor: AlwaysStoppedAnimation<Color>(c.rose),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            ratio >= 1
                ? 'Profil lengkap - semua kolom terisi.'
                : 'Profil $filled/$total kolom terisi. Lengkapi surel dan telepon '
                    'agar sekolah mudah menghubungi Anda.',
            style: theme.text.smallMuted,
          ),
        ],
      ),
    );
  }
}
