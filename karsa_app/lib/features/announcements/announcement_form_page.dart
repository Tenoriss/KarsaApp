import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/karsa_theme.dart';
import '../../core/widgets/karsa_button.dart';
import '../../core/widgets/karsa_chips.dart';
import '../../core/widgets/karsa_input.dart';
import '../../core/widgets/page_header.dart';
import '../../providers/app_state.dart';

class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;

    // Wali kelas: kelasnya sendiri. Guru mapel: "Semua kelas" + kelas yang
    // benar-benar diajar mapelnya. Operator/admin: semua kelas.
    final List<String> classOptions;
    if (state.isWali) {
      classOptions = const <String>[AppConstants.waliClass];
    } else if (state.isTeacher) {
      classOptions = <String>['Semua kelas', ...state.teacherClasses];
    } else {
      classOptions = const <String>['Semua kelas', ...AppConstants.classes];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          title: 'Buat pengumuman',
          sub: 'Data demo tersimpan di perangkat ini',
          onBack: () => state.setScreen('announcements'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Judul', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftTitle,
          onChanged: state.setDraftTitle,
          placeholder: 'Mis. Libur sekolah',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Isi pengumuman', style: theme.text.label),
        ),
        KarsaInput(
          value: state.draftBody,
          onChanged: state.setDraftBody,
          placeholder: 'Tulis pengumuman...',
          multiline: true,
          minHeight: 120,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Untuk kelas', style: theme.text.label),
        ),
        KarsaChips(
          options: classOptions,
          // Jaga-jaga: bila kelas tersimpan di luar opsi (mis. guru berganti
          // mapel), jatuhkan ke opsi pertama supaya tidak ada chip terpilih
          // yang tak terlihat.
          value: classOptions.contains(state.draftClass)
              ? state.draftClass
              : classOptions.first,
          onChanged: state.setDraftClass,
        ),
        if (state.isTeacher && state.teacherClasses.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Pengumuman hanya dikirim ke kelas yang kamu ajar '
              '(${state.teacherClasses.join(', ')}).',
              style: theme.text.smallMuted,
            ),
          ),
        if (state.error.isNotEmpty)
          Text(
            state.error,
            style: TextStyle(color: c.rose, fontWeight: FontWeight.w800),
          ),
        KarsaButton(
          title: 'Kirim pengumuman',
          onTap: state.saveAnnouncement,
        ),
      ],
    );
  }
}
