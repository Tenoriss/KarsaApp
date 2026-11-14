import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/page_header.dart';
import '../../data/curriculum_data.dart';
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
        if (setting == 'Informasi pribadi') ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Nama', style: theme.text.label),
          ),
          KarsaInput(
            value: state.draftTitle,
            onChanged: state.setDraftTitle,
          ),
          if (!state.isTeacher) ...<Widget>[
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
